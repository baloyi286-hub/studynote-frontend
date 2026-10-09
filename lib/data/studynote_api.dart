import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StudyNoteApi {
  StudyNoteApi({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = String.fromEnvironment(
    'STUDYNOTE_API_URL',
    defaultValue: 'http://localhost:8000',
  );
  final http.Client _client;

  Future<String> ocr(Uint8List bytes, String filename) async {
    final request = http.MultipartRequest(
      'POST', Uri.parse('$baseUrl/api/v1/ocr'),
    );
    request.files.add(http.MultipartFile.fromBytes(
      'file', bytes, filename: filename,
    ));
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception('OCR failed: ${response.statusCode} ${response.body}');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['text'] as String;
  }

  Future<List<dynamic>> questions(String notes, {int count = 10}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/questions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'notes': notes, 'count': count}),
    );
    if (response.statusCode != 200) {
      throw Exception('Question generation failed: ${response.statusCode} ${response.body}');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['questions'] as List<dynamic>;
  }
}
