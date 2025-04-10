import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class RecipeProvider extends ChangeNotifier {
  // Map to hold scheduled recipes grouped by date.
  final Map<DateTime, List<Map<String, String>>> _scheduledRecipes = {};
  // List holding recommended recipes locally.
  List<Map<String, String>> _recommendedRecipes = [];

  // Firestore subscription for recommended recipes updates.
  StreamSubscription? _recommendedRecipesSubscription;

  // Getters to access recipes.
  Map<DateTime, List<Map<String, String>>> get scheduledRecipes =>
      _scheduledRecipes;
  List<Map<String, String>> get recommendedRecipes => _recommendedRecipes;

  RecipeProvider() {
    _startListeningToRecommendedRecipes();
  }

  /// Listens to the Firestore `recommendedRecipes` collection in real time.
  void _startListeningToRecommendedRecipes() {
    _recommendedRecipesSubscription = FirebaseFirestore.instance
        .collection('recommendedRecipes')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<Map<String, String>> updatedRecipes = [];
      // Iterate through each recommended recipe document.
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        updatedRecipes.add({
          "title": data["name"] ?? "",
          "instructions": data["instructions"] ?? "",
          // Convert the Firestore Timestamp to a formatted string.
          "latestPossibleDate": data["latestPossibleDate"] != null
              ? (data["latestPossibleDate"] as Timestamp).toDate().toString()
              : "",
          // Add additional fields as necessary.
        });
      }
      _recommendedRecipes = updatedRecipes;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _recommendedRecipesSubscription?.cancel();
    super.dispose();
  }

  /// Adds a recipe to a specific calendar date and updates recommended recipes.
  void addRecipeToCalendar(DateTime date, Map<String, String> recipe) {
    // Normalize the date to remove time part.
    DateTime onlyDate = DateTime(date.year, date.month, date.day);

    if (!_scheduledRecipes.containsKey(onlyDate)) {
      _scheduledRecipes[onlyDate] = [];
    }
    _scheduledRecipes[onlyDate]!.add(recipe);

    // Remove the added recipe from the recommended recipes list using the title.
    _recommendedRecipes.removeWhere((r) => r["title"] == recipe["title"]);

    notifyListeners();
  }

  /// Removes a recipe from the calendar and optionally adds it back to recommendations.
  void removeRecipeFromCalendar(Map<String, String> recipe) {
    DateTime? keyToRemove;

    // Loop over each date to find and remove the recipe.
    _scheduledRecipes.forEach((date, recipesList) {
      if (recipesList.any((r) => r["title"] == recipe["title"])) {
        recipesList.removeWhere((r) => r["title"] == recipe["title"]);
        if (recipesList.isEmpty) {
          keyToRemove = date;
        }
      }
    });
    if (keyToRemove != null) {
      _scheduledRecipes.remove(keyToRemove);
    }

    // Optionally, re-add the recipe to the recommended list if it isn’t already there.
    if (!_recommendedRecipes.any((r) => r["title"] == recipe["title"])) {
      _recommendedRecipes.add(recipe);
    }

    notifyListeners();
  }

  /// Directly sets the recommended recipes list.
  void setRecommendedRecipes(List<Map<String, String>> recipes) {
    _recommendedRecipes = recipes;
    notifyListeners();
  }

  /// Adds a single recipe to the recommended list.
  void addRecommendedRecipe(Map<String, String> recipe) {
    _recommendedRecipes.add(recipe);
    notifyListeners();
  }

  /// Removes a recipe from the recommended list.
  void removeRecommendedRecipe(Map<String, String> recipe) {
    _recommendedRecipes.removeWhere((r) => r["title"] == recipe["title"]);
    notifyListeners();
  }
}
