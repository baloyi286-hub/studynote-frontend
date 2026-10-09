import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'data/studynote_api.dart';

void main() => runApp(const StudyNoteApp());

class StudyNoteApp extends StatelessWidget {
  const StudyNoteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'StudyNote AI',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const StudyHome(),
  );
}

class StudyHome extends StatefulWidget {
  const StudyHome({super.key});

  @override
  State<StudyHome> createState() => _StudyHomeState();
}

class _StudyHomeState extends State<StudyHome> {
  final _api = StudyNoteApi();
  final _notes = TextEditingController();
  bool _busy = false;
  String? _error;
  List<dynamic> _questions = [];

  Future<void> _scan() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image, withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    if (file.bytes == null) {
      setState(() => _error = 'Unable to read selected image');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final text = await _api.ocr(file.bytes!, file.name);
      if (mounted) setState(() => _notes.text = text);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _generate() async {
    if (_notes.text.trim().length < 20) {
      setState(() => _error = 'Enter at least 20 characters of notes');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final result = await _api.questions(_notes.text);
      if (mounted) setState(() => _questions = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() { _notes.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('StudyNote AI')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      FilledButton.icon(
        onPressed: _busy ? null : _scan,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Upload handwritten notes'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _notes,
        maxLines: 12,
        decoration: const InputDecoration(
          labelText: 'Editable notes', border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _busy ? null : _generate,
        child: const Text('Create Study Pack'),
      ),
      if (_busy) const LinearProgressIndicator(),
      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
      const SizedBox(height: 16),
      Text('Questions (${_questions.length})',
        style: Theme.of(context).textTheme.titleLarge),
      for (final item in _questions)
        Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(const JsonEncoder.withIndent('  ').convert(item)),
        )),
    ]),
  );
}
