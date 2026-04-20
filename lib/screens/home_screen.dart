import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';
import '../models/expense_model.dart';
import '../widgets/glass_container.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseService _db = FirebaseService();
  Timer? _debounce;
  
  String _category = "Detecting...";
  double _amount = 0.0;
  bool _isAnalyzing = false;
  int _currentIndex = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onInputChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (val.trim().isEmpty) {
      setState(() { _amount = 0.0; _category = "Detecting..."; });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isAnalyzing = true);
      final result = await AIService.predict(val);
      if (result != null && mounted) {
        setState(() {
          _amount = (result['amount'] as num).toDouble();
          _category = result['category'].toString();
          _isAnalyzing = false;
        });
      } else {
        if (mounted) setState(() => _isAnalyzing = false);
      }
    });
  }

  IconData _getIcon(String category) {
    switch (category) {
      case "Food": return Icons.restaurant_outlined;
      case "Transport": return Icons.directions_bus_outlined;
      case "Health": return Icons.health_and_safety_outlined;
      case "Shopping": return Icons.shopping_bag_outlined;
      case "Utilities": return Icons.lightbulb_outlined;
      case "Education": return Icons.school_outlined;
      case "Finance": return Icons.savings_outlined;
      default: return Icons.category_outlined;
    }
  }

  Future<void> _confirmExpense() async {
    if (_controller.text.isEmpty || _amount <= 0) return;

    final String sentence = _controller.text;
    final String category = _category;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _db.saveExpense(ExpenseModel(
        sentence: sentence,
        amount: _amount,
        category: category,
        date: DateTime.now(),
      ));

      await AIService.teachAI(sentence, category);

      if (mounted) {
        Navigator.pop(context);
        _controller.clear();
        setState(() { _amount = 0.0; _category = "Detecting..."; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense Logged & AI Updated!")),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      bottomNavigationBar: _buildBottomNav(),
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: _buildGlow(Colors.blueAccent.withValues(alpha: 0.15))),
          Positioned(bottom: -150, right: -100, child: _buildGlow(Colors.indigoAccent.withValues(alpha: 0.1))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildMainHeroCard(),
                  const SizedBox(height: 30),
                  _buildSectionHeader(),
                  Expanded(child: _buildTransactionList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0F172A),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white24,
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
        } else {
          setState(() => _currentIndex = index);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Analytics"),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, Venusha!", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
            const Text("Smart Tracker", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          child: const Icon(Icons.person_outline, color: Colors.white70, size: 18),
        )
      ],
    );
  }

  Widget _buildMainHeroCard() {
    return GlassContainer(
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: _onInputChanged,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: "Enter expense (e.g. 200 for tea)",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.add_circle_outline_rounded, color: Colors.blueAccent),
              suffixIcon: _isAnalyzing 
                ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                : null,
            ),
          ),
          const Divider(color: Colors.white10, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric("LKR ${_amount.toInt()}", "ESTIMATED AMOUNT"),
              _buildMetric(_category, "AI CATEGORY"),
            ],
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: _confirmExpense,
            child: Container(
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Colors.blueAccent, Color(0xFF3B82F6)]),
              ),
              child: const Center(child: Text("Confirm Expense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetric(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("RECENT ACTIVITY", 
          style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Colors.blueAccent, fontSize: 12))),
      ],
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<List<ExpenseModel>>(
      stream: _db.getExpensesByRange(DateTime.now().subtract(const Duration(days: 30)), DateTime.now()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        return list.isEmpty 
          ? _buildEmptyState()
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemBuilder: (context, index) => _buildTransactionItem(list[index]),
            );
      },
    );
  }

  Widget _buildTransactionItem(ExpenseModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.03),
            child: Icon(_getIcon(item.category), color: Colors.white60, size: 20),
          ),
          title: Text(item.sentence, style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text(item.category, style: const TextStyle(color: Colors.white24, fontSize: 12)),
          trailing: Text("- Rs. ${item.amount.toInt()}", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, color: Colors.white10, size: 60),
          const SizedBox(height: 15),
          const Text("No transactions yet", style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 400, height: 400,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)]),
    );
  }
}