import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firebase_service.dart';
import '../services/nlp_processor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  String _detectedCategory = "Waiting...";
  double _detectedAmount = 0.0;
  bool _isLoading = false;

  // Real-time NLP processing logic
  void _processInput(String value) {
    if (value.isEmpty) {
      setState(() {
        _detectedAmount = 0.0;
        _detectedCategory = "Waiting...";
      });
      return;
    }

    final result = NLPProcessor.process(value);
    setState(() {
      _detectedAmount = result['amount'];
      _detectedCategory = result['category'];
    });
  }

  // Save the validated expense to Firebase
  Future<void> _saveData() async {
    if (_controller.text.isEmpty || _detectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid expense sentence")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newExpense = ExpenseModel(
      sentence: _controller.text,
      amount: _detectedAmount,
      category: _detectedCategory,
      date: DateTime.now(),
    );

    try {
      await _firebaseService.addExpense(newExpense);

      if (!mounted) return;

      _controller.clear();
      setState(() {
        _detectedAmount = 0.0;
        _detectedCategory = "Waiting...";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Expense saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Smart Expense",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What did you spend on?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            
            // Modern Styled Input Field
            TextField(
              controller: _controller,
              onChanged: _processInput,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "e.g., 500 for lunch or bus ekata 150",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.auto_fix_high, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue.withOpacity(0.1)),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Dynamic Display Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "PREDICTED DETAILS",
                    style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn("Amount", "Rs. ${_detectedAmount.toStringAsFixed(0)}"),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildInfoColumn("Category", _detectedCategory),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Confirm & Save",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
      ],
    );
  }
}