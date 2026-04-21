import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? "anonymous";

  Future<void> saveExpense(ExpenseModel expense) async {
    final data = expense.toMap();
    data['userId'] = _uid; 
    await _db.collection('expenses').add(data);
  }

  Stream<List<ExpenseModel>> getExpensesByRange(DateTime start, DateTime end) {
    return _db.collection('expenses')
        .where('userId', isEqualTo: _uid) 
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ExpenseModel.fromMap(doc.data(), doc.id)).toList());
  }
}