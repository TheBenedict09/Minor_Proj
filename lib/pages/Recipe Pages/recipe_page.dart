// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:minor_proj/providers/RecipeProvider.dart';
import 'package:provider/provider.dart';
import 'package:minor_proj/components/circle_blur.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, String> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      // Use Consumer to conditionally build the FAB based on if the recipe is in the calendar
      floatingActionButton: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          bool isInCalendar = false;
          // Check each scheduled date to see if the recipe exists
          provider.scheduledRecipes.forEach((date, recipes) {
            if (recipes.any((r) => r["title"] == recipe["title"])) {
              isInCalendar = true;
            }
          });

          // If the recipe is in the calendar, show the remove button.
          if (isInCalendar) {
            return FloatingActionButton.extended(
              onPressed: () {
                provider.removeRecipeFromCalendar(recipe);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Recipe removed from Calendar!')),
                );
                Navigator.pop(context);
              },
              backgroundColor: Colors.red.shade100,
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              label: const Text(
                'Remove from Calendar',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            // If not scheduled yet, show the add button with a date picker.
            return FloatingActionButton.extended(
              onPressed: () async {
                DateTime? lastDate;
                if (recipe.containsKey('prepDate') &&
                    recipe['prepDate'] != null) {
                  try {
                    lastDate = DateTime.parse(recipe['prepDate']!);
                  } catch (e) {
                    lastDate = DateTime(2100);
                  }
                } else {
                  lastDate = DateTime(2100);
                }

                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: lastDate,
                );

                if (selectedDate != null) {
                  DateTime onlyDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                  );

                  // Add the recipe to the calendar and remove from the recommendations.
                  provider.addRecipeToCalendar(onlyDate, recipe);
                  provider.removeRecommendedRecipe(recipe);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recipe added to Calendar!')),
                  );

                  Navigator.pop(context); // Close the detail page after adding
                }
              },
              backgroundColor: Colors.blue.shade100,
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.blue,
              ),
              label: const Text(
                'Add to Calendar',
                style: TextStyle(color: Colors.blue),
              ),
            );
          }
        },
      ),
      body: Stack(
        children: [
          Positioned(
            top: -110,
            left: -80,
            child: CircleBlurWidget(
              color: Colors.orangeAccent,
              diameter: 250,
              blurSigma: 50,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: CircleBlurWidget(
              color: Colors.cyanAccent.shade100,
              diameter: 300,
              blurSigma: 90,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: recipe["title"]!,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            recipe['image'] ?? '',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 50),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          recipe['title'] ?? 'Recipe Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.09,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Time: ${recipe['cookTime'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Prep by: ${recipe['prepDate'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructions:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              recipe['instructions'] ??
                                  'No instructions provided.',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
