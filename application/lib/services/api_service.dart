import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/vocab_word.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<int> getDueCount() async {
    final uri = Uri.parse('$baseUrl/count-due');
    final res = await http.get(uri);
    if (res.statusCode == 200) return int.parse(res.body);
    throw Exception("Failed to load count: ${res.statusCode}");
  }

  static Future<List<VocabWord>> getRehearsalWords({int page = 0, int size = 10}) async {
    final uri = Uri.parse('$baseUrl/rehearse?page=$page&size=$size');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Failed to load rehearsal words: ${res.statusCode}");
    }
    final Map<String, dynamic> data = json.decode(res.body);
    final List content = (data['content'] as List?) ?? [];
    return content.map((e) => VocabWord.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<VocabWord>> searchWords(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final uri = Uri.parse('$baseUrl/search?query=${Uri.encodeQueryComponent(q)}');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Search failed: ${res.statusCode}");
    }
    final List data = json.decode(res.body);
    return data.map((e) => VocabWord.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> submitGrade(int wordId, int grade) async {
    final uri = Uri.parse('$baseUrl/$wordId/grade');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'grade': grade}),
    );
    if (res.statusCode != 200) {
      throw Exception("Submit grade failed: ${res.statusCode}");
    }
  }
}