import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/app_state.dart';
import '../models/note.dart';

class ExportService {
  static const String _mediaDirectoryName = 'media';
  
  static Future<Directory> _getAppMediaDirectory() async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDocumentsDir.path}/$_mediaDirectoryName');
    
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    
    return mediaDir;
  }
  
  static Future<void> exportAndZipNotes(AppState appState) async {
    try {
      final notes = appState.notes;
      final archive = Archive();
      
      // Create temporary directory for processing media files
      final tempDir = Directory.systemTemp.createTempSync('flutter_obsidiclone_export');
      final mediaDir = Directory(path.join(tempDir.path, 'media'));
      await mediaDir.create(recursive: true);
      
      // Process each note and extract media
      List<Map<String, dynamic>> processedNotes = [];
      Set<String> copiedMediaFiles = {}; // Track copied files to avoid duplicates
      
      for (final note in notes) {
        final noteData = await _createNoteExportData(note);
        
        // Update media references to point to bundled files
        List<String> updatedImages = [];
        List<String> updatedVideos = [];
        
        // Process images
        for (String imageUrl in noteData['images']) {
          final copiedFile = await _copyMediaFile(imageUrl, mediaDir.path);
          if (copiedFile != null) {
            final fileName = path.basename(copiedFile.path);
            updatedImages.add(fileName);
            copiedMediaFiles.add(copiedFile.path);
          } else {
            // Keep original URL if we couldn't copy the file
            updatedImages.add(imageUrl);
          }
        }
        
        // Process videos
        for (String videoUrl in noteData['videos']) {
          final copiedFile = await _copyMediaFile(videoUrl, mediaDir.path);
          if (copiedFile != null) {
            final fileName = path.basename(copiedFile.path);
            updatedVideos.add(fileName);
            copiedMediaFiles.add(copiedFile.path);
          } else {
            // Keep original URL if we couldn't copy the file
            updatedVideos.add(videoUrl);
          }
        }
        
        // Update the note data with new media paths
        noteData['images'] = updatedImages;
        noteData['videos'] = updatedVideos;
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
      
      // Add media files to archive
      for (String mediaFilePath in copiedMediaFiles) {
        final mediaFile = File(mediaFilePath);
        if (await mediaFile.exists()) {
          final mediaBytes = await mediaFile.readAsBytes();
          final relativePath = 'notes_collection/${path.basename(mediaFilePath)}';
          final archiveFile = ArchiveFile(relativePath, mediaBytes.length, mediaBytes);
          archive.addFile(archiveFile);
        }
      }
      
      // Clean up temp directory
      try {
        await tempDir.delete(recursive: true);
      } catch (e) {
        print('Warning: Could not clean up temp directory: $e');
      }
      
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
          print('Exported ${notes.length} notes with ${copiedMediaFiles.length} media files');
        } else {
          print('Export cancelled by user');
        }
      }
    } catch (e) {
      print('Error exporting and zipping notes: $e');
    }
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
    
    // Separate images and videos based on file extension
    List<String> images = [];
    List<String> videos = [];
    
    for (String url in mediaUrls) {
      final extension = path.extension(url).toLowerCase();
      if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(extension)) {
        images.add(url);
      } else if (['.mp4', '.webm', '.ogg', '.avi', '.mov'].contains(extension)) {
        videos.add(url);
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

  static Future<String?> _ensureMediaInAppDirectory(String mediaUrl) async {
    try {
      final appMediaDir = await _getAppMediaDirectory();
      
      // Handle local file paths
      if (mediaUrl.startsWith('/') || mediaUrl.startsWith('file://')) {
        String filePath = mediaUrl.startsWith('file://') 
          ? mediaUrl.substring(7) 
          : mediaUrl;
          
        final sourceFile = File(filePath);
        if (await sourceFile.exists()) {
          final fileName = path.basename(filePath);
          final destFile = File('${appMediaDir.path}/$fileName');
          
          // Check if file already exists in app directory
          if (await destFile.exists()) {
            return destFile.path;
          }
          
          // Try to copy to app's media directory
          try {
            await sourceFile.copy(destFile.path);
            print('Moved media file to app directory: ${destFile.path}');
            return destFile.path;
          } catch (copyError) {
            print('Could not copy $filePath to app directory: $copyError');
            print('Suggestion: Move your media files to Documents or Downloads folder');
            return null;
          }
        }
      }
      
      // Handle base64 data URLs
      if (mediaUrl.startsWith('data:')) {
        final parts = mediaUrl.split(',');
        if (parts.length == 2) {
          final mimeType = parts[0].split(':')[1].split(';')[0];
          final extension = mimeType.split('/')[1];
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
          final destFile = File('${appMediaDir.path}/$fileName');
          
          final bytes = base64Decode(parts[1]);
          await destFile.writeAsBytes(bytes);
          return destFile.path;
        }
      }
      
      // For URLs that are already in the app directory, return as-is
      if (mediaUrl.contains(appMediaDir.path)) {
        return mediaUrl;
      }
      
    } catch (e) {
      print('Error processing media file $mediaUrl: $e');
    }
    
    return null;
  }
  
  static Future<File?> _copyMediaFile(String mediaUrl, String mediaDir) async {
    try {
      // First try to ensure media is in app directory
      final accessiblePath = await _ensureMediaInAppDirectory(mediaUrl);
      
      if (accessiblePath != null) {
        final sourceFile = File(accessiblePath);
        if (await sourceFile.exists()) {
          final fileName = path.basename(accessiblePath);
          final destFile = File(path.join(mediaDir, fileName));
          await destFile.parent.create(recursive: true);
          await sourceFile.copy(destFile.path);
          return destFile;
        }
      }
      
    } catch (e) {
      print('Error copying media file $mediaUrl: $e');
    }
    
    return null;
  }

}