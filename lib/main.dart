import 'package:flutter/material.dart';
import 'package:minor_proj/pages/dashboard_page.dart';
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
          screen: const Center(child: Text("Inventory")),
          item: ItemConfig(
            icon: const Icon(Icons.list),
            title: "Inventory",
          ),
        ),
        PersistentTabConfig(
          screen: const Center(child: Text("Recipes")),
          item: ItemConfig(
            icon: const Icon(Icons.restaurant),
            title: "Recipes",
          ),
        ),
        PersistentTabConfig(
          screen: const Center(child: Text("Profile")),
          item: ItemConfig(
            icon: const Icon(Icons.person),
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
