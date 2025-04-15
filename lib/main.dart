import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minor_proj/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:minor_proj/pages/welcome_page.dart';
import 'package:minor_proj/components/main_screen.dart';
import 'package:minor_proj/providers/RecipeProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecipeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // User is signed in → display the MainScreen (which includes the navbar).
          return const MainScreen();
        } else {
          // User is signed out → display the LoginPage.
          return const LoginPage();
        }
      },
    );
  }
}
