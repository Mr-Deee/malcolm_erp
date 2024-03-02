import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Inventorydetails extends StatefulWidget {
  Inventorydetails({Key? key, this.categoryName}) : super(key: key);
  final String? categoryName;

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
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var document = snapshot.data!.docs[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            document['Product'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'QTY: ${document['quantity']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),

                          SizedBox(height: 5),
                          Text(
                            'Date: ${document['Date']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Text(
                'No inventory items found for this category.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
