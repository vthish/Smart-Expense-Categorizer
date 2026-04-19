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

  void _analyze(String val) async {
    if (val.isEmpty) {
      setState(() {
        _amount = 0.0;
        _category = "Detecting...";
      });
      return;
    }

    setState(() => _isAnalyzing = true);

    // AI Prediction call
    final res = await AIService.predictExpense(val);

    setState(() {
      _amount = res['amount'];
      _category = res['category'];
      _isAnalyzing = false; // Loading finished
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Smart Expense", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input Section
            GlassContainer(
              child: TextField(
                controller: _controller,
                onChanged: _analyze,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "What did you spend today?",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results Section with Loading Indicator
            GlassContainer(
              child: _isAnalyzing
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat("Amount", "Rs. ${_amount.toStringAsFixed(0)}"),
                        _stat("Category", _category),
                      ],
                    ),
            ),
            const SizedBox(height: 30),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Colors.white24),
                ),
                onPressed: () async {
                  if (_controller.text.isNotEmpty) {
                    await _db.saveExpense(ExpenseModel(
                      sentence: _controller.text,
                      amount: _amount,
                      category: _category,
                      date: DateTime.now(),
                    ));
                    _controller.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Saved & Learning Process Started!")),
                    );
                  }
                },
                child: const Text("Confirm & Learn", style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String value) => Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      );
}