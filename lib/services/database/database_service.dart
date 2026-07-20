import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'noteai.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Create main notes table
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        raw_transcript TEXT,
        summary_json TEXT,
        created_at INTEGER
      )
    ''');

    // 2. Create FTS5 virtual table for fast full-text search
    await db.execute('''
      CREATE VIRTUAL TABLE notes_fts USING fts5(
        title, 
        raw_transcript, 
        summary_json, 
        content='notes', 
        content_rowid='id'
      )
    ''');
  }

  // Note: We will add triggers or methods to keep FTS in sync during Insert/Update
}
