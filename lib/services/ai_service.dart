import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = "http://192.168.8.177:8000";

  static Future<Map<String, dynamic>> predict(String text) async {
    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"category": "Other", "amount": 0.0};
    }
  }

  static Future<void> triggerLearning() async {
    try {
      await http.post(Uri.parse("$_baseUrl/retrain"));
    } catch (e) {
      print("Retrain trigger failed");
    }
  }
}