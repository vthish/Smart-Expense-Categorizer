import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class FirebaseService {
  final CollectionReference _expensesCollection = 
      FirebaseFirestore.instance.collection('expenses');
  
  final CollectionReference _learningCollection = 
      FirebaseFirestore.instance.collection('learning_data');

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      // Saving the actual expense
      await _expensesCollection.add(expense.toMap());
      
      // Auto-learning: Store the sentence and its category for future training
      await _learningCollection.add({
        'sentence': expense.sentence,
        'category': expense.category,
        'verified': true,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving to Firebase: $e");
    }
  }

  Stream<List<ExpenseModel>> getExpenses() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}