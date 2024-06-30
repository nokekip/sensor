import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMU Data Recording',
      theme: ThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool recording; // Variable to indicate recording status
  late List<StreamSubscription<dynamic>> _streamSubscriptions;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    recording = false;
    _streamSubscriptions = [];
    _databaseHelper = DatabaseHelper.instance;
  }

  @override
  void dispose() {
    stopRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMU Data Recording'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: recording ? stopRecording : startRecording,
              child: Text(recording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }

  void stopRecording() {
    for (var subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    setState(() {
      recording = false;
    });
  }

  void startRecording() {
    // Add subscriptions for sensors
    _streamSubscriptions.add(
      accelerometerEvents.listen((AccelerometerEvent event) {
        // Handle accelerometer data
        // Insert into database or process as required
      }),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen((GyroscopeEvent event) {
        // Handle gyroscope data
        // Insert into database or process as required
      }),
    );
    _streamSubscriptions.add(
      magnetometerEvents.listen((MagnetometerEvent event) {
        // Handle magnetometer data
        // Insert into database or process as required
      }),
    );
    setState(() {
      recording = true;
    });
  }
}

class ImuData {
  // Define variables to store IMU data
  double? xAcc, yAcc, zAcc; // Example variables

  ImuData({
    this.xAcc,
    this.yAcc,
    this.zAcc,
  });

  Map<String, dynamic> toMap() {
    return {
      'xAcc': xAcc,
      'yAcc': yAcc,
      'zAcc': zAcc,
    };
  }
}

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = Path.join(documentsDirectory.path, 'imu_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE imu_data(
        id INTEGER PRIMARY KEY,
        xAcc REAL,
        yAcc REAL,
        zAcc REAL
      )
    ''');
  }

  Future<void> insertImuData(ImuData imuData) async {
    Database db = await instance.database;
    await db.insert('imu_data', imuData.toMap());
  }

  Future<void> exportDatabase() async {
    // Export database logic
    // Example of exporting database as a file and sharing
    try {
      Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
      String databasePath = Path.join(appDocumentsDirectory.path, 'imu_database.db');
      File databaseFile = File(databasePath);
      
      List<String> filePaths = [databaseFile.path];
      // await Share.shareFiles(filePaths);
      await Share.shareXFiles(filePaths.cast<XFile>());
    } catch (e) {
      print('Error exporting database: $e');
    }
  }
}
