import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../widgets/glass_container.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String category;
  final List<ExpenseModel> expenses;

  const CategoryDetailScreen({super.key, required this.category, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text(category.toUpperCase(),
            style: const TextStyle(fontSize: 14, letterSpacing: 2, color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: expenses.isEmpty
          ? const Center(child: Text("No expenses found", style: TextStyle(color: Colors.white24)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final item = expenses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: GlassContainer(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.sentence, style: const TextStyle(color: Colors.white, fontSize: 15)),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd | hh:mm a').format(item.date),
                        style: const TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                      trailing: Text("Rs. ${item.amount.toInt()}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}