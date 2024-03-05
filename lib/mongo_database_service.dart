import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_database/models/milazzo_path_model.dart';

class MongoDatabaseService {
  static final MongoDatabaseService _singleton = MongoDatabaseService._internal();

  factory MongoDatabaseService() {
    return _singleton;
  }

  MongoDatabaseService._internal();

  late Db db;
  static const String dbName = 'milazzo_path';
  Future<void> connect() async {
    db = await Db.create('mongodb+srv://fmartella:RDeJqpUQSwheC92L@innova4virgin.l1puulw.mongodb.net/$dbName?retryWrites=true&w=majority');
    await db.open();
  }

  Future<Map<String, Object?>>  getServerStatus() async {
    var status = db.serverStatus();
    return status;
  }

  Future<List<PathMilazzo>> getPaths() async {
    var collection = db.collection('paths');
    var pathsJson = await collection.find().toList();

    List<PathMilazzo> paths = pathsJson.map<PathMilazzo>((pathJson) => PathMilazzo.fromJson(pathJson)).toList();

    return paths;
  }

  Future<List<String>> getDatabaseNames() async {
    var dbs = await db.listDatabases();
    for (var value in dbs) {
      print(value.toString());
    }
    return dbs.map<String>((db) => db[0].toString()).toList();
  }
}
