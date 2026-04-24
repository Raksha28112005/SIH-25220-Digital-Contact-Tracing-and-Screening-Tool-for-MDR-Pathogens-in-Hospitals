import 'dart:convert';
import 'package:http/http.dart' as http;

import '../db/app_database.dart';

class SyncService {
  final AppDatabase _dbHelper = AppDatabase();

  // 👉 TODO: change this to your real AWS API URL later
  static const String baseUrl =
      'https://wlqnbyplma.execute-api.ap-south-1.amazonaws.com';

  Future<void> syncToCloud() async {
    final db = await _dbHelper.database;

    // 1) Get unsynced rows from each table
    final unsyncedPatients = await db.query(
      'patients',
      where: 'sync_status = ?',
      whereArgs: [0],
    );
    final unsyncedMovements = await db.query(
      'movements',
      where: 'sync_status = ?',
      whereArgs: [0],
    );
    final unsyncedContacts = await db.query(
      'contact_events',
      where: 'sync_status = ?',
      whereArgs: [0],
    );
    final unsyncedClinical = await db.query(
      'clinical_observations',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    if (unsyncedPatients.isEmpty &&
        unsyncedMovements.isEmpty &&
        unsyncedContacts.isEmpty &&
        unsyncedClinical.isEmpty) {
      // nothing to sync
      return;
    }

    // 2) Create JSON payload
    final payload = {
      'patients': unsyncedPatients,
      'movements': unsyncedMovements,
      'contacts': unsyncedContacts,
      'clinical_observations': unsyncedClinical,
    };

    final uri = Uri.parse('$baseUrl/sync');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      // 3) Mark as synced (sync_status = 1)
      await db.update(
        'patients',
        {'sync_status': 1},
        where: 'sync_status = ?',
        whereArgs: [0],
      );
      await db.update(
        'movements',
        {'sync_status': 1},
        where: 'sync_status = ?',
        whereArgs: [0],
      );
      await db.update(
        'contact_events',
        {'sync_status': 1},
        where: 'sync_status = ?',
        whereArgs: [0],
      );
      await db.update(
        'clinical_observations',
        {'sync_status': 1},
        where: 'sync_status = ?',
        whereArgs: [0],
      );
    } else {
      throw Exception(
        'Sync failed: ${response.statusCode} ${response.body}',
      );
    }
  }
}
