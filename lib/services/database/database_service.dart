import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
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

    // 3. Create Triggers to auto-sync notes_fts when notes table changes
    await db.execute('''
      CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
        INSERT INTO notes_fts(rowid, title, raw_transcript, summary_json) 
        VALUES (new.id, new.title, new.raw_transcript, new.summary_json);
      END;
    ''');
    
    await db.execute('''
      CREATE TRIGGER notes_ad AFTER DELETE ON notes BEGIN
        INSERT INTO notes_fts(notes_fts, rowid, title, raw_transcript, summary_json) 
        VALUES ('delete', old.id, old.title, old.raw_transcript, old.summary_json);
      END;
    ''');
    
    await db.execute('''
      CREATE TRIGGER notes_au AFTER UPDATE ON notes BEGIN
        INSERT INTO notes_fts(notes_fts, rowid, title, raw_transcript, summary_json) 
        VALUES ('delete', old.id, old.title, old.raw_transcript, old.summary_json);
        INSERT INTO notes_fts(rowid, title, raw_transcript, summary_json) 
        VALUES (new.id, new.title, new.raw_transcript, new.summary_json);
      END;
    ''');
  }

  /// Insert a new note safely
  Future<int> insertNote(Map<String, dynamic> note) async {
    try {
      final db = await database;
      return await db.insert('notes', note, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Database Insert Error: $e');
      return -1;
    }
  }

  /// Perform Full-Text Search in < 100ms
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    try {
      final db = await database;
      // Use MATCH for FTS5 queries, safely wrap the query
      final sanitizedQuery = query.replaceAll('"', '""');
      return await db.rawQuery('''
        SELECT notes.* FROM notes 
        JOIN notes_fts ON notes.id = notes_fts.rowid 
        WHERE notes_fts MATCH ? 
        ORDER BY rank
      ''', ['"$sanitizedQuery"']);
    } catch (e) {
      debugPrint("Error loading search results: $e");
      return [];
    }
  }
}
