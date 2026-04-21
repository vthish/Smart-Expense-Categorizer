import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
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
  final AuthService _auth = AuthService();
  Timer? _debounce;
  
  String _category = "Detecting...";
  double _amount = 0.0;
  bool _isAnalyzing = false;
  int _currentIndex = 0;

  final List<String> _categories = [
    "Food", "Transport", "Health", "Shopping", "Utilities", "Education", "Finance"
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Route _smoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
        );
        var scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastLinearToSlowEaseIn),
        );
        return FadeTransition(opacity: fadeAnimation, child: ScaleTransition(scale: scaleAnimation, child: child));
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
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
          String predicted = result['category'].toString();
          if (!_categories.contains(predicted)) _categories.add(predicted);
          _category = predicted;
          _isAnalyzing = false;
        });
      } else {
        if (mounted) setState(() => _isAnalyzing = false);
      }
    });
  }

  Future<void> _confirmExpense() async {
    if (_controller.text.isEmpty || _amount <= 0) return;
    final FirebaseService db = FirebaseService(); 
    
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await db.saveExpense(ExpenseModel(
        sentence: _controller.text,
        amount: _amount,
        category: _category,
        date: DateTime.now(),
      ));
      await AIService.teachAI(_controller.text, _category);
      if (mounted) {
        Navigator.pop(context);
        _controller.clear();
        setState(() { _amount = 0.0; _category = "Detecting..."; });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService db = FirebaseService();
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      bottomNavigationBar: _buildBottomNav(),
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: _buildGlow(Colors.blueAccent.withValues(alpha: 0.15))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(user?.displayName ?? "User"),
                  const SizedBox(height: 25),
                  _buildMainHeroCard(),
                  const SizedBox(height: 30),
                  const Text("RECENT ACTIVITY", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Expanded(child: _buildTransactionList(db)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, $name!", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
            const Text("Smart Tracker", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        GestureDetector(
          onTap: () => _showLogoutDialog(),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            child: const Icon(Icons.logout, color: Colors.white70, size: 18),
          ),
        )
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to sign out?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { _auth.signOut(); Navigator.pop(context); }, child: const Text("Logout", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildTransactionList(FirebaseService db) {
    return StreamBuilder<List<ExpenseModel>>(
      stream: db.getExpensesByRange(DateTime.now().subtract(const Duration(days: 30)), DateTime.now()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              child: ListTile(
                title: Text(list[index].sentence, style: const TextStyle(color: Colors.white)),
                subtitle: Text(list[index].category, style: const TextStyle(color: Colors.white24)),
                trailing: Text("Rs. ${list[index].amount.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widgets (Glow, Metric, etc.) would follow here...
  Widget _buildGlow(Color color) => Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)]));

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0F172A),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white24,
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 1) Navigator.push(context, _smoothRoute(const AnalyticsScreen()));
        else setState(() => _currentIndex = index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Analytics"),
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
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "What did you spend on?", border: InputBorder.none),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _confirmExpense, child: const Text("Confirm Expense")),
        ],
      ),
    );
  }
}