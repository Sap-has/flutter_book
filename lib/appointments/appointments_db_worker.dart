import 'package:flutterbook/base_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'appointments_model.dart';

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class AppointmentsDBWorker implements EntryDBWorker<Appointment> {
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  static const String DB_NAME = 'appointments.db';
  static const String TBL_NAME = 'appointments';
  static const String KEY_ID = 'id';
  static const String KEY_TITLE = 'title';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_DATE = 'date';
  static const String KEY_TIME = 'time';

  Database? _db;

  AppointmentsDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    // Initialize databaseFactory for desktop platforms
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);

    return await openDatabase(DB_NAME,
    version: 1,
    onOpen: (db) {},
    onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS $TBL_NAME ('
            '$KEY_ID INTEGER PRIMARY KEY,'
            '$KEY_TITLE TEXT,'
            '$KEY_DESCRIPTION TEXT,'
            '$KEY_DATE INTEGER,'
            '$KEY_TIME INTEGER'
        ')'
      );
    });
  }

  @override
  Future<int> create(Appointment app) async {
    Database db = await database;
    return await db.rawInsert(
      'INSERT INTO $TBL_NAME ($KEY_TITLE, $KEY_DESCRIPTION, $KEY_DATE, $KEY_TIME)'
          'VALUES (?, ?, ?, ?)',
      [app.title, app.description, app.dateInUnix ?? -1, app.timeInUnix ?? -1]
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
  }

  @override
  Future<Appointment?> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
    return values.isEmpty ? null : _appFromMap(values.first);
  }

  @override
  Future<List<Appointment>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _appFromMap(m)).toList() : [];
  }

  @override
  Future<void> update(Appointment app) async {
    Database db = await database;
    await db.update(TBL_NAME, _appToMap(app),
      where: '$KEY_ID = ?', whereArgs: [app.id]);
  }

  Appointment _appFromMap(Map<String, dynamic> map) => Appointment(
      id: map[KEY_ID],
      title: map[KEY_TITLE],
      description: map[KEY_DESCRIPTION])
    ..dateInUnix = map[KEY_DATE] >= 0 ? map[KEY_DATE] : null
    ..timeInUnix = map[KEY_TIME] >= 0 ? map[KEY_TIME] : null;

  Map<String, dynamic> _appToMap(Appointment app) => <String, dynamic> {}
    ..[KEY_ID] = app.id
    ..[KEY_TITLE] = app.title
    ..[KEY_DESCRIPTION] = app.description
    ..[KEY_DATE] = app.dateInUnix ?? -1
    ..[KEY_TIME] = app.timeInUnix ?? -1;
}