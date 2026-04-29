import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class FileHelper {
  static final FileHelper _instance = FileHelper._internal();
  FileHelper._internal();
  factory FileHelper() => _instance;

  Future<Directory> _getNotesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final notesDir = Directory(join(dir.path, 'notes'));

    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    return notesDir;
  }

  String generateId() =>
      'note_${DateTime.now().millisecondsSinceEpoch}';

  Future<void> saveNote(String id, String title, String content) async {
    final notesDir = await _getNotesDir();
    final noteDir = Directory(join(notesDir.path, id));

    if (!await noteDir.exists()) {
      await noteDir.create(recursive: true);
    }

    final file = File(join(noteDir.path, 'content.txt'));
    await file.writeAsString('$title\n$content');
  }

  Future<Note?> readNote(String id) async {
    final notesDir = await _getNotesDir();
    final file = File(join(notesDir.path, id, 'content.txt'));

    if (!await file.exists()) return null;

    final raw = await file.readAsString();
    final lines = raw.split('\n');

    int imageCount = 0;
    for (int i = 1; i <= 3; i++) {
      final img = File(join(notesDir.path, id, 'image_$i.jpg'));
      if (await img.exists()) imageCount++;
    }

    return Note(
      id: id,
      title: lines.first,
      content: lines.length > 1 ? lines.sublist(1).join('\n') : '',
      imageCount: imageCount,
    );
  }

  Future<List<Note>> getAllNotes() async {
    final notesDir = await _getNotesDir();
    if (!await notesDir.exists()) return [];

    List<Note> notes = [];

    await for (final entity in notesDir.list()) {
      if (entity is Directory) {
        final id = entity.path.split(Platform.pathSeparator).last;
        final note = await readNote(id);
        if (note != null) notes.add(note);
      }
    }

    notes.sort((a, b) => b.id.compareTo(a.id));
    return notes;
  }

  Future<void> saveNoteImage(
      String id, int index, String sourcePath) async {
    final notesDir = await _getNotesDir();
    final file = File(sourcePath);
    final bytes = await file.readAsBytes();

    final imageFile =
    File(join(notesDir.path, id, 'image_$index.jpg'));

    await imageFile.writeAsBytes(bytes);
  }

  Future<void> deleteNoteImage(String id, int index) async {
    final notesDir = await _getNotesDir();
    final file =
    File(join(notesDir.path, id, 'image_$index.jpg'));

    if (await file.exists()) await file.delete();
  }

  Future<List<File>> getImages(String id) async {
    final notesDir = await _getNotesDir();
    List<File> images = [];

    for (int i = 1; i <= 3; i++) {
      final file =
      File(join(notesDir.path, id, 'image_$i.jpg'));
      if (await file.exists()) images.add(file);
    }
    return images;
  }

  Future<void> deleteNote(String id) async {
    final notesDir = await _getNotesDir();
    final dir = Directory(join(notesDir.path, id));

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}