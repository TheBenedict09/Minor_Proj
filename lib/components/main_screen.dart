import 'package:flutter/material.dart';
import 'package:minor_proj/pages/Recipe%20Pages/recommended_recipes_page.dart';
import 'package:minor_proj/pages/calendar_page.dart';
import 'package:minor_proj/pages/Dashboard%20Pages/dashboard_page.dart';
import 'package:minor_proj/pages/profile_page.dart';
import 'package:minor_proj/providers/RecipeProvider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';

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
          screen: Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              return CalendarPage();
            },
          ),
          item: ItemConfig(
            icon: const Icon(Icons.calendar_month),
            title: "Inventory",
          ),
        ),
        PersistentTabConfig(
          screen: const ProfilePage(),
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
