import '../db/app_database.dart';
import '../models/movement.dart';

class MovementService {
  final AppDatabase _dbHelper = AppDatabase();

  Future<void> addMovement(Movement move) async {
    final db = await _dbHelper.database;
    await db.insert('movements', move.toMap());
  }

  Future<List<Movement>> getMovementsForPatient(String patientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'movements',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    return maps.map((m) => Movement.fromMap(m)).toList();
  }
}
