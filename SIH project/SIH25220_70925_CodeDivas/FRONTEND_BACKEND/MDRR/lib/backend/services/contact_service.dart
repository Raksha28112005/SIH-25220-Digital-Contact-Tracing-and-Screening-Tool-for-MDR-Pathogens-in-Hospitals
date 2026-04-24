import '../db/app_database.dart';
import '../models/contact_event.dart';

class ContactService {
  final AppDatabase _dbHelper = AppDatabase();

  Future<void> addContactEvent(ContactEvent event) async {
    final db = await _dbHelper.database;
    await db.insert('contact_events', event.toMap());
  }

  Future<List<ContactEvent>> getContacts(String patientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('contact_events',
        where: 'index_patient_id = ?', whereArgs: [patientId]);
    return maps.map((c) => ContactEvent.fromMap(c)).toList();
  }
}
