library tesla.tracker.tool;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:tesla/tesla.dart';

class TeslaTrackerConfig {
  static Future<TeslaTrackerConfig> load(String path) async {
    var file = new File(path);

    if (!(await file.exists())) {
      throw new Exception("The file '${path}' does not exist.");
    }

    var content = await file.readAsString();
    var map = const JsonDecoder().convert(content);
    if (map is! Map) {
      throw new Exception("The file '${path}' does not contain a JSON map.");
    }

    return new TeslaTrackerConfig(map);
  }

  final Map<String, dynamic> config;

  TeslaTrackerConfig(this.config);

  String get dbHost => config["db.host"];
  int get dbPort => config["db.port"];
  String get dbName => config["db.name"];
  String get dbUser => config["db.user"];
  String get dbPassword => config["db.pass"];

  String get teslaEmail => config["tesla.email"];
  String get teslaPassword => config["tesla.password"];

  int get httpPort => config["http.port"];
  String get httpToken => config["http.token"];

  PostgreSQLConnection getPostgresConnection() {
    return new PostgreSQLConnection(
      dbHost,
      dbPort,
      dbName,
      username: dbUser,
      password: dbPassword
    );
  }

  TeslaClient getTeslaClient() {
    return new TeslaClient(teslaEmail, teslaPassword);
  }
}
