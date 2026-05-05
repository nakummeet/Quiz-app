import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://quiz-backend-sand.vercel.app/api";


  static Future<List<dynamic>> getTests(String topic) async {
    final response = await http.get(
      Uri.parse("$baseUrl/test?topic=$topic"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tests");
    }
  }


  static Future<Map<String, dynamic>> getTestById(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/test/$id"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load test");
    }
  }


  static Future<Map<String, dynamic>> submitAnswers({
    required String testId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/question/submit"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "testId": testId,
        "answers": answers,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Submission failed");
    }
  }
}