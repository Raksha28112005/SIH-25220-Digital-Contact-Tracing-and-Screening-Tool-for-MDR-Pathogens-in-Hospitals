import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/patient.dart';

class PatientService {
  final AppDatabase _dbHelper = AppDatabase();

  Future<void> addPatient(Patient patient) async {
    final db = await _dbHelper.database;
    final map = patient.toMap();
    map['sync_status'] = 0; // 0 = pending sync to cloud
    await db.insert(
      'patients',
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 🔍 GET patient by ID (used by doctor during risk evaluation)
  Future<Patient?> getPatientById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  /// (optional) get all patients
  Future<List<Patient>> getAllPatients() async {
    final db = await _dbHelper.database;
    final maps = await db.query('patients');
    return maps.map((m) => Patient.fromMap(m)).toList();
  }
}
