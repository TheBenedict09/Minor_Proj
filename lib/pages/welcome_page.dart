import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minor_proj/components/circle_blur.dart';
import 'package:minor_proj/pages/login_page.dart';
import 'package:minor_proj/components/main_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(
        const Duration(seconds: 4)); // Show welcome screen for 2 seconds

    FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        if (user != null) {
          // ✅ User is logged in, go to MainScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // ❌ User is NOT logged in, go to LoginPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Stack(
        children: [
          // Blurred circles
          Positioned(
            top: -60,
            left: -30,
            child: CircleBlurWidget(
              color: Colors.cyanAccent.shade200,
              diameter: 270,
              blurSigma: 50,
            ),
          ),
          Positioned(
            top: 250,
            right: -80,
            child: CircleBlurWidget(
              color: Colors.lightGreenAccent.shade200,
              diameter: 220,
              blurSigma: 65,
            ),
          ),
          Positioned(
            bottom: 190,
            left: -70,
            child: CircleBlurWidget(
              color: Colors.yellow,
              diameter: 200,
              blurSigma: 50,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -30,
            child: CircleBlurWidget(
              color: Colors.orange,
              diameter: 220,
              blurSigma: 50,
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Foodie',
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width * 0.18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.06,
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Plan your plate\n",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      TextSpan(
                        text: "Save your food",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
