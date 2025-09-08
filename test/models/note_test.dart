import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_obsidiclone/models/note.dart';

void main() {
  group('Note', () {
    test('Constructor sets default createdAt and modifiedAt', () {
      final note = Note(id: '1', title: 'Test Note', content: 'Test content');
      expect(note.id, '1');
      expect(note.title, 'Test Note');
      expect(note.content, 'Test content');
      expect(note.createdAt, isA<DateTime>());
      expect(note.modifiedAt, isA<DateTime>());
    });

    test('updateContent updates content and modifiedAt', () {
      final note = Note(id: '1', title: 'Test Note', content: 'Initial content');
      final newTime = DateTime.now().add(const Duration(days: 1));
      note.updateContent('New content', modifiedAt: newTime);
      expect(note.content, 'New content');
      expect(note.modifiedAt, newTime);
    });

    test('updateTitle updates title and modifiedAt', () {
      final note = Note(id: '1', title: 'Initial Title', content: 'Test content');
      final newTime = DateTime.now().add(const Duration(days: 1));
      note.updateTitle('New Title', modifiedAt: newTime);
      expect(note.title, 'New Title');
      expect(note.modifiedAt, newTime);
    });

    test('toJson returns a valid map', () {
      final note = Note(id: '1', title: 'Test Note', content: 'Test content');
      final json = note.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test Note');
      expect(json['content'], 'Test content');
      expect(json['createdAt'], note.createdAt.toIso8601String());
      expect(json['modifiedAt'], note.modifiedAt.toIso8601String());
    });

    test('fromJson creates a valid Note object', () {
      final json = {
        'id': '1',
        'title': 'Test Note',
        'content': 'Test content',
        'createdAt': DateTime.now().toIso8601String(),
        'modifiedAt': DateTime.now().toIso8601String(),
      };
      final note = Note.fromJson(json);

      expect(note.id, '1');
      expect(note.title, 'Test Note');
      expect(note.content, 'Test content');
      expect(note.createdAt, DateTime.parse(json['createdAt']!));
      expect(note.modifiedAt, DateTime.parse(json['modifiedAt']!));
    });

    test('copyWith creates a copy with updated values', () {
      final note = Note(id: '1', title: 'Test Note', content: 'Test content');
      final copiedNote = note.copyWith(title: 'New Title', content: 'New content');

      expect(copiedNote.id, '1');
      expect(copiedNote.title, 'New Title');
      expect(copiedNote.content, 'New content');
      expect(copiedNote.createdAt, note.createdAt);
      expect(copiedNote.modifiedAt, note.modifiedAt);
    });
  });
}
