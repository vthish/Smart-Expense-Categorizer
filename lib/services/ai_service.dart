import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = "https://venu17-smart-expense-ai.hf.space";

  static Future<Map<String, dynamic>?> predict(String text) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Prediction failed: $e");
    }
    return null;
  }

  static Future<void> teachAI(String sentence, String category) async {
    try {
      await http.post(
        Uri.parse("$_baseUrl/learn"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sentence": sentence,
          "category": category,
        }),
      );
    } catch (e) {
      print("Self-learning update failed: $e");
    }
  }
}