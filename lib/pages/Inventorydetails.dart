import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Inventorydetails extends StatefulWidget {
  const Inventorydetails({Key? key, required this.categoryName})
      : super(key: key);

  @override
  State<Inventorydetails> createState() => _InventorydetailsState();
}

class _InventorydetailsState extends State<Inventorydetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Details"),
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
              return CircularProgressIndicator(); // Display a progress indicator while fetching data
            }
            if (snapshot.hasError) {
              return Text('Error:${snapshot.error}');
            }
            if (snapshot.hasData && snapshot.data!.exists) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> categories =
                  data['list']; // Assuming category names are stored as a list
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String categoryName = categories[index];
                  return GestureDetector(
                    onTap: () {
                      print('Tapped on category: $categoryName');
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(categoryName),
                        leading: Icon(Icons
                            .category), // Placeholder icon, replace with actual icons
                      ),
                    ),
                  );
                },
              );
            }
            return Text('No categories found');
          },
        ),
      ),
    );
  }
}
