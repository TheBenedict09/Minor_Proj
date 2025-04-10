import 'dart:ui';
import 'dart:convert'; // for JSON decoding
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minor_proj/components/circle_blur.dart';
import 'package:http/http.dart' as http;

import 'functions.dart'; // for API requests

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, String>> inventoryItems = [];
  bool isLoading = true;
  bool hasError = false;
  // Firestore instance for convenience.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listener subscription for real-time updates.
  late final Stream<QuerySnapshot> _inventoryStream;

  @override
  void initState() {
    super.initState();
    _inventoryStream = _firestore.collection('ingredients').snapshots();
    _listenToInventory();
  }

  void _listenToInventory() {
    _inventoryStream.listen((QuerySnapshot snapshot) {
      try {
        List<Map<String, String>> items = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "name": data["name"]?.toString() ?? "Unnamed",
            "purchase": data["purchase"]?.toString() ?? "Unknown",
            "expiry": data["expiry"]?.toString() ?? "Unknown",
          };
        }).toList();
        setState(() {
          inventoryItems = items;
          isLoading = false;
          hasError = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }, onError: (error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    });
  }

  // Date picker helper.
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // default value.
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // Format the date as e.g., "10 Feb"
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')} ${_monthName(picked.month)}";
      controller.text = formattedDate;
    }
  }

  String _monthName(int month) {
    const List<String> months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  void _showAddItemDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController purchaseController = TextEditingController();
    final TextEditingController expiryController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierLabel: "Add Item",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        // Declare the variable outside of the builder to preserve state.
        bool isAdding = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEEAD8), Color(0xFFF3F3F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
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
                        // Purchase Date field with Date Picker.
                        TextField(
                          controller: purchaseController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Purchase Date",
                            hintText: "Select purchase date",
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _selectDate(context, purchaseController),
                        ),
                        const SizedBox(height: 15),
                        // Expiry Date field with Date Picker.
                        TextField(
                          controller: expiryController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Expiry Date",
                            hintText: "Select expiry date",
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _selectDate(context, expiryController),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreenAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isAdding
                              ? null
                              : () async {
                                  if (nameController.text.isNotEmpty &&
                                      expiryController.text.isNotEmpty) {
                                    setState(() {
                                      isAdding = true;
                                    });
                                    // Save the new inventory item (name and dates only).
                                    await _firestore
                                        .collection('ingredients')
                                        .add({
                                      "name": nameController.text,
                                      "purchase":
                                          purchaseController.text.isNotEmpty
                                              ? purchaseController.text
                                              : "Unknown",
                                      "expiry": expiryController.text,
                                    });
                                    setState(() {
                                      isAdding = false;
                                    });
                                    Navigator.pop(context);
                                  }
                                },
                          child: isAdding
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                  ),
                                )
                              : const Text("Add Item"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
                  FutureBuilder<String>(
                    future: getIngredientImage(item["name"]!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.broken_image, size: 50);
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            snapshot.data ?? "https://via.placeholder.com/100",
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 50);
                            },
                          ),
                        );
                      }
                    },
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
            top: -160,
            right: -70,
            child: CircleBlurWidget(
              color: Colors.cyanAccent,
              diameter: 270,
              blurSigma: 50,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -30,
            child: CircleBlurWidget(
              color: Colors.orangeAccent,
              diameter: 250,
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
                                  onPressed: () {
                                    _listenToInventory();
                                  },
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
                                inventoryItems.isEmpty
                                    ? Container(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.5,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Inventory empty",
                                          style: TextStyle(
                                            fontSize: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.05,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: inventoryItems.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio:
                                              MediaQuery.sizeOf(context)
                                                      .height *
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

/// _buildInventoryItem now uses a FutureBuilder to fetch the image based on the item name.
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
                  child: FutureBuilder<String>(
                    future: getIngredientImage(item["name"]!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 60,
                          width: 60,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey);
                      } else {
                        final imageUrl =
                            snapshot.data ?? "https://via.placeholder.com/100";
                        return Image.network(
                          imageUrl,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image,
                                size: 50, color: Colors.grey);
                          },
                        );
                      }
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
