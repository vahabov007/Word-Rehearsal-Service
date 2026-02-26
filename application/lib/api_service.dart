import 'dart:convert'; // Required for json.decode and json.encode
import 'package:http/http.dart' as http;

class ApiService {
  // NOTE: Use your actual IP address if testing on a real phone
  static const String baseUrl =
    "http://192.168.101.3:8080/api/v1/words";

  static Future<int> getDueCount() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/count-due'));
      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      return 0;
    } catch (e) {
      print("Connection Error: $e");
      return 0;
    }
  }

  static Future<List<dynamic>> getRehearsalWords() async {
    try {
      // Fetches random words that are due AND marked 'is_ready' by Java
      final response = await http.get(Uri.parse('$baseUrl/rehearse?page=0&size=10'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['content'] ?? []; 
      }
      return [];
    } catch (e) {
      print("Error fetching words: $e");
      return [];
    }
  }

  static Future<void> submitGrade(int wordId, int grade) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$wordId/grade'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'grade': grade}),
      );
      if (response.statusCode != 200) {
        print("Backend failed to save grade: ${response.statusCode}");
      }
    } catch (e) {
      print("Error submitting grade: $e");
    }
  }
}