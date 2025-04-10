import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minor_proj/pages/welcome_page.dart';
import 'package:minor_proj/components/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(), // Dynamically decide the first screen
    );
  }
}

// ✅ Decides which screen to show first
class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ✅ User is already logged in → Go to MainScreen
      return const MainScreen();
    } else {
      // ❌ User NOT logged in → Show WelcomePage
      return const WelcomePage();
    }
  }
}
