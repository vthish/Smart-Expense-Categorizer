import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';
import '../models/expense_model.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseService _db = FirebaseService();
  
  String _category = "Detecting...";
  double _amount = 0.0;
  bool _isAnalyzing = false;

  void _onInputChanged(String val) async {
    if (val.trim().isEmpty) {
      setState(() { _amount = 0.0; _category = "Detecting..."; });
      return;
    }
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
  }

  IconData _getIcon(String category) {
    switch (category) {
      case "Food": return Icons.fastfood_outlined;
      case "Transport": return Icons.commute_outlined;
      case "Health": return Icons.health_and_safety_outlined;
      case "Shopping": return Icons.shopping_cart_outlined;
      case "Utilities": return Icons.receipt_long_outlined;
      case "Education": return Icons.menu_book_outlined;
      default: return Icons.api_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(top: -150, left: -100, child: _buildGlow(Colors.blueAccent.withValues(alpha: 0.2))),
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
                  
                  // Main Input & Analysis Card
                  _buildMainHeroCard(),
                  
                  const SizedBox(height: 30),
                  
                  // Transactions Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("RECENT ACTIVITY", 
                        style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Colors.blueAccent, fontSize: 12))),
                    ],
                  ),

                  // Full-width Scrollable History
                  Expanded(
                    child: StreamBuilder<List<ExpenseModel>>(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, Venusha!", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
            const Text("Your Spending", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          child: const Icon(Icons.person_outline, color: Colors.white70),
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
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: "What did you spend on?",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.blueAccent),
              suffixIcon: _isAnalyzing 
                ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                : null,
            ),
          ),
          const Divider(color: Colors.white10, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric("LKR ${_amount.toInt()}", "Amount Detected"),
              _buildMetric(_category, "AI Category"),
            ],
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () async {
              if (_controller.text.isEmpty || _amount <= 0) return;
              await _db.saveExpense(ExpenseModel(
                sentence: _controller.text,
                amount: _amount,
                category: _category,
                date: DateTime.now(),
              ));
              _controller.clear();
              setState(() { _amount = 0.0; _category = "Detecting..."; });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("Confirm Expense", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildMetric(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTransactionItem(ExpenseModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12)),
            child: Icon(_getIcon(item.category), color: Colors.white70, size: 22),
          ),
          title: Text(item.sentence, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Text(item.category, style: const TextStyle(color: Colors.white24, fontSize: 12)),
          trailing: Text("- Rs. ${item.amount.toInt()}", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_outlined, color: Colors.white10, size: 60),
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