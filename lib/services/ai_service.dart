import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiEndpoint = "http://192.168.8.177:8000/predict";

  static Future<Map<String, dynamic>> predictExpense(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        body: jsonEncode({"text": text}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return _localFallback(text);
    }
    return _localFallback(text);
  }

  static Map<String, dynamic> _localFallback(String text) {
    double amount = 0;
    RegExp(r'\d+').allMatches(text).forEach((m) => amount = double.parse(m.group(0)!));
    
    String category = "Other";
    if (text.contains("bus") || text.contains("බස්")) category = "Transport";
    if (text.contains("food") || text.contains("කෑම")) category = "Food";
    
    return {"amount": amount, "category": category};
  }
}