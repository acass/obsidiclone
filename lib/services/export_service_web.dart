import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/app_state.dart';
import '../models/note.dart';

class ExportService {

  static Future<void> exportAndZipNotes(AppState appState) async {
    final notes = appState.notes;
    final archive = Archive();
    
    // Process each note and extract media
    List<Map<String, dynamic>> processedNotes = [];
    
    for (final note in notes) {
      final noteData = await _createNoteExportData(note);
      processedNotes.add(noteData);
    }
    
    // Create main collection JSON
    final exportData = {
      "id": "11111111-1111-4111-9111-111111111111",
      "title": "Notes Collection",
      "type": "Note",
      "topics": processedNotes,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final mainFile = ArchiveFile('notes_collection/notes_collection.json', jsonString.length, utf8.encode(jsonString));
    archive.addFile(mainFile);
    
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

  static List<String> _extractMediaFromDelta(String content) {
    List<String> mediaUrls = [];
    
    try {
      if (content.isEmpty) return mediaUrls;
      
      // Try to parse as Delta JSON
      if (content.startsWith('[') && content.endsWith(']')) {
        final List<dynamic> deltaJson = jsonDecode(content);
        
        for (var op in deltaJson) {
          if (op is Map<String, dynamic> && op['insert'] is Map<String, dynamic>) {
            final insert = op['insert'] as Map<String, dynamic>;
            
            // Check for image embeds
            if (insert.containsKey('image') && insert['image'] is String) {
              mediaUrls.add(insert['image']);
            }
            
            // Check for video embeds  
            if (insert.containsKey('video') && insert['video'] is String) {
              mediaUrls.add(insert['video']);
            }
          }
        }
      }
    } catch (e) {
      // If parsing fails, content is likely plain text, no media to extract
    }
    
    return mediaUrls;
  }

  static Future<Map<String, dynamic>> _createNoteExportData(Note note) async {
    final mediaUrls = _extractMediaFromDelta(note.content);
    
    // For web, we keep the original URLs since we can't easily bundle files
    // Separate images and videos based on URL patterns or file extensions
    List<String> images = [];
    List<String> videos = [];
    
    for (String url in mediaUrls) {
      // Basic detection - can be enhanced
      if (url.contains('image') || url.contains('.jpg') || url.contains('.png') ||
          url.contains('.gif') || url.contains('.webp') || url.contains('.bmp')) {
        images.add(url);
      } else if (url.contains('video') || url.contains('.mp4') || url.contains('.webm') ||
                 url.contains('.ogg') || url.contains('.avi') || url.contains('.mov')) {
        videos.add(url);
      } else {
        // Default to image if unclear
        images.add(url);
      }
    }
    
    return {
      "id": note.id,
      "title": note.title,
      "content": note.content,
      "images": images,
      "videos": videos,
      "links": <String>[],
    };
  }

}