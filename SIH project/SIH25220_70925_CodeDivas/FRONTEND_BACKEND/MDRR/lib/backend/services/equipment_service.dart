import '../db/app_database.dart';
import '../models/equipment_usage.dart';

class EquipmentService {
  final AppDatabase _dbHelper = AppDatabase();

  Future<void> addUsage(EquipmentUsage usage) async {
    final db = await _dbHelper.database;
    await db.insert('equipment_usage', usage.toMap());
  }

  Future<List<EquipmentUsage>> getUsage(String patientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('equipment_usage',
        where: 'patient_id = ?', whereArgs: [patientId]);
    return maps.map((u) => EquipmentUsage.fromMap(u)).toList();
  }
}
