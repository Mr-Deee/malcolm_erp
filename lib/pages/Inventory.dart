import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Inventorydetails.dart';

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory"),
      ),
      body: Container(
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
    );
  }
}
