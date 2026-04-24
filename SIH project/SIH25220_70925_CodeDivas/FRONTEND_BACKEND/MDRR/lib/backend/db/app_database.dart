// lib/backend/db/app_database.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mdr_contact_tracing.db');


    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE patients (
      id TEXT PRIMARY KEY,
      name TEXT,
      age INTEGER,
      ward TEXT,
      is_mdr_known INTEGER,
      sync_status INTEGER DEFAULT 0,
      
      -- 👇 NEW COLUMNS
      mdr_pathogen TEXT,
      mdr_syndrome TEXT,
      transmission_type TEXT
    );
    ''');

    await db.execute('''
      CREATE TABLE movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT,
        ward TEXT,
        time_in TEXT,
        time_out TEXT
        sync_status INTEGER DEFAULT 0

      );
    ''');

    await db.execute('''
      CREATE TABLE equipment_usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT,
        equipment_name TEXT,
        timestamp TEXT,
        shared_with_others INTEGER
        sync_status INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE contact_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        index_patient_id TEXT,
        contact_patient_id TEXT,
        start_time TEXT,
        end_time TEXT,
        location TEXT
        sync_status INTEGER DEFAULT 0
      );
    ''');
    await db.execute('''
      CREATE TABLE risk_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT,
        backend_exposure_risk REAL,
        ml_clinical_risk REAL,
        final_risk REAL,
        calculated_at TEXT,
        explanation TEXT
        sync_status INTEGER DEFAULT 0
      );
    ''');


    await db.execute('''
      CREATE TABLE clinical_observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT,
        temperature REAL,
        icu_days INTEGER,
        ventilator_days INTEGER,
        antibiotic_days INTEGER,
        comorbidities_score INTEGER,
        previous_mdr_history INTEGER,
        lab_mdr_positive INTEGER,
        recorded_at TEXT
        sync_status INTEGER DEFAULT 0
      );
    ''');

  }
}
