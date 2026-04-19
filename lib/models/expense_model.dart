import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String? id;
  final String sentence;
  final double amount;
  final String category;
  final DateTime date;

  ExpenseModel({
    this.id,
    required this.sentence,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'sentence': sentence,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      sentence: map['sentence'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? 'Other',
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}