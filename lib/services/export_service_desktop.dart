import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import '../models/app_state.dart';

class ExportService {

  static Future<void> exportAndZipNotes(AppState appState) async {
    try {
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
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select folder to save Notes Export',
        );
        
        if (selectedDirectory != null) {
          final zipFile = File('$selectedDirectory/notes_collection.zip');
          await zipFile.writeAsBytes(Uint8List.fromList(zipData));
          print('Notes exported and zipped to: ${zipFile.path}');
        } else {
          print('Export cancelled by user');
        }
      }
    } catch (e) {
      print('Error exporting and zipping notes: $e');
    }
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