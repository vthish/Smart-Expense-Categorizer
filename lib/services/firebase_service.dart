import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";

  // Save expense with user ID
  Future<void> saveExpense(ExpenseModel expense) async {
    final data = expense.toMap();
    data['userId'] = _uid; // Attach current user's ID

    await _db.collection('expenses').add(data);
    
    // Save to learning data with userId for personalized AI patterns later
    await _db.collection('learning_data').add({
      'sentence': expense.sentence,
      'category': expense.category,
      'timestamp': FieldValue.serverTimestamp(),
      'is_verified': true,
      'userId': _uid,
    });
  }

  // Get only current user's expenses within a date range
  Stream<List<ExpenseModel>> getExpensesByRange(DateTime start, DateTime end) {
    return _db.collection('expenses')
        .where('userId', isEqualTo: _uid) // Filter by current user
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}