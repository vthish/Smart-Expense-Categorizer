import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseService _db = FirebaseService();
  
  String _category = "Other";
  double _amount = 0.0;
  bool _isAnalyzing = false;
  
  final List<String> _allCategories = [
    "Food", "Transport", "Utilities", "Entertainment", "Health", "Shopping", "Education", "Personal Care", "Other"
  ];

  void _handleInput(String val) async {
    if (val.isEmpty) return;
    setState(() => _isAnalyzing = true);
    final res = await AIService.predict(val);
    setState(() {
      _amount = res['amount'];
      _category = res['category'];
      _isAnalyzing = false;
    });
  }

  void _saveAndLearn() async {
    if (_controller.text.isEmpty) return;
    
    final expense = ExpenseModel(
      sentence: _controller.text,
      amount: _amount,
      category: _category,
      date: DateTime.now(),
    );

    await _db.saveExpense(expense); // Save to Firestore
    await AIService.triggerLearning(); // Tell Backend to retrain

    _controller.clear();
    setState(() { _category = "Other"; _amount = 0.0; });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved! AI learning in progress...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Smart Expense"), backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)], begin: Alignment.topLeft)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              child: TextField(
                controller: _controller,
                onChanged: _handleInput,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "What's the expense?", hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 20),
            GlassContainer(
              child: _isAnalyzing 
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                    children: [
                      Text("Amount: Rs. $_amount", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: _category,
                        dropdownColor: const Color(0xFF1E293B),
                        items: _allCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      )
                    ],
                  ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _saveAndLearn,
              child: const Text("Confirm & Learn"),
            )
          ],
        ),
      ),
    );
  }
}