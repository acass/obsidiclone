import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/app_state.dart';

class ExportService {

  static Future<void> exportAndZipNotes(AppState appState) async {
    final notes = appState.notes;
    
    final exportData = {
      "id": _generateUuid(),
      "title": "Notes Collection",
      "type": "Note",
      "topics": notes.map((note) => {
        "id": note.id,
        "title": note.title,
        "content": note.content,
        "images": <String>[],
        "videos": <String>[],
        "links": <String>[],
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    
    final archive = Archive();
    final file = ArchiveFile('notes_collection/notes_collection.json', jsonString.length, utf8.encode(jsonString));
    archive.addFile(file);
    
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    
    if (zipData != null) {
      _downloadZip(Uint8List.fromList(zipData), 'notes_collection.zip');
    }
  }

  static void _downloadZip(Uint8List zipData, String fileName) {
    final blob = html.Blob([zipData]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  static String _generateUuid() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        .replaceAllMapped(RegExp(r'[xy]'), (match) {
      final r = (random + (random * 16).floor()) % 16;
      final v = match.group(0) == 'x' ? r : (r & 0x3 | 0x8);
      return v.toRadixString(16);
    });
  }
}