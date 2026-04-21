import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/glass_container.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            top: -100, 
            right: -50, 
            child: Container(
              width: 400, 
              height: 400, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.1), // Fixed withValues
                    blurRadius: 150, 
                    spreadRadius: 50
                  )
                ]
              )
            )
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("SMART EXPENSE", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  Text("AI Powered Tracker", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () async {
                      final userCredential = await auth.signInWithGoogle();
                      // Fixed async gap warning by checking if context is still valid
                      if (userCredential != null && context.mounted) {
                        Navigator.pushReplacement(context, _smoothRoute(const HomeScreen()));
                      }
                    },
                    child: GlassContainer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, color: Colors.blueAccent),
                          const SizedBox(width: 15),
                          const Text("Continue with Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
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
}