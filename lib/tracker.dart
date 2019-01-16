library tesla.tracker;

import 'dart:async';
import 'dart:convert';

import 'package:tesla/tesla.dart';
import 'package:postgres/postgres.dart';

class VehicleTracker {
  final PostgreSQLConnection conn;
  Vehicle vehicle;

  String phase = "unknown";

  VehicleTracker(this.vehicle, this.conn);

  bool get isRunning => _timer != null;

  Timer _timer;

  void start() {
    stop();
    phase = "started";

    _timer = new Timer(const Duration(seconds: 5), () {
      _update(true);
    });
  }

  void stop() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    phase = "stopped";
  }

  Future update() async {
    return await _update(false);
  }

  void sleep() {
    stop();
    phase = "sleeping";
    _timer = new Timer(const Duration(minutes: 30), () {
      start();
    });
  }

  Future _update(bool scheduled) async {
    try {
      vehicle = await vehicle.client.getVehicle(vehicle.id);
      if (vehicle.state == "online") {
        await _publishState();
      }

      await _publishUptime(vehicle.state);
    } catch (e, stack) {
      print("ERROR: Failed to update vehicle: ${e}");
      print(stack);
    } finally {
      if (scheduled && _timer != null) {
        _timer = new Timer(const Duration(seconds: 5), () {
          _update(true);
        });
      }
    }
  }

  Future _publishState() async {
    var state = await vehicle.getAllVehicleState();
    var json = new Map<String, dynamic>.from(state.json);
    json["timestamp"] = new DateTime.now().millisecondsSinceEpoch;
    await conn.execute(
      "INSERT INTO telemetry (time, vehicle, state) VALUES (NOW(), @vehicle, @state)",
      substitutionValues: {
        "vehicle": vehicle.id,
        "state": const JsonEncoder().convert(json)
      }
    );
  }

  Future _publishUptime(String state) async {
    await conn.execute(
      "INSERT INTO uptime (time, vehicle, status) VALUES (NOW(), @vehicle, @state)",
      substitutionValues: {
        "vehicle": vehicle.id,
        "state": state
      }
    );
  }
}
