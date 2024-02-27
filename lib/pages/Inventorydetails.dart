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
      body: 
      
      
   Container(
        padding: EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Inventory') // Assuming inventory data is stored in a collection named 'inventory'
              .where('Category', isEqualTo: widget.categoryName) // Filter by category name
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var document = snapshot.data!.docs[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(document['Product']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${document['quantity']}'),
                          Text('Date: ${document['Date']}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Text('No inventory items found for this category.'),
            );
          },
        ),
      ),
  }
}