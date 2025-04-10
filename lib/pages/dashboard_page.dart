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
              // Here we add a dummy purchase date. You can update this based on real API data.
              "purchase": "${10 + index} Feb",
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

  void _showInventoryDetails(Map<String, String> item) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Item Details",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      item["image"]!,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 50);
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    item["name"]!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Purchased on: ${item["purchase"] ?? "Unknown"}",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Expires: ${item["expiry"]}",
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  void _showAddItemDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController purchaseController = TextEditingController();
    final TextEditingController expiryController = TextEditingController();
    final TextEditingController imageController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierLabel: "Add Item",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add Inventory Item",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: purchaseController,
                      decoration: const InputDecoration(
                        labelText: "Purchase Date",
                        hintText: "e.g. 10 Feb",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: expiryController,
                      decoration: const InputDecoration(
                        labelText: "Expiry Date",
                        hintText: "e.g. 25 Mar",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: "Image URL",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            expiryController.text.isNotEmpty) {
                          setState(() {
                            // Create a new item using the provided data.
                            inventoryItems.add({
                              "name": nameController.text,
                              "purchase": purchaseController.text.isNotEmpty
                                  ? purchaseController.text
                                  : "Unknown",
                              "expiry": expiryController.text,
                              "image": imageController.text.isNotEmpty
                                  ? imageController.text
                                  : "https://via.placeholder.com/100",
                            });
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add Item"),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
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
            bottom: 190,
            left: -140,
            child: CircleBlurWidget(
              color: Colors.yellow,
              diameter: 290,
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
                        Icons.account_circle,
                        size: MediaQuery.sizeOf(context).width * 0.07,
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
                                    return GestureDetector(
                                      onTap: () => _showInventoryDetails(
                                          inventoryItems[index]),
                                      child: _buildInventoryItem(
                                          inventoryItems[index]),
                                    );
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
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
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
