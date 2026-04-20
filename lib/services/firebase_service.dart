import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveExpense(ExpenseModel expense) async {
    await _db.collection('expenses').add(expense.toMap());
    
    await _db.collection('learning_data').add({
      'sentence': expense.sentence,
      'category': expense.category,
      'timestamp': FieldValue.serverTimestamp(),
      'is_verified': true,
    });
  }

  Stream<List<ExpenseModel>> getExpensesByRange(DateTime start, DateTime end) {
    return _db.collection('expenses')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}