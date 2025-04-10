// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minor_proj/components/circle_blur.dart';
import 'package:minor_proj/pages/Recipe%20Pages/recipe_page.dart';
import 'package:minor_proj/providers/RecipeProvider.dart';
import 'package:provider/provider.dart';

class RecommendedRecipesPage extends StatefulWidget {
  const RecommendedRecipesPage({super.key});

  @override
  _RecommendedRecipesPageState createState() => _RecommendedRecipesPageState();
}

class _RecommendedRecipesPageState extends State<RecommendedRecipesPage> {
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchRecommendedRecipes();
  }

  Future<void> fetchRecommendedRecipes() async {
    const String apiKey = "849300edee8446acbb831e6c395a7c5e";
    const String apiUrl =
        "https://api.spoonacular.com/recipes/random?number=10&apiKey=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request Timeout");
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, String>> fetchedRecipes = List.generate(
          data['recipes'].length,
          (index) {
            final recipe = data['recipes'][index];
            return {
              "title": recipe['title'],
              "image": recipe['image'],
              "cookTime": "${recipe['readyInMinutes']} min",
              "instructions":
                  recipe['instructions'] ?? "Instructions not available.",
              "prepDate": "N/A",
            };
          },
        );

        // Update provider with new recommended recipes
        Provider.of<RecipeProvider>(context, listen: false)
            .setRecommendedRecipes(fetchedRecipes);

        setState(() {
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("Failed to load recipes");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recommendedRecipes = recipeProvider.recommendedRecipes;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -110,
            left: -80,
            child: CircleBlurWidget(
              color: Colors.orangeAccent,
              diameter: 370,
              blurSigma: 50,
            ),
          ),
          Positioned(
            bottom: 0,
            right: -120,
            child: CircleBlurWidget(
              color: Colors.cyanAccent,
              diameter: 350,
              blurSigma: 50,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recommended \nRecipes",
                      style: TextStyle(
                        fontSize: MediaQuery.sizeOf(context).width * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        size: MediaQuery.sizeOf(context).width * 0.07,
                        Icons.restaurant_menu,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error,
                                    color: Colors.red, size: 50),
                                const SizedBox(height: 10),
                                const Text(
                                    "Failed to load recipes. Try again."),
                                ElevatedButton(
                                  onPressed: fetchRecommendedRecipes,
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: recommendedRecipes.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.69,
                            ),
                            itemBuilder: (context, index) {
                              final recipe = recommendedRecipes[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailPage(recipe: recipe),
                                    ),
                                  );
                                },
                                child: _buildRecipeCard(
                                    recipe, recipeProvider, context),
                              );
                            },
                          ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.08,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildRecipeCard(Map<String, String> recipe,
    RecipeProvider recipeProvider, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 3,
          offset: const Offset(2, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wrap image with Hero widget for smooth transition
              Hero(
                tag: recipe["title"]!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    recipe["image"]!,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image,
                          size: 50, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                recipe["title"]!,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.grey.shade600),
                        Text(
                          recipe["cookTime"]!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        DateTime today = DateTime.now();
                        recipeProvider.addRecipeToCalendar(today, recipe);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Added ${recipe["title"]} to today's schedule!"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
