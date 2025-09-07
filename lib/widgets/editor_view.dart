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

  void _saveCurrentContent(String noteId) {
    final delta = _controller.document.toDelta();
    final deltaJson = delta.toJson();
    // Update the note content directly without triggering state change
    final appState = context.read<AppState>();
    final note = appState.notes.firstWhere((n) => n.id == noteId);
    note.updateContent(jsonEncode(deltaJson));
    // Save to storage asynchronously without state notification
    appState.saveNoteDirectly(note);
  }

  @override
  void didUpdateWidget(EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      // Save the old note content after the current build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _saveCurrentContent(oldWidget.note.id);
      });
      _controller.removeListener(_onContentChanged);
      _controller.dispose();
      _initializeController();
    }
  }

  @override
  void dispose() {
    // Force save current content before disposing
    try {
      _saveCurrentContent(widget.note.id);
    } catch (e) {
      // Ignore errors during disposal
    }
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
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    context.read<AppState>().clearSelectedNote();
                  },
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.edit, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  '${widget.note.title}.md',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
            color: Colors.white70,
            size: 18,
          ),
          tooltipTheme: TooltipThemeData(
            decoration: BoxDecoration(
              color: const Color(0xFF404040),
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(color: Colors.white),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: const Color(0xFF2a2a2a),
            textStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          dividerColor: const Color(0xFF404040),
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
            showListNumbers: true,
            showListBullets: true,
            showListCheck: true,
            showCodeBlock: false,
            showIndent: true,
            showLink: true,
            showUndo: true,
            showRedo: true,
            showDirection: false,
            showSearchButton: false,
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
                  color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
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
            ],
          ),
        );
      },
    );
  }
}