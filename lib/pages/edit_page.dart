import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/file_helper.dart';
import '../models/note.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final helper = FileHelper();
  final titleC = TextEditingController();
  final contentC = TextEditingController();

  List<File> images = [];
  late String id;

  @override
  void initState() {
    super.initState();
    id = widget.note?.id ?? helper.generateId();

    if (widget.note != null) {
      titleC.text = widget.note!.title;
      contentC.text = widget.note!.content;
      loadImages();
    }
  }

  Future<void> loadImages() async {
    final imgs = await helper.getImages(id);
    setState(() => images = imgs);
  }

  Future<void> pickImage() async {
    if (images.length >= 3) return;

    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);

    if (x != null) {
      setState(() => images.add(File(x.path)));
    }
  }

  Future<void> save() async {
    await helper.saveNote(id, titleC.text, contentC.text);

    for (int i = 0; i < images.length; i++) {
      await helper.saveNoteImage(id, i + 1, images[i].path);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Tambahkan catatan',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: save,
            icon: const Icon(Icons.save, color: Colors.orange),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: titleC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Judul',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: contentC,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Isi catatan',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < images.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              images[i],
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() => images.removeAt(i));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  if (images.length < 3)
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white),
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}