import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/clinical_observation.dart';
class ClinicalService {
  final AppDatabase _dbHelper = AppDatabase();

  Future<void> insertObservation(ClinicalObservation obs) async {
    final db = await _dbHelper.database;
    await db.insert(
      'clinical_observations',
      obs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // old name still works, just calls the new one
  Future<void> addObservation(ClinicalObservation obs) async {
    await insertObservation(obs);
  }

  Future<ClinicalObservation?> getLatestForPatient(String patientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'clinical_observations',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ClinicalObservation.fromMap(maps.first);
  }
}
