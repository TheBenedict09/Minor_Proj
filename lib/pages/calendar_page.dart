import 'package:flutter/material.dart';
import 'package:minor_proj/pages/Recipe%20Pages/recipe_page.dart';
import 'package:minor_proj/providers/RecipeProvider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:minor_proj/components/circle_blur.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();

  Future<void> _refreshCalendar() async {
    // If your RecipeProvider has a refresh method, call it here
    // e.g., await Provider.of<RecipeProvider>(context, listen: false).refresh();
    // Otherwise just wait a moment so the RefreshIndicator shows briefly.
    await Future.delayed(const Duration(milliseconds: 500));
    // setState((){}); // Not needed if provider notifies automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFEF5E7), Color(0xFF85C1E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -220,
            left: -80,
            child: CircleBlurWidget(
              color: Colors.lightGreenAccent.shade100,
              diameter: 370,
              blurSigma: 50,
            ),
          ),
          // Positioned(
          //   bottom: -180,
          //   right: -150,
          //   child: CircleBlurWidget(
          //     color: Colors.yellowAccent.shade100,
          //     diameter: 350,
          //     blurSigma: 50,
          //   ),
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recipe Calendar",
                      style: TextStyle(
                        fontSize: MediaQuery.sizeOf(context).width * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 28),
                      onPressed: () async {
                        await _refreshCalendar();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TableCalendar(
                        daysOfWeekVisible: true,
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          weekendStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        focusedDay: _selectedDay,
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        calendarFormat: CalendarFormat.month,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = DateTime(selectedDay.year,
                                selectedDay.month, selectedDay.day);
                          });
                        },
                        calendarBuilders: CalendarBuilders(
                          todayBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.lightGreenAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.yellowAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Consumer<RecipeProvider>(
                        builder: (context, recipeProvider, child) {
                          return _buildRecipeList(
                              recipeProvider.scheduledRecipes);
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.08,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.08,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(
      Map<DateTime, List<Map<String, String>>> scheduledRecipes) {
    List<Map<String, String>> recipes = scheduledRecipes[_selectedDay] ?? [];

    return recipes.isEmpty
        ? const Center(child: Text("No recipes scheduled for today."))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recipes.length,
            itemBuilder: (context, index) => _buildRecipeTile(recipes[index]),
          );
  }

  Widget _buildRecipeTile(Map<String, String> recipe) {
    // Preprocess the title by applying our formatter.
    final formattedTitle = formatRecipeTitle(recipe["title"] ?? "",
        maxCharsPerLine: 20, maxLines: 2);

    return InkWell(
      onTap: () {
        // Navigate to RecipeDetailPage when the tile is tapped.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(recipe: recipe),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.white.withOpacity(1)],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.network(
                  recipe["image"]!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Use a Text widget that displays the preformatted title.
                  Text(
                    formattedTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  // Cook time shown on its own line.
                  Text(
                    "Cook Time: ${recipe["cook_time_minutes"]} min",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function that formats a title into at most [maxLines] where each line
// contains at most [maxCharsPerLine] characters. If not all words fit, it appends an ellipsis.
String formatRecipeTitle(String title,
    {int maxCharsPerLine = 20, int maxLines = 2}) {
  List<String> words = title.split(RegExp(r'\s+'));
  List<String> lines = [];
  String currentLine = "";
  int wordIndex = 0;

  // Build each line until either we run out of words or we filled maxLines.
  while (wordIndex < words.length && lines.length < maxLines) {
    String word = words[wordIndex];
    if (currentLine.isEmpty) {
      currentLine = word;
      wordIndex++;
    } else {
      // Check if adding the next word (with a space) exceeds the limit.
      if (currentLine.length + 1 + word.length <= maxCharsPerLine) {
        currentLine += " " + word;
        wordIndex++;
      } else {
        // Cannot add more words to this line, so push it and start a new line.
        lines.add(currentLine);
        currentLine = "";
      }
    }
  }

  // Add the last accumulated line if not empty.
  if (currentLine.isNotEmpty && lines.length < maxLines) {
    lines.add(currentLine);
  }

  // If there are leftover words, append an ellipsis on the last line.
  if (wordIndex < words.length && lines.isNotEmpty) {
    lines[lines.length - 1] = lines.last + "...";
  }

  return lines.join("\n");
}
