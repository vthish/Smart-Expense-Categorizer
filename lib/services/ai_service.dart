import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Updated with your specific local IPv4 address
  static const String _baseUrl = "http://192.168.8.177:8000";

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
      // Print error to terminal for debugging
      print("AI Service Error: $e");
    }
    return null;
  }
}