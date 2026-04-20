import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firebase_service.dart';
import '../widgets/glass_container.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService db = FirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text("SPENDING ANALYTICS", style: TextStyle(fontSize: 14, letterSpacing: 2, color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: db.getExpensesByRange(DateTime.now().subtract(const Duration(days: 30)), DateTime.now()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final expenses = snapshot.data!;
          final categoryTotals = _calculateCategoryTotals(expenses);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: _buildChartSections(categoryTotals),
                      centerSpaceRadius: 50,
                      sectionsSpace: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    children: categoryTotals.entries.map((entry) => _buildLegendItem(entry.key, entry.value)).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List<ExpenseModel> expenses) {
    Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<PieChartSectionData> _buildChartSections(Map<String, double> totals) {
    final colors = [Colors.blueAccent, Colors.purpleAccent, Colors.orangeAccent, Colors.greenAccent, Colors.redAccent, Colors.cyanAccent];
    int index = 0;

    return totals.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '',
        radius: 25,
      );
    }).toList();
  }

  Widget _buildLegendItem(String category, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GlassContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            Text("Rs. ${amount.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}