import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final ScrollController _scrollController = ScrollController();
  final AuthService _auth = AuthService();
  final FirebaseService _db = FirebaseService();
  
  late Stream<List<ExpenseModel>> _expenseStream;
  Timer? _debounce;

  String _category = "Detecting...";
  double _amount = 0.0;
  bool _isAnalyzing = false;
  int _currentIndex = 0;

  final List<String> _categories = [
    "Food", "Transport", "Health", "Shopping", "Utilities", "Education", "Finance", "Entertainment", "Other"
  ];

  @override
  void initState() {
    super.initState();
    _expenseStream = _db.getExpensesByRange(
      DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now().add(const Duration(days: 1)),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Route _smoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation, 
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)
          ),
        );
        var scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: fadeAnimation, 
          child: ScaleTransition(scale: scaleAnimation, child: child)
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void _onInputChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (val.trim().isEmpty) {
      setState(() { 
        _amount = 0.0; 
        _category = "Detecting..."; 
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isAnalyzing = true);
      final result = await AIService.predict(val);
      
      if (result != null && mounted) {
        setState(() {
          var rawAmount = result['amount'];
          if (rawAmount is String) {
            _amount = double.tryParse(rawAmount) ?? 0.0;
          } else if (rawAmount is num) {
            _amount = rawAmount.toDouble();
          } else {
            _amount = 0.0;
          }

          String predictedCat = result['category'].toString();
          if (!_categories.contains(predictedCat) && predictedCat != "Detecting...") {
            _categories.add(predictedCat);
          }
          _category = predictedCat;
          _isAnalyzing = false;
        });
      } else if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    });
  }

  void _showAddCategoryDialog() {
    TextEditingController newCatController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text("Add New Category", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: newCatController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter category name",
              hintStyle: TextStyle(color: Colors.white30),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                if (newCatController.text.trim().isNotEmpty) {
                  setState(() {
                    _categories.add(newCatController.text.trim());
                    _category = newCatController.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  Future<void> _confirmExpense() async {
    if (_controller.text.isEmpty || _amount <= 0 || _category == "Detecting...") return;
    
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();

    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator())
    );

    try {
      await _db.saveExpense(ExpenseModel(
        sentence: _controller.text,
        amount: _amount,
        category: _category,
        date: DateTime.now(),
      ));
      
      AIService.teachAI(_controller.text, _category);
      
      if (mounted) {
        Navigator.pop(context);
        _controller.clear();
        setState(() { 
          _amount = 0.0; 
          _category = "Detecting..."; 
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      bottomNavigationBar: _buildBottomNav(),
      body: Stack(
        children: [
          Positioned(
            top: -100, 
            left: -50, 
            child: _buildGlow(Colors.blueAccent.withValues(alpha: 0.15))
          ),
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
                  const Text(
                    "RECENT ACTIVITY", 
                    style: TextStyle(
                      color: Colors.white38, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.5
                    )
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _buildTransactionList()),
                ],
              ),
            ),
          ),
        ],
      ),
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
              hintText: "What did you spend on?",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
              suffixIcon: _isAnalyzing 
                ? const Padding(
                    padding: EdgeInsets.all(12), 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  ) 
                : null,
            ),
          ),
          const Divider(color: Colors.white10, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric("LKR ${_amount.toStringAsFixed(2)}", "ESTIMATED"),
              _buildCategoryDisplay(),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _confirmExpense,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), 
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Color(0xFF3B82F6)]
                )
              ),
              child: const Center(
                child: Text(
                  "Confirm Expense", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<List<ExpenseModel>>(
      stream: _expenseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(
            child: Text("No transactions yet", style: TextStyle(color: Colors.white24))
          );
        }
        return ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  child: const Icon(Icons.receipt_long, color: Colors.white70, size: 20),
                ),
                title: Text(
                  list[index].sentence, 
                  style: const TextStyle(color: Colors.white, fontSize: 14)
                ),
                subtitle: Text(
                  list[index].category, 
                  style: const TextStyle(color: Colors.white24, fontSize: 12)
                ),
                trailing: Text(
                  "Rs. ${list[index].amount.toStringAsFixed(2)}", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $name!", 
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)
            ),
            const Text(
              "Smart Tracker", 
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showLogoutDialog(),
          child: CircleAvatar(
            radius: 20, 
            backgroundColor: Colors.white.withValues(alpha: 0.05), 
            child: const Icon(Icons.logout, color: Colors.white70, size: 18)
          ),
        )
      ]
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
          TextButton(
            onPressed: () { 
              _auth.signOut(); 
              Navigator.pop(context); 
            }, 
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent))
          )
        ]
      )
    );
  }

  Widget _buildMetric(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(
          label, 
          style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)
        ), 
        const SizedBox(height: 4), 
        Text(
          val, 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        )
      ]
    );
  }

  Widget _buildCategoryDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, 
      children: [
        const Text(
          "CATEGORY", 
          style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)
        ), 
        const SizedBox(height: 4),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _categories.contains(_category) ? _category : null,
            hint: Text(
              _category, 
              style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
            dropdownColor: const Color(0xFF0F172A),
            alignment: AlignmentDirectional.centerEnd,
            items: [
              ..._categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }),
              const DropdownMenuItem<String>(
                value: "ADD_NEW",
                child: Text("➕ Add New...", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              )
            ],
            onChanged: (String? newValue) {
              if (newValue == "ADD_NEW") {
                _showAddCategoryDialog();
              } else if (newValue != null) {
                setState(() {
                  _category = newValue;
                });
              }
            },
          ),
        )
      ]
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 400, 
      height: 400, 
      decoration: BoxDecoration(
        shape: BoxShape.circle, 
        boxShadow: [
          BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)
        ]
      )
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
          Navigator.push(context, _smoothRoute(const AnalyticsScreen())); 
        } else {
          setState(() => _currentIndex = index); 
        }
      }, 
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"), 
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Analytics")
      ]
    );
  }
}