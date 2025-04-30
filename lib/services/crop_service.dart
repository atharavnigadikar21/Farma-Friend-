import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farma_friend/model/SoilData.dart';
import 'package:farma_friend/model/crop_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CropService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Database? _database;

  // Initialize the local SQLite database
  Future<void> initLocalDb() async {
    log("Initializing local database");
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'crops9.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE crops(
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            pesticides TEXT,
            imageUrl TEXT,
            season TEXT,
            minNitrogenLevel REAL,
            maxNitrogenLevel REAL,
            minPhosphorusLevel REAL,
            maxPhosphorusLevel REAL,
            minPotassiumLevel REAL,
            maxPotassiumLevel REAL,
            minMoisture REAL,
            maxMoisture REAL,
            minTemperature REAL,
            maxTemperature REAL,
            minPHLevel REAL,
            maxPHLevel REAL
          )
          ''',
        );

        await db.execute(
          '''
          CREATE TABLE soildata(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ph TEXT,
            moisture TEXT,
            temp TEXT,
            nitrogen TEXT,
            phosphorus TEXT,
            potassium TEXT,
            date TEXT
          )
          ''',
        );
      },
    );
  }

  // Ensure the local database is initialized
  Future<void> _ensureInitialized() async {
    if (_database == null) {
      await initLocalDb();
      log("Local database initialized successfully");
    }
  }

  // Insert Soil Data
  Future<void> insertSoilData(SoilData soilData) async {
    await _ensureInitialized();
    final db = _database;
    if (db == null) {
      log("Database not initialized");
      return;
    }
    
    await db.insert(
      'soildata',
      soilData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log("Soil data inserted successfully");
  }

  // Fetch all Soil Data
  Future<List<SoilData>> fetchAllSoilData() async {
    await _ensureInitialized();
    final db = _database;
    final List<Map<String, dynamic>> maps = await db!.query('soildata');
    
    log("Fetched soil data from local database");
    return List.generate(maps.length, (i) {
      return SoilData(
        id: maps[i]['id'],
        ph: maps[i]['ph'],
        moisture: maps[i]['moisture'],
        temp: maps[i]['temp'],
        nitrogen: maps[i]['nitrogen'],
        phosphorus: maps[i]['phosphorus'],
        potassium: maps[i]['potassium'],
        date: maps[i]['date'],
      );
    });
  }

  // Sync crops from Firestore to Local DB
  Future<void> syncCropsFromFirebase() async {
    await _ensureInitialized();
    try {
      final cropsFromFirebase = await fetchCropsFromFirebase();
      for (var crop in cropsFromFirebase) {
        await _database?.insert('crops', crop.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      log("Successfully synced crops from Firebase");
    } catch (e) {
      log('Error syncing crops from Firebase: $e');
    }
  }

  // Add crop details to Firestore and local database
  Future<void> addCrop(Crop crop) async {
    await _ensureInitialized();
    try {
      await _firestore.collection('crops').doc(crop.id).set(crop.toMap());
      await _database?.insert('crops', crop.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      log("Crop added successfully");
    } catch (e) {
      log('Error adding crop: $e');
    }
  }

  // Fetch crop details from Firestore
  Future<List<Crop>> fetchCropsFromFirebase() async {
    try {
      final snapshot = await _firestore.collection('crops').get();
      return snapshot.docs.map((doc) => Crop.fromMap(doc.data())).toList();
    } catch (e) {
      log(' From Crop Service Error fetching crops from Firebase: $e');
      return []; // Return an empty list on error
    }
  }

  // Fetch crop details from local database
  Future<List<Crop>> fetchCropsFromLocalDb() async {
    await _ensureInitialized();
    try {
      final crops = await _database?.query('crops');
      return crops != null
          ? crops.map((crop) => Crop.fromMap(crop)).toList()
          : [];
    } catch (e) {
      log('Error fetching crops from local database: $e');
      return []; // Return an empty list on error
    }
  }

  // Fetch specific crop details from local database
  Future<Crop?> fetchCropById(String id) async {
    await _ensureInitialized();
    try {
      final crops =
          await _database?.query('crops', where: 'id = ?', whereArgs: [id]);
      return crops != null && crops.isNotEmpty
          ? Crop.fromMap(crops.first)
          : null;
    } catch (e) {
      log('Error fetching crop by ID: $e');
      return null; // Return null on error
    }
  }
}
