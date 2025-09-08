import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/note.dart';

class EditorView extends StatefulWidget {
  final Note note;

  const EditorView({super.key, required this.note});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Initialize with existing content or empty document
    Document document;
    try {
      if (widget.note.content.isNotEmpty) {
        // Check if content looks like Delta JSON
        if (widget.note.content.startsWith('[') && widget.note.content.endsWith(']')) {
          // Try to parse as Delta JSON
          final List<dynamic> deltaJson = jsonDecode(widget.note.content);
          final delta = Delta.fromJson(deltaJson);
          document = Document.fromDelta(delta);
        } else {
          // Treat as plain text and convert to Delta
          document = Document()..insert(0, widget.note.content);
        }
      } else {
        document = Document();
      }
    } catch (e) {
      // If parsing fails, treat as plain text and convert
      if (widget.note.content.isNotEmpty) {
        document = Document()..insert(0, widget.note.content);
      } else {
        document = Document();
      }
    }

    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Listen for changes and update the note
    _controller.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    final delta = _controller.document.toDelta();
    final deltaJson = delta.toJson();
    // Convert to proper JSON string for storage
    context.read<AppState>().updateNoteContent(widget.note.id, jsonEncode(deltaJson));
  }


  @override
  void didUpdateWidget(EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      // Save the current note's content before switching
      _saveCurrentContent(oldWidget.note.id);
      
      // Remove listener and dispose controller
      _controller.removeListener(_onContentChanged);
      _controller.dispose();
      
      // Initialize controller for the new note
      _initializeController();
    }
  }

  void _saveCurrentContent(String noteId) {
    try {
      final delta = _controller.document.toDelta();
      final deltaJson = delta.toJson();
      final content = jsonEncode(deltaJson);
      
      final appState = context.read<AppState>();
      // Find the note safely
      final noteIndex = appState.notes.indexWhere((n) => n.id == noteId);
      if (noteIndex != -1) {
        final note = appState.notes[noteIndex];
        // Only update if content has changed
        if (note.content != content) {
          note.updateContent(content);
          appState.saveNoteDirectly(note);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error saving current content for note $noteId: $e');
    }
  }

  @override
  void dispose() {
    // Force save current content before disposing
    _saveCurrentContent(widget.note.id);
    
    _controller.removeListener(_onContentChanged);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildToolbar(),
        Expanded(
          child: _buildEditor(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.note.title,
                  style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    context.read<AppState>().clearSelectedNote();
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
            color: isDark ? Colors.white70 : Colors.black54,
            size: 18,
          ),
          tooltipTheme: TooltipThemeData(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF404040) : const Color(0xFFe0e0e0),
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: isDark ? const Color(0xFF2a2a2a) : const Color(0xFFffffff),
            textStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          dividerColor: isDark ? const Color(0xFF404040) : const Color(0xFFe0e0e0),
        ),
        child: QuillSimpleToolbar(
          controller: _controller,
          config: QuillSimpleToolbarConfig(
            toolbarSize: 48,
            multiRowsDisplay: false,
            showDividers: true,
            showFontFamily: false,
            showFontSize: false,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: false,
            showInlineCode: false,
            showColorButton: false,
            showBackgroundColorButton: false,
            showClearFormat: true,
            showAlignmentButtons: false,
            showHeaderStyle: true,
            showListNumbers: false,
            showListBullets: true,
            showListCheck: false,
            showCodeBlock: false,
            showIndent: false,
            showLink: true,
            showUndo: true,
            showRedo: true,
            showDirection: false,
            showSearchButton: false,
            showSubscript: false,
            showSuperscript: false,
            showQuote: false,
            embedButtons: FlutterQuillEmbeds.toolbarButtons(),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.note.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: Theme.of(context).textTheme.copyWith(
                      bodyMedium: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: appState.appSettings.fontSize,
                      ),
                    ),
                  ),
                  child: Focus(
                    focusNode: _focusNode,
                    child: QuillEditor.basic(
                      controller: _controller,
                      config: QuillEditorConfig(
                        placeholder: 'Start typing...',
                        padding: EdgeInsets.zero,
                        autoFocus: false,
                        expands: true,
                        embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}