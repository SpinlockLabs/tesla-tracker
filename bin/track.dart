import 'dart:convert';
import 'dart:io';

import 'package:tesla_tracker/tool.dart';
import 'package:tesla_tracker/tracker.dart';

final JsonEncoder _jsonEncoder = const JsonEncoder.withIndent("  ");

final Map<int, VehicleTracker> trackers = <int, VehicleTracker>{};

handleVehicleRequest(int vehicleId, HttpRequest request, HttpResponse response) async {
  if (!trackers.containsKey(vehicleId)) {
    response.statusCode = HttpStatus.notFound;
    response.writeln(_jsonEncoder.convert({
      "error": "unknown_vehicle",
      "message": "The vehicle ${vehicleId} is unknown."
    }));
    return;
  }

  var tracker = trackers[vehicleId];
  if (request.uri.pathSegments.length > 3 &&
      request.uri.pathSegments[3].isNotEmpty) {
    if (request.method != "POST") {
      response.statusCode = HttpStatus.methodNotAllowed;
      response.writeln("POST method is required.");
      return;
    }
    var sub = request.uri.pathSegments[3];

    if (sub == "stop") {
      tracker.stop();
    } else if (sub == "start") {
      tracker.start();
    } else if (sub == "sleep") {
      tracker.sleep();
    } else if (sub == "wake") {
      await tracker.vehicle.wake();
      tracker.start();
    } else {
      response.statusCode = HttpStatus.badRequest;
      response.writeln("Unknown command.");
      return;
    }
  } else {
    response.headers.contentType = ContentType.json;
    response.writeln(_jsonEncoder.convert({
      "id": vehicleId,
      "status": tracker.phase,
      "vehicle": {
        "name": tracker.vehicle.displayName,
        "vin": tracker.vehicle.vin,
        "id": tracker.vehicle.id,
        "state": tracker.vehicle.state
      }
    }));
  }
}

handleRequest(HttpRequest request) async {
  var response = request.response;

  if (request.uri.path == "/api/trackers") {
    response.headers.contentType = ContentType.json;
    response.writeln(_jsonEncoder.convert(trackers.keys.toList()));
  } else if (request.uri.path.startsWith("/api/tracker/")) {
    var pid = request.uri.path.split("/")[3];
    try {
      int vehicleId = int.parse(pid);
      handleVehicleRequest(vehicleId, request, response);
    } on FormatException {
      response.statusCode = HttpStatus.notFound;
    }
  } else if (request.uri.path.startsWith("/control/")) {
    if (request.uri.pathSegments.length == 2) {
      var id = int.parse(request.uri.pathSegments[1]);
      if (!trackers.containsKey(id)) {
        response.statusCode = HttpStatus.notFound;
        response.writeln("Tracker does not exist.");
      } else {
        var tracker = trackers[id];
        var file = new File(Platform.script.resolve("../resources/controller.html").toFilePath());
        var content = await file.readAsString();
        content = content.replaceAll("{{name}}", tracker.vehicle.displayName);
        content = content.replaceAll("{{id}}", tracker.vehicle.id.toString());
        response.headers.contentType = ContentType.html;
        response.writeln(content);
      }
    }
  } else {
    response.statusCode = HttpStatus.notFound;
    response.writeln("404: Not Found");
  }

  response.close();
}

main(List<String> args) async {
  var config = await TeslaTrackerConfig.load(args[0]);
  var conn = config.getPostgresConnection();
  await conn.open();
  var client = config.getTeslaClient();

  var server = await HttpServer.bind("0.0.0.0", config.httpPort);

  for (var vehicle in await client.listVehicles()) {
    var tracker = new VehicleTracker(vehicle, conn);
    tracker.start();
    trackers[tracker.vehicle.id] = tracker;

    print("New controller available at http://127.0.0.1:${config.httpPort}/control/${vehicle.id}");
  }

  await for (var request in server) {
    try {
      if (config.httpToken != null) {
        if (request.uri.queryParameters["token"] == config.httpToken) {
          request.session["authed"] = true;
        }

        if (request.session["authed"] != true) {
          request.response.statusCode = HttpStatus.badRequest;
          request.response.writeln("Token is required.");
          request.response.close();
          continue;
        }
      }

      await handleRequest(request);
    } catch (e, stack) {
      request.response.writeln(e.toString());
      print(e);
      print(stack);
      request.response.close();
    }
  }
}
