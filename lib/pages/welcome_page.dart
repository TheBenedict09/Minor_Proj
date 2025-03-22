import 'package:flutter/material.dart';
import 'package:minor_proj/components/circle_blur.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light gray background
      backgroundColor: const Color(0xFFF3F3F3),
      body: Stack(
        children: [
          // Blurred circles
          Positioned(
            top: -60,
            left: -30,
            child: CircleBlurWidget(
              color: Colors.orange,
              diameter: 270,
              blurSigma: 50, // Increase for more blur
            ),
          ),
          Positioned(
            top: 250,
            right: -80,
            child: CircleBlurWidget(
              color: Colors.purple,
              diameter: 200,
              blurSigma: 65,
            ),
          ),
          Positioned(
            bottom: 160,
            left: -70,
            child: CircleBlurWidget(
              color: Colors.yellow,
              diameter: 200,
              blurSigma: 50,
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: CircleBlurWidget(
              color: Colors.cyanAccent.shade200,
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
                  height: MediaQuery.sizeOf(context).height * 0.25,
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
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
                  onPressed: () {},
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
