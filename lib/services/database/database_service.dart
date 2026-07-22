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
  static Database? _database;
  static const int _version = 3;

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
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    // 2. Create FTS4 virtual table for fast full-text search
    await db.execute('''
      CREATE VIRTUAL TABLE notes_fts USING fts4(
        content='notes', 
        title, 
        raw_transcript, 
        summary_json
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
      CREATE TRIGGER notes_ad BEFORE DELETE ON notes BEGIN
        INSERT INTO notes_fts(notes_fts, rowid, title, raw_transcript, summary_json) 
        VALUES ('delete', old.id, old.title, old.raw_transcript, old.summary_json);
      END;
    ''');
    
    await db.execute('''
      CREATE TRIGGER notes_au BEFORE UPDATE ON notes BEGIN
        INSERT INTO notes_fts(notes_fts, rowid, title, raw_transcript, summary_json) 
        VALUES ('delete', old.id, old.title, old.raw_transcript, old.summary_json);
        INSERT INTO notes_fts(rowid, title, raw_transcript, summary_json) 
        VALUES (new.id, new.title, new.raw_transcript, new.summary_json);
      END;
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS notes_fts');
      await db.execute('DROP TRIGGER IF EXISTS notes_ai');
      await db.execute('DROP TRIGGER IF EXISTS notes_ad');
      await db.execute('DROP TRIGGER IF EXISTS notes_au');
      
      await db.execute('''
        CREATE VIRTUAL TABLE notes_fts USING fts4(
          content='notes', 
          title, 
          raw_transcript, 
          summary_json
        )
      ''');
      
      await db.execute('''
        INSERT INTO notes_fts(rowid, title, raw_transcript, summary_json)
        SELECT id, title, raw_transcript, summary_json FROM notes;
      ''');

      await db.execute('''
        CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
          INSERT INTO notes_fts(rowid, title, raw_transcript, summary_json) 
          VALUES (new.id, new.title, new.raw_transcript, new.summary_json);
        END;
      ''');
      
      await db.execute('''
        CREATE TRIGGER notes_ad BEFORE DELETE ON notes BEGIN
          INSERT INTO notes_fts(notes_fts, rowid, title, raw_transcript, summary_json) 
          VALUES ('delete', old.id, old.title, old.raw_transcript, old.summary_json);
        END;
      ''');
      
      await db.execute('''
        CREATE TRIGGER notes_au BEFORE UPDATE ON notes BEGIN
          INSERT INTO notes_fts(notes_fts, rowid, title, raw_transcript, summary_json) 
          VALUES ('delete', old.id, old.title, old.raw_transcript, old.summary_json);
          INSERT INTO notes_fts(rowid, title, raw_transcript, summary_json) 
          VALUES (new.id, new.title, new.raw_transcript, new.summary_json);
        END;
      ''');
    }
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
      // Use MATCH for FTS4 queries, safely wrap the query
      final sanitizedQuery = query.replaceAll('"', '""');
      return await db.rawQuery('''
        SELECT notes.* FROM notes 
        JOIN notes_fts ON notes.id = notes_fts.rowid 
        WHERE notes_fts MATCH ? 
        ORDER BY notes.created_at DESC
      ''', ['"$sanitizedQuery"']);
    } catch (e) {
      debugPrint("Error loading search results: $e");
      return [];
    }
  }

  /// Get all notes ordered by creation date
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      final db = await database;
      return await db.query('notes', orderBy: 'created_at DESC');
    } catch (e) {
      debugPrint('Error getting notes: $e');
      return [];
    }
  }

  /// Delete a note by ID
  Future<int> deleteNote(int id) async {
    try {
      final db = await database;
      return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Error deleting note: $e');
      return 0;
    }
  }

  /// Update a note's fields
  Future<int> updateNote(int id, Map<String, dynamic> values) async {
    try {
      final db = await database;
      return await db.update('notes', values, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Error updating note: $e');
      return 0;
    }
  }

  /// Delete all notes (clear all data)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('notes');
      // Rebuild FTS index
      await db.execute("INSERT INTO notes_fts(notes_fts) VALUES('rebuild')");
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}
