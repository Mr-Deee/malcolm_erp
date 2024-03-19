import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Assistant/assistantmethods.dart';
import '../models/Item.dart';
import 'Inventorydetails.dart';

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
    _fetchInventoryData();
  }
  List<InventoryItem> _inventoryItems = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text("Inventory"),
        ),
      ),
      body: Column(
        children: [

          Text("AVAILABLE GOODS",style: TextStyle(fontWeight: FontWeight.bold),),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              height: 100,

              child: _inventoryItems.isNotEmpty ? _buildTotals() : CircularProgressIndicator(),
            ),
          ),


          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('utils')
                    .doc('ProductCategory')
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(), // Display a progress indicator while fetching data
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.hasData && snapshot.data!.exists) {
                    Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                    List<dynamic> categories =
                    data['list']; // Assuming category names are stored as a list
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns in the grid
                        crossAxisSpacing: 20.0, // Spacing between columns
                        mainAxisSpacing: 20.0, // Spacing between rows
                        childAspectRatio: 0.8, // Aspect ratio of each grid item
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        String categoryName = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Inventorydetails(categoryName: categoryName),
                              ),
                            );
                            print('Tapped on category: $categoryName');
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory, size: 50, color: Colors.blue),
                                SizedBox(height: 10),
                                Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: Text('No categories found'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _fetchInventoryData() async {
    // Fetch inventory data from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Product').get();
    Map<String, double> categoryCostMap = {}; // Map to store total cost per category

    setState(() {
      _inventoryItems = snapshot.docs.map((doc) {
        String name = doc['Product'];
        String category = doc['Category'];
        int quantity = (doc['quantity'] ?? 0).toInt(); // Ensure quantity is converted to int
        double sum = double.tryParse(doc['Sum'].toString()) ?? 0.0;

        // Update category cost map by accumulating sum for each category
        categoryCostMap[category] =  sum;

        return InventoryItem(
          name: name,
          category: category,
          quantity: quantity,
          price: sum / quantity, // Calculate price per item
          totalCost: categoryCostMap[category]??0.0, // Total cost for the category
        );
      }).toList();
    });

    // Output the sum for each category
    categoryCostMap.forEach((category, totalCost) {
      print('Total cost for category $category: $totalCost');
    });
  }

  Widget _buildTotals() {
    Map<String, double> categoryCostMap = {};

    _inventoryItems.forEach((item) {
      if (categoryCostMap.containsKey(item.category)) {
        categoryCostMap[item.category] =
            categoryCostMap[item.category]! + item.totalCost;
      } else {
        categoryCostMap[item.category] = item.totalCost;
      }
    });

    return ListView(
      scrollDirection: Axis.horizontal,
      children: categoryCostMap.entries.map((entry) {
        String category = entry.key;
        double totalCost = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              category,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'GHC ${totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
