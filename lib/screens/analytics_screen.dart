import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firebase_service.dart';
import '../widgets/glass_container.dart';
import 'category_detail_screen.dart';

enum DateRange { daily, weekly, monthly, yearly }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseService _db = FirebaseService();
  DateRange _selectedRange = DateRange.monthly;

  final List<Color> _chartColors = [
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.amberAccent,
    Colors.tealAccent,
  ];

  DateTime get _startDate {
    DateTime now = DateTime.now();
    switch (_selectedRange) {
      case DateRange.daily:
        return DateTime(now.year, now.month, now.day);
      case DateRange.weekly:
        return now.subtract(const Duration(days: 7));
      case DateRange.monthly:
        return DateTime(now.year, now.month, 1);
      case DateRange.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  Route _smoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
          ),
        );

        var scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text("ANALYTICS",
            style: TextStyle(fontSize: 14, letterSpacing: 2, color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _db.getExpensesByRange(_startDate, DateTime.now()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final expenses = snapshot.data!;
          final categoryTotals = _aggregateCategoryTotals(expenses);
          final double totalAmount = expenses.fold(0, (sum, e) => sum + e.amount);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildRangeSelector(),
                const SizedBox(height: 20),
                _buildTotalCard(totalAmount),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildChartAndLegend(categoryTotals),
                      const SizedBox(height: 30),
                      ...categoryTotals.entries
                          .map((entry) => _buildCategoryRow(entry.key, entry.value, expenses)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: DateRange.values.map((range) {
        bool isSelected = _selectedRange == range;
        return GestureDetector(
          onTap: () => setState(() => _selectedRange = range),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(range.name.toUpperCase(),
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalCard(double total) {
    return GlassContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("TOTAL EXPENSES",
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
          Text("Rs. ${total.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartAndLegend(Map<String, double> totals) {
    final categories = totals.keys.toList();
    const visibleCount = 5;
    final visibleCats =
        categories.length > visibleCount ? categories.take(visibleCount - 1).toList() : categories;
    final hiddenCats =
        categories.length > visibleCount ? categories.skip(visibleCount - 1).toList() : [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 180,
            child: PieChart(PieChartData(
              sections: _buildSections(totals),
              centerSpaceRadius: 40,
              sectionsSpace: 3,
            )),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...visibleCats.map(
                  (cat) => _legendItem(cat, _chartColors[categories.indexOf(cat) % _chartColors.length])),
              if (hiddenCats.isNotEmpty)
                PopupMenuButton<String>(
                  color: const Color(0xFF0F172A),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("+ More",
                        style: TextStyle(
                            color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  itemBuilder: (context) => hiddenCats
                      .map<PopupMenuEntry<String>>((cat) => PopupMenuItem<String>(
                            value: cat,
                            child: _legendItem(
                                cat, _chartColors[categories.indexOf(cat) % _chartColors.length]),
                          ))
                      .toList(),
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, double amount, List<ExpenseModel> all) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            _smoothRoute(CategoryDetailScreen(
                category: category, expenses: all.where((e) => e.category == category).toList()))),
        child: GlassContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("Rs. ${amount.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _aggregateCategoryTotals(List<ExpenseModel> expenses) {
    Map<String, double> totals = {
      "Food": 0.0,
      "Transport": 0.0,
      "Health": 0.0,
      "Shopping": 0.0,
      "Utilities": 0.0,
      "Education": 0.0,
      "Finance": 0.0
    };
    for (var e in expenses) {
      if (totals.containsKey(e.category)) {
        totals[e.category] = totals[e.category]! + e.amount;
      } else {
        totals[e.category] = e.amount;
      }
    }
    return totals;
  }

  List<PieChartSectionData> _buildSections(Map<String, double> totals) {
    final sortedEntries = totals.entries.toList();
    return sortedEntries.where((e) => e.value > 0).map((entry) {
      final color = _chartColors[sortedEntries.indexOf(entry) % _chartColors.length];
      return PieChartSectionData(color: color, value: entry.value, radius: 18, title: '');
    }).toList();
  }
}