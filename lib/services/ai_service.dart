import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIService {
  static const String _baseUrl = "https://venu17-smart-expense-ai.hf.space";

  static Future<Map<String, dynamic>?> predict(String text) async {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    // 1. Personalized Lookup: Check if user has entered this exact sentence before
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
          debugPrint("Personalized pattern recognized locally.");
          return {
            'category': data['category'],
            'amount': data['amount'],
            'source': 'local_history'
          };
        }
      } catch (e) {
        debugPrint("Local history lookup failed: $e");
      }
    }

    // 2. General AI Fallback: Call the Hugging Face model if no local history found
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
      debugPrint("API Prediction failed: $e");
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
      debugPrint("Global self-learning update failed: $e");
    }
  }
}