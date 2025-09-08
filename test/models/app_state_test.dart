import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_obsidiclone/models/app_state.dart';
import 'package:flutter_obsidiclone/models/note.dart';
import 'package:flutter_obsidiclone/models/app_settings.dart';
import 'package:flutter_obsidiclone/services/notes_storage.dart';
import 'package:flutter_obsidiclone/services/settings_storage.dart';

// Manual mock for NotesStorage
class MockNotesStorage implements NotesStorage {
  List<Note> notes = [];

  @override
  Future<void> saveNote(Note note) async {
    notes.removeWhere((n) => n.id == note.id);
    notes.add(note);
  }

  @override
  Future<List<Note>> loadAllNotes() async {
    return notes;
  }

  @override
  Future<void> deleteNote(String noteId) async {
    notes.removeWhere((n) => n.id == noteId);
  }


  @override
  Future<bool> noteExists(String noteId) async {
    return notes.any((n) => n.id == noteId);
  }
}

// Manual mock for SettingsStorage
class MockSettingsStorage implements SettingsStorage {
  AppSettings? settings;

  @override
  Future<void> saveSettings(AppSettings newSettings) async {
    settings = newSettings;
  }

  @override
  Future<AppSettings?> loadSettings() async {
    return settings;
  }

  @override
  Future<void> deleteSettings() async {
    settings = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState', () {
    late AppState appState;
    late MockNotesStorage mockNotesStorage;
    late MockSettingsStorage mockSettingsStorage;

    setUp(() {
      mockNotesStorage = MockNotesStorage();
      mockSettingsStorage = MockSettingsStorage();
      appState = AppState(
        notesStorage: mockNotesStorage,
        settingsStorage: mockSettingsStorage,
      );
    });

    test('Initial values are correct', () {
      expect(appState.notes, isEmpty);
      expect(appState.selectedNote, isNull);
      expect(appState.currentView, AppView.editor);
      expect(appState.isCreatingNote, isFalse);
      expect(appState.newNoteName, isEmpty);
      expect(appState.appSettings, isA<AppSettings>());
    });

    test('addNote adds a note and saves it', () async {
      final note = Note(id: '1', title: 'Test', content: 'Test content');
      appState.addNote(note);
      expect(appState.notes, contains(note));
      expect(await mockNotesStorage.noteExists(note.id), isTrue);
    });

    test('deleteNote removes a note and deletes it from storage', () async {
      final note = Note(id: '1', title: 'Test', content: 'Test content');
      appState.addNote(note);
      appState.deleteNote('1');
      expect(appState.notes, isEmpty);
      expect(await mockNotesStorage.noteExists('1'), isFalse);
    });

    test('selectNote updates the selected note', () {
      final note = Note(id: '1', title: 'Test', content: 'Test content');
      appState.addNote(note);
      appState.selectNote(note);
      expect(appState.selectedNote, note);
    });

    test('updateNoteContent updates note content', () {
      final note = Note(id: '1', title: 'Test', content: '[{"insert":"Initial content\\n"}]');
      appState.addNote(note);
      appState.updateNoteContent('1', '[{"insert":"New content\\n"}]');
      expect(appState.notes.first.content, '[{"insert":"New content\\n"}]');
    });

    test('updateNoteTitle updates note title', () {
      final note = Note(id: '1', title: 'Initial Title', content: 'Test content');
      appState.addNote(note);
      appState.updateNoteTitle('1', 'New Title');
      expect(appState.notes.first.title, 'New Title');
    });

    test('setView changes the current view', () {
      appState.setView(AppView.graphView);
      expect(appState.currentView, AppView.graphView);
    });

    test('createNote creates a new note', () {
      appState.startCreatingNote();
      appState.setNewNoteName('New Note from Test');
      appState.createNote();
      expect(appState.notes.length, 1);
      expect(appState.notes.first.title, 'New Note from Test');
      expect(appState.isCreatingNote, isFalse);
    });
  });
}
