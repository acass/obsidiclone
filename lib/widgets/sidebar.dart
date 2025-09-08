import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/note.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final TextEditingController _noteNameController = TextEditingController();
  final TextEditingController _titleEditController = TextEditingController();
  String? _editingNoteId;

  @override
  void dispose() {
    _noteNameController.dispose();
    _titleEditController.dispose();
    super.dispose();
  }

  void _startEditingTitle(Note note) {
    setState(() {
      _editingNoteId = note.id;
      _titleEditController.text = note.title;
    });
  }

  void _cancelEditingTitle() {
    setState(() {
      _editingNoteId = null;
      _titleEditController.clear();
    });
  }

  void _saveTitle(AppState appState, Note note) {
    final newTitle = _titleEditController.text.trim();
    if (newTitle.isNotEmpty && newTitle != note.title) {
      appState.updateNoteTitle(note.id, newTitle);
    }
    _cancelEditingTitle();
  }

  void _showDeleteConfirmation(BuildContext context, AppState appState, Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Delete Note',
            style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
          ),
          content: Text(
            'Are you sure you want to delete "${note.title}"?',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ),
            TextButton(
              onPressed: () {
                appState.deleteNote(note.id);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, appState),
              _buildNoteCreation(context, appState),
              Expanded(
                child: _buildNoteList(context, appState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PLAYGROUND',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          GestureDetector(
            onTap: () => appState.startCreatingNote(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCreation(BuildContext context, AppState appState) {
    if (!appState.isCreatingNote) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
              ),
              child: TextField(
                controller: _noteNameController,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Note name',
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                ),
                onChanged: (value) => appState.setNewNoteName(value),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    appState.createNote();
                    _noteNameController.clear();
                  }
                },
                autofocus: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (appState.newNoteName.isNotEmpty) {
                appState.createNote();
                _noteNameController.clear();
              }
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              appState.cancelCreatingNote();
              _noteNameController.clear();
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteList(BuildContext context, AppState appState) {
    return ListView.builder(
      itemCount: appState.notes.length,
      itemBuilder: (context, index) {
        final note = appState.notes[index];
        final isSelected = appState.selectedNote?.id == note.id;
        
        return GestureDetector(
          onTap: () => appState.selectNote(note),
          onDoubleTap: () => _startEditingTitle(note),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: _editingNoteId == note.id ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1) : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  size: 16,
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _editingNoteId == note.id
                    ? Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 28,
                              child: TextField(
                                controller: _titleEditController,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _saveTitle(appState, note),
                                autofocus: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _saveTitle(appState, note),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _cancelEditingTitle,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        note.title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                if (_editingNoteId != note.id)
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(context, appState, note),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: isSelected ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}