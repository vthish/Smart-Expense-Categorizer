import 'package:flutter/material.dart';
import '../services/nlp_processor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String category = "Waiting...";
  double amount = 0.0;

  void _onTextChanged(String value) {
    var result = NLPProcessor.process(value);
    setState(() {
      amount = result['amount'];
      category = result['category'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _onTextChanged,
              decoration: const InputDecoration(
                labelText: "Enter expense details",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text("Category: $category"),
                subtitle: Text("Amount: Rs. $amount"),
                leading: const Icon(Icons.auto_awesome),
              ),
            )
          ],
        ),
      ),
    );
  }
}