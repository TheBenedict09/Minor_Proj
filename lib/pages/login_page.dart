import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minor_proj/components/circle_blur.dart';
import 'package:minor_proj/pages/registration_page.dart';
import 'package:minor_proj/components/main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigate to MainScreen on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFEF5E7), Color(0xFF85C1E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Blurred Circles
          Positioned(
            top: -60,
            left: -30,
            child: CircleBlurWidget(
              color: Colors.yellow,
              diameter: 270,
              blurSigma: 50,
            ),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: CircleBlurWidget(
              color: Colors.lightGreenAccent.shade200,
              diameter: 360,
              blurSigma: 50,
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: CircleBlurWidget(
              color: Colors.cyanAccent,
              diameter: 220,
              blurSigma: 50,
            ),
          ),

          // Center content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Login Title
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: MediaQuery.sizeOf(context).width * 0.13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Sign in to continue",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon:
                          Icon(Icons.email_outlined, color: Colors.black54),
                      focusedBorder: _borderStyle(Colors.black),
                      enabledBorder: _borderStyle(Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon:
                          Icon(Icons.lock_outline, color: Colors.black54),
                      focusedBorder: _borderStyle(Colors.black),
                      enabledBorder: _borderStyle(Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Error Message (if any)
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sign In',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                  ),
                  const SizedBox(height: 40),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New User?", style: TextStyle(fontSize: 16)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistrationPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for text field borders
  OutlineInputBorder _borderStyle(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
