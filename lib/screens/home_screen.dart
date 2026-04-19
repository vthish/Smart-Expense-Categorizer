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
    setState(() => _isAnalyzing = true);
    final res = await AIService.predictExpense(val);
    setState(() {
      _amount = res['amount'];
      _category = res['category'];
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Smart Expense"), backgroundColor: Colors.transparent),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft, end: Alignment.bottomRight
          )
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              child: TextField(
                controller: _controller,
                onChanged: _analyze,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "What did you spend today?",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GlassContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat("Amount", "Rs. $_amount"),
                  _stat("Category", _category),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _db.saveExpense(ExpenseModel(
                sentence: _controller.text,
                amount: _amount,
                category: _category,
                date: DateTime.now()
              )),
              child: const Text("Confirm & Learn"),
            )
          ],
        ),
      ),
    );
  }

  Widget _stat(String t, String v) => Column(children: [
    Text(t, style: const TextStyle(color: Colors.white60)),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
  ]);
}