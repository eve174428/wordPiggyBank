import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // join()

//tableName
const String table_score = 'score';
//tableHeader
const String th_testName = 'testName';
const String th_time = 'time';
const String th_score = 'score';

class TestResult {
  final String? testName;
  final String? time;
  final int? score;
  TestResult({this.testName, this.time, this.score});

  Map<String, dynamic> toMap() {
    return {
      th_testName: this.testName,
      th_time: this.time,
      th_score: this.score,
    };
  }
}

//sqlite
class ScoreDB extends ChangeNotifier {
  Database? db;
  List<TestResult> scoreList = [];
  //create
  Future<void> _createDB(Database db) async {
    Batch batch = db.batch();
    batch.execute('''CREATE TABLE IF NOT EXISTS $table_score(
    $th_time REAL PRIMARY KEY,
    $th_testName TEXT,
    $th_score INT
    )''');
    await batch.commit(noResult: true);
  }

  //open
  Future<void> openDB() async {
    String path = join(await getDatabasesPath(), 'score.db');
    db = await openDatabase(
      path,
      onCreate: (db, version) async {
        return await _createDB(db);
      },
      version: 1,
    );
    print('database is created');
    notifyListeners();
  }

  //insert
  Future<void> insertScoreTb(TestResult result) async {
    if (db == null) {
      await openDB();
    }
    await db!.insert(table_score, result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('new data is inserted!');
    notifyListeners();
  }

  //query
  Future<List<TestResult>> queryScoreTb() async {
    final List<Map<String, dynamic>> scores =
        await db!.query(table_score, orderBy: "$th_time DESC");
    return List.generate(scores.length, (i) {
      print('database has ${scores.length} data.');
      return TestResult(
        testName: scores[i][th_testName],
        time: scores[i][th_time],
        score: scores[i][th_score],
      );
    });
  }

  //clean table
  Future<void> deleteScoreTb() async {
    await db!.delete(table_score);
    await openDB();
  }
}
