import 'dart:convert'; // Keep for potential future use, but removed from instructions
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Make sure this dependency is in pubspec.yaml
import 'package:intl/intl.dart'; // For formatting dates
import 'package:minor_proj/providers/RecipeProvider.dart'; // Assuming correct path
import 'package:provider/provider.dart';
import 'package:minor_proj/components/circle_blur.dart'; // Assuming correct path

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  // Helper function to parse ingredients from either a List or a JSON string.
  List<Map<String, dynamic>> parseIngredients(dynamic rawIngredients) {
    List<dynamic> ingredientList;

    if (rawIngredients is String && rawIngredients.isNotEmpty) {
      try {
        ingredientList = jsonDecode(rawIngredients) as List<dynamic>;
      } catch (e) {
        return [];
      }
    } else if (rawIngredients is List) {
      ingredientList = rawIngredients;
    } else {
      return [];
    }

    return ingredientList.whereType<Map>().map((item) {
      final Map<String, dynamic> ingredientMap =
          Map<String, dynamic>.from(item);
      return {
        'name': ingredientMap['name']?.toString() ?? 'Unknown Ingredient',
        'amount': ingredientMap['amount']?.toString() ?? '',
        'unit': ingredientMap['unit']?.toString() ?? '',
      };
    }).toList();
  }

  // Helper to format date safely
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat.yMMMd().format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data Extraction and Preparation
    final String title = recipe['name']?.toString() ?? 'Untitled Recipe';
    final List<Map<String, dynamic>> ingredients =
        parseIngredients(recipe['ingredients_required']);
    final String portionSize = recipe['portion_size']?.toString() ?? 'N/A';
    final String cookTime = recipe['cook_time_minutes']?.toString() ?? 'N/A';
    final String cookBy = formatDate(recipe['cook_by_date']?.toString());
    final String imageUrl = (recipe['image'] as String?)?.trim() ?? '';

    // Instructions
    final String instructionHtml = recipe['instructions']?.toString() ?? '';
    final bool hasInstructions = instructionHtml.trim().isNotEmpty &&
        instructionHtml.toLowerCase() != 'no instructions available.';

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFab(context, title),
      body: Stack(
        children: [
          // Background Blurs
          Positioned(
            top: -110,
            left: -80,
            child: CircleBlurWidget(
              color: Colors.orangeAccent.withOpacity(0.6),
              diameter: 250,
              blurSigma: 60,
            ),
          ),
          Positioned(
            bottom: -90,
            right: -70,
            child: CircleBlurWidget(
              color: Colors.lightBlueAccent.withOpacity(0.5),
              diameter: 300,
              blurSigma: 90,
            ),
          ),
          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header
                Hero(
                  tag: title,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(25)),
                    child: Image.network(
                      imageUrl.isNotEmpty
                          ? imageUrl
                          : 'https://via.placeholder.com/600x400/E0E0E0/BDBDBD?text=No+Image',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey.shade300,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Image not available",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    title,
                    style: textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                // Info Cards Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoCard(
                        icon: Icons.timer_outlined,
                        label: 'Time',
                        value: cookTime != 'N/A' ? '$cookTime min' : 'N/A',
                        iconColor: Colors.orange.shade600,
                      ),
                      _InfoCard(
                        icon: Icons.group_outlined,
                        label: 'Servings',
                        value: portionSize,
                        iconColor: Colors.green.shade600,
                      ),
                      _InfoCard(
                        icon: Icons.event_available_outlined,
                        label: 'Prep By',
                        value: cookBy,
                        iconColor: Colors.purple.shade600,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Ingredients Section
                _buildSectionHeader(
                    context, Icons.list_alt_outlined, 'Ingredients'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ingredients.isNotEmpty
                      ? Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 16.0),
                            child: Column(
                              children: ingredients.map((item) {
                                final String name = item['name'] ?? '';
                                final String unit = item['unit'] ?? '';
                                final String amount = item['amount'] ?? '';
                                final String ingredientText = [
                                  if (amount.isNotEmpty) amount,
                                  if (unit.isNotEmpty) unit,
                                  name
                                ].join(' ').trim();

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            ingredientText,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (item != ingredients.last)
                                      const Divider(
                                        color: Colors.grey,
                                        height: 1,
                                      ),
                                    if (item != ingredients.last)
                                      const SizedBox(height: 12),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : const Center(child: Text("No ingredients listed.")),
                ),
                const SizedBox(height: 24),
                // Instructions Section
                _buildSectionHeader(
                    context, Icons.menu_book_outlined, 'Instructions'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: hasInstructions
                          ? Html(
                              data: instructionHtml,
                              style: {
                                "body": Style(
                                  fontSize: FontSize(16.0),
                                  lineHeight: const LineHeight(1.6),
                                  color: Colors.black87,
                                  padding: HtmlPaddings.zero,
                                  margin: Margins.zero,
                                ),
                                "h1": Style(
                                  fontSize: FontSize(24.0),
                                  fontWeight: FontWeight.bold,
                                  margin: Margins.only(bottom: 12),
                                ),
                                "h2": Style(
                                  fontSize: FontSize(22.0),
                                  fontWeight: FontWeight.bold,
                                  margin: Margins.only(bottom: 10),
                                ),
                                "p": Style(
                                  margin: Margins.only(bottom: 12),
                                ),
                                "li": Style(
                                  margin: Margins.only(bottom: 8),
                                ),
                                "ul": Style(
                                  margin: Margins.only(bottom: 12),
                                ),
                                "ol": Style(
                                  margin: Margins.only(bottom: 12),
                                ),
                              },
                            )
                          : const Center(
                              child: Text("No instructions provided.")),
                    ),
                  ),
                ),
                // Bottom Padding for Bottom Navigation Bar
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for section headers.
  Widget _buildSectionHeader(
      BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Extracted FAB Builder.
  Widget _buildFab(BuildContext context, String recipeTitle) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, child) {
        bool isInCalendar = provider.scheduledRecipes.values
            .any((recipes) => recipes.any((r) => r["name"] == recipeTitle));

        final Map<String, String> recipeAsStringMap = recipe.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        );

        return FloatingActionButton.extended(
          onPressed: () async {
            if (isInCalendar) {
              provider.removeRecipeFromCalendar(recipeAsStringMap);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$recipeTitle" removed from Calendar!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else {
              DateTime? lastDate;
              try {
                final dateStrToParse = recipe['cook_by_date']?.toString();
                lastDate = (dateStrToParse != null && dateStrToParse.isNotEmpty)
                    ? DateTime.parse(dateStrToParse)
                    : DateTime(2101);
              } catch (_) {
                lastDate = DateTime(2101);
              }

              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: lastDate,
              );

              if (selectedDate != null) {
                DateTime dateOnly = DateTime(
                    selectedDate.year, selectedDate.month, selectedDate.day);
                provider.addRecipeToCalendar(dateOnly, recipeAsStringMap);
                provider.removeRecommendedRecipe(recipeAsStringMap);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '"$recipeTitle" added to Calendar for ${DateFormat.yMMMd().format(dateOnly)}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
            Navigator.pop(context);
          },
          backgroundColor:
              isInCalendar ? Colors.red.shade100 : Colors.blue.shade100,
          icon: Icon(
            isInCalendar ? Icons.delete_outline : Icons.add,
            color: isInCalendar ? Colors.red.shade700 : Colors.blue.shade700,
          ),
          label: Text(
            isInCalendar ? 'Remove from Calendar' : 'Add to Calendar',
            style: TextStyle(
              color: isInCalendar ? Colors.red.shade700 : Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

// --- Enhanced Info Card Widget ---
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
