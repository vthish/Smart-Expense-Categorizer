import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIService {
  static const String _baseUrl = "https://venu17-smart-expense-ai.hf.space";

  static Future<Map<String, dynamic>?> predict(String text) async {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (uid.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: uid)
            .where('sentence', isEqualTo: text)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data();
          
          double finalAmount = 0.0;
          if (data['amount'] is num) {
            finalAmount = (data['amount'] as num).toDouble();
          } else if (data['amount'] is String) {
            finalAmount = double.tryParse(data['amount']) ?? 0.0;
          }

          return {
            'category': data['category'],
            'amount': finalAmount,
            'source': 'local_history'
          };
        }
      } catch (e) {
        // Ignored
      }
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        double finalAmount = 0.0;
        if (result['amount'] != null) {
          if (result['amount'] is num) {
            finalAmount = (result['amount'] as num).toDouble();
          } else {
            finalAmount = double.tryParse(result['amount'].toString()) ?? 0.0;
          }
        }
        
        result['amount'] = finalAmount;
        return result;
      }
    } catch (e) {
      // Ignored
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
      // Ignored
    }
  }
}