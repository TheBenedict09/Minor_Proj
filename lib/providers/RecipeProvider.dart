import 'package:flutter/material.dart';

class RecipeProvider extends ChangeNotifier {
  final Map<DateTime, List<Map<String, String>>> _scheduledRecipes = {};
  List<Map<String, String>> _recommendedRecipes = [];

  Map<DateTime, List<Map<String, String>>> get scheduledRecipes =>
      _scheduledRecipes;
  List<Map<String, String>> get recommendedRecipes => _recommendedRecipes;

  void addRecipeToCalendar(DateTime date, Map<String, String> recipe) {
    DateTime onlyDate = DateTime(date.year, date.month, date.day);

    if (!_scheduledRecipes.containsKey(onlyDate)) {
      _scheduledRecipes[onlyDate] = [];
    }
    _scheduledRecipes[onlyDate]!.add(recipe);

    // 🔥 FIX: Remove from recommendations by title (not object reference)
    _recommendedRecipes.removeWhere((r) => r["title"] == recipe["title"]);

    notifyListeners();
  }

  void setRecommendedRecipes(List<Map<String, String>> recipes) {
    _recommendedRecipes = recipes;
    notifyListeners();
  }

  void addRecommendedRecipe(Map<String, String> recipe) {
    _recommendedRecipes.add(recipe);
    notifyListeners();
  }

  void removeRecommendedRecipe(Map<String, String> recipe) {
    _recommendedRecipes.removeWhere((r) => r["title"] == recipe["title"]);
    notifyListeners();
  }
}
