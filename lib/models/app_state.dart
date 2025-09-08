import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'note.dart';
import 'app_settings.dart';
import '../services/notes_storage.dart';
import '../services/settings_storage.dart';

enum AppView {
  editor,
  graphView,
  settings,
}

class AppState extends ChangeNotifier {
  late final NotesStorage _notesStorage;
  late final SettingsStorage _settingsStorage;

  AppState({NotesStorage? notesStorage, SettingsStorage? settingsStorage}) {
    _notesStorage = notesStorage ?? NotesStorage();
    _settingsStorage = settingsStorage ?? SettingsStorage();
  }

  List<Note> _notes = [];
  Note? _selectedNote;
  AppView _currentView = AppView.editor;
  bool _isCreatingNote = false;
  String _newNoteName = '';
  Timer? _saveTimer;
  AppSettings _appSettings = AppSettings();

  List<Note> get notes => _notes;
  Note? get selectedNote => _selectedNote;
  AppView get currentView => _currentView;
  bool get isCreatingNote => _isCreatingNote;
  String get newNoteName => _newNoteName;
  AppSettings get appSettings => _appSettings;

  void addNote(Note note) {
    _notes.add(note);
    _saveNote(note);
    notifyListeners();
  }

  void deleteNote(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
    if (_selectedNote?.id == noteId) {
      _selectedNote = null;
    }
    _deleteNoteFromStorage(noteId);
    notifyListeners();
  }

  void selectNote(Note? note) {
    // Don't switch if it's the same note
    if (_selectedNote?.id == note?.id) {
      return;
    }
    
    // Save the currently selected note before switching
    if (_selectedNote != null) {
      // Cancel any pending debounced saves
      _saveTimer?.cancel();
      
      // Force immediate save to prevent race conditions
      _saveNote(_selectedNote!);
    }
    
    _selectedNote = note;
    notifyListeners();
  }

  void clearSelectedNote() {
    _selectedNote = null;
    notifyListeners();
  }

  void updateNoteContent(String noteId, String content) {
    // Find the note and verify it exists
    final noteIndex = _notes.indexWhere((n) => n.id == noteId);
    if (noteIndex == -1) {
      if (kDebugMode) print('Warning: Attempted to update non-existent note: $noteId');
      return;
    }
    
    final note = _notes[noteIndex];
    
    // Only update if content has actually changed and content is valid
    if (note.content != content && content.isNotEmpty) {
      try {
        // Validate that content is valid JSON (since we're storing Delta JSON)
        if (content.startsWith('[') && content.endsWith(']')) {
          // Try to parse as JSON to validate
          jsonDecode(content);
        }
        
        note.updateContent(content, modifiedAt: DateTime.now());
        if (_appSettings.autoSave) {
          _debouncedSave(note);
        }
        notifyListeners();
      } catch (e) {
        if (kDebugMode) print('Invalid content format for note $noteId: $e');
      }
    }
  }

  void updateNoteTitle(String noteId, String title) {
    final note = _notes.firstWhere((n) => n.id == noteId);
    note.updateTitle(title, modifiedAt: DateTime.now());
    _saveNote(note);
    notifyListeners();
  }

  void setView(AppView view) {
    _currentView = view;
    notifyListeners();
  }

  void startCreatingNote() {
    _isCreatingNote = true;
    _newNoteName = '';
    notifyListeners();
  }

  void cancelCreatingNote() {
    _isCreatingNote = false;
    _newNoteName = '';
    notifyListeners();
  }

  void setNewNoteName(String name) {
    _newNoteName = name;
    notifyListeners();
  }

  void createNote() {
    if (_newNoteName.isNotEmpty) {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _newNoteName,
        content: '',
      );
      addNote(note);
      selectNote(note);
      _isCreatingNote = false;
      _newNoteName = '';
      notifyListeners();
    }
  }

  // Settings management methods
  void updateSettings(AppSettings newSettings) {
    _appSettings = newSettings;
    _saveSettings();
    notifyListeners();
  }

  void updateTheme(AppTheme theme) {
    _appSettings.setTheme(theme);
    _saveSettings();
    notifyListeners();
  }

  void updateAutoSave(bool autoSave) {
    _appSettings.setAutoSave(autoSave);
    _saveSettings();
    notifyListeners();
  }

  void updateFontSize(double fontSize) {
    _appSettings.setFontSize(fontSize);
    _saveSettings();
    notifyListeners();
  }

  void updateShowPreview(bool showPreview) {
    _appSettings.setShowPreview(showPreview);
    _saveSettings();
    notifyListeners();
  }

  Future<void> loadPersistedSettings() async {
    try {
      final loadedSettings = await _settingsStorage.loadSettings();
      if (loadedSettings != null) {
        _appSettings = loadedSettings;
      }
    } catch (e) {
      if (kDebugMode) print('Error loading persisted settings: $e');
    }
    notifyListeners();
  }

  void _saveSettings() async {
    try {
      await _settingsStorage.saveSettings(_appSettings);
    } catch (e) {
      if (kDebugMode) print('Error saving settings: $e');
    }
  }

  Future<void> loadPersistedNotes() async {
    try {
      final loadedNotes = await _notesStorage.loadAllNotes();
      
      if (loadedNotes.isEmpty) {
        _loadSampleNotes();
      } else {
        _notes = loadedNotes;
      }
    } catch (e) {
      if (kDebugMode) print('Error loading persisted notes: $e');
      _loadSampleNotes();
    }
    notifyListeners();
  }

  void _loadSampleNotes() {
    final sampleNotes = [
      Note(
        id: '1',
        title: 'Welcome to ObsidiClone',
        content: '''Welcome to your note-taking app! This is a sample note to get you started.

Your notes will automatically save as you type, so you never have to worry about losing your work.

Try creating a new note using the + button in the sidebar.''',
      ),
      Note(
        id: '2',
        title: 'Getting Started',
        content: 'This is another sample note. You can edit this content and it will be saved automatically.',
      ),
    ];

    _notes = sampleNotes;
    for (final note in sampleNotes) {
      _saveNote(note);
    }
  }

  void _saveNote(Note note) async {
    try {
      await _notesStorage.saveNote(note);
    } catch (e) {
      if (kDebugMode) print('Error saving note: $e');
    }
  }

  void _deleteNoteFromStorage(String noteId) async {
    try {
      await _notesStorage.deleteNote(noteId);
    } catch (e) {
      if (kDebugMode) print('Error deleting note: $e');
    }
  }

  void _debouncedSave(Note note) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () {
      _saveNote(note);
    });
  }

  void saveNoteDirectly(Note note) {
    _saveNote(note);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}