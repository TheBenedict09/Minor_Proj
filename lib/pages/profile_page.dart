import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minor_proj/components/circle_blur.dart';
import 'package:minor_proj/pages/login_page.dart';
import 'package:minor_proj/pages/welcome_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  /// Builds a card containing the user's profile details.
  Widget _buildProfileDetails(BuildContext context, User? user) {
    // Fallbacks in case there is no available data.
    final String name = user?.displayName ?? "Anonymous";
    final String email = user?.email ?? "No Email Available";

    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.85),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Greeting and welcome message.
            Text(
              "Welcome,",
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 32,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // A decorative divider.
            Divider(
              color: Colors.grey.shade400,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 16),
            // Email information.
            ListTile(
              leading: const Icon(Icons.email, color: Colors.grey),
              title: Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sign Out button.
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) =>
                      false, // Removes all previous routes.
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: MediaQuery.sizeOf(context).width * 0.07,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFF3F3F3),
      body: Stack(
        children: [
          // Background gradient.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFEF5E7), Color(0xFF85C1E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Blurred decoration in the top-right corner.
          const Positioned(
            top: -160,
            right: -70,
            child: CircleBlurWidget(
              color: Colors.yellow,
              diameter: 270,
              blurSigma: 50,
            ),
          ),
          const Positioned(
            bottom: -100,
            left: -30,
            child: CircleBlurWidget(
              color: Colors.cyanAccent,
              diameter: 250,
              blurSigma: 50,
            ),
          ),
          // Blurred decoration in the bottom-left corner.
          // Centered profile details card.
          Center(
            child: _buildProfileDetails(context, user),
          ),
        ],
      ),
    );
  }
}
