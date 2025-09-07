import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class NotesStorage {
  static const String _notesDirectoryName = 'notes';

  Future<Directory> _getNotesDirectory() async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDocumentsDir.path}/$_notesDirectoryName');
    
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    
    return notesDir;
  }

  Future<String> _getNoteFilePath(String noteId) async {
    final notesDir = await _getNotesDirectory();
    return '${notesDir.path}/$noteId.json';
  }

  Future<void> saveNote(Note note) async {
    try {
      final filePath = await _getNoteFilePath(note.id);
      final file = File(filePath);
      final jsonString = jsonEncode(note.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      if (kDebugMode) print('Error saving note ${note.id}: $e');
      rethrow;
    }
  }

  Future<List<Note>> loadAllNotes() async {
    try {
      final notesDir = await _getNotesDirectory();
      final noteFiles = notesDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      final notes = <Note>[];
      
      for (final file in noteFiles) {
        try {
          final jsonString = await file.readAsString();
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          final note = Note.fromJson(jsonMap);
          notes.add(note);
        } catch (e) {
          if (kDebugMode) print('Error loading note from ${file.path}: $e');
        }
      }

      notes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
      
      return notes;
    } catch (e) {
      if (kDebugMode) print('Error loading notes: $e');
      return [];
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final filePath = await _getNoteFilePath(noteId);
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) print('Error deleting note $noteId: $e');
      rethrow;
    }
  }

  Future<bool> noteExists(String noteId) async {
    try {
      final filePath = await _getNoteFilePath(noteId);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}