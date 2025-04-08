import 'package:flutter/material.dart';
import 'package:minor_proj/pages/dashboard_page.dart';
import 'package:minor_proj/pages/login_page.dart';
import 'package:minor_proj/pages/recommended_recipes_page.dart';
import 'package:minor_proj/pages/registration_page.dart';
import 'package:minor_proj/pages/welcome_page.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  List<PersistentTabConfig> _tabs() => [
        PersistentTabConfig(
          screen: const DashboardPage(),
          item: ItemConfig(
            icon: const Icon(Icons.home),
            title: "Home",
          ),
        ),
        PersistentTabConfig(
          screen: const RecommendedRecipesPage(),
          item: ItemConfig(
            icon: const Icon(Icons.restaurant),
            title: "Recipes",
          ),
        ),
        PersistentTabConfig(
          screen: const Center(child: Text("Calendar")),
          item: ItemConfig(
            icon: const Icon(Icons.calendar_month),
            title: "Inventory",
          ),
        ),
        PersistentTabConfig(
          screen: const Center(child: Text("Settings")),
          item: ItemConfig(
            icon: const Icon(Icons.settings),
            title: "Profile",
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        backgroundColor: Colors.transparent,
        tabs: _tabs(),
        navBarBuilder: (navBarConfig) => Style9BottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: const NavBarDecoration(color: Colors.transparent),
        ),
        navBarOverlap: NavBarOverlap.full(),
      ),
    );
  }
}
