import 'dart:io';

import 'package:tesla_tracker/tool.dart';

main(List<String> args) async {
  var config = await TeslaTrackerConfig.load(args[0]);
  var conn = config.getPostgresConnection();
  await conn.open();
  await conn.transaction((c) async {
    var path = Platform.script.resolve("../schema").toFilePath();
    var dir = new Directory(path);

    await for (var file in dir.list().where((e) => e.path.endsWith(".sql"))) {
      if (file is! File) {
        continue;
      }

      var content = await (file as File).readAsString();
      var statements = content.split(";");
      for (var stmt in statements) {
        if (stmt.trim().isEmpty) continue;
        await c.execute(stmt);
      }
    }
  });
  await conn.close();
}
