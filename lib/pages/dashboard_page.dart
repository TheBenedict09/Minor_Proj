import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minor_proj/components/circle_blur.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, String>> inventoryItems = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchFoodIngredients();
  }

  Future<void> fetchFoodIngredients() async {
    const String apiKey = "849300edee8446acbb831e6c395a7c5e";
    const String apiUrl =
        "https://api.spoonacular.com/food/ingredients/search?query=food&number=10&apiKey=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request Timeout");
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          inventoryItems = List.generate(data['results'].length, (index) {
            final ingredient = data['results'][index];
            return {
              "name": ingredient['name'],
              "expiry": "${25 + index} Mar", // Mock expiry dates
              "image":
                  "https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}",
            };
          });
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("Failed to load ingredients");
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
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 20,
        tooltip: "Add Item",
        backgroundColor: Colors.lightGreenAccent,
        child: Icon(
          Icons.add,
          size: MediaQuery.sizeOf(context).width * 0.09,
        ),
      ),
      backgroundColor: const Color(0xFFF3F3F3),
      body: Stack(
        children: [
          Positioned(
            top: -160,
            left: -30,
            child: CircleBlurWidget(
              color: Colors.cyanAccent,
              diameter: 270,
              blurSigma: 50,
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: CircleBlurWidget(
              color: Colors.lightGreenAccent.shade200,
              diameter: 220,
              blurSigma: 50,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: MediaQuery.sizeOf(context).width * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        size: MediaQuery.sizeOf(context).width * 0.07,
                        Icons.account_circle,
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
                                const Text("Failed to load data. Try again."),
                                ElevatedButton(
                                  onPressed: fetchFoodIngredients,
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  "Your Inventory",
                                  style: TextStyle(
                                    fontSize: MediaQuery.sizeOf(context).width *
                                        0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: inventoryItems.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio:
                                        MediaQuery.sizeOf(context).height *
                                            0.0007,
                                  ),
                                  itemBuilder: (context, index) {
                                    return _buildInventoryItem(
                                        inventoryItems[index]);
                                  },
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
              ),
              Expanded(
                  flex: 1,
                  child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.08)),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildInventoryItem(Map<String, String> item) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    item["image"]!,
                    height: 60,
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
                item["name"]!,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Expires: ${item["expiry"]}",
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
