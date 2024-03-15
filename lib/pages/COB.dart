import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class COB extends StatefulWidget {
   COB({super.key});

  @override
  State<COB> createState() => _COBState();
}

class _COBState extends State<COB> {

  Future<void> _handleDelete(document) async {
    // Delete from AssignedStock table
    await FirebaseFirestore.instance.collection('AssignedStock').doc(document).delete();
   var querySnapshot = await FirebaseFirestore.instance.collection('SoldQuantity').where("productId",isEqualTo:document).get();
    querySnapshot.docs.forEach((doc) {
      doc.reference.delete();
    });
    // Update quantity in product table
    DocumentSnapshot productSnapshot =
    await FirebaseFirestore.instance.collection('Product').doc(document).get();
    int currentQuantity = productSnapshot['quantity'];
    int? soldQuantity = await _getSoldQuantity(document);
    int remainingQuantity = currentQuantity - soldQuantity!;

    // Calculate total cost for remaining quantity
    int pricePerUnit = productSnapshot['Cost'];
    int totalCost = remainingQuantity * pricePerUnit;

    // Update product with new quantity and total cost
    await FirebaseFirestore.instance.collection('Product').doc(document).update({
      'quantity': remainingQuantity,
      'totalCost': totalCost,
      'status': remainingQuantity > 0 ? 'Available' : 'Out of Stock',
    });

    setState(() {
      // Refresh UI after deletion
    });
  }

  Future<int?> _getSoldQuantity(String productId) async {
    QuerySnapshot soldSnapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('productId', isEqualTo: productId)
        .get();
    int? totalQuantitySold = 0;
    soldSnapshot.docs.forEach((doc) {
      totalQuantitySold = ((totalQuantitySold ?? 0) + (doc['quantity'] ?? 0)) as int?;    });
    return totalQuantitySold;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Close Of Business"),
      ),
      backgroundColor: Colors.black38,

      body: SingleChildScrollView(
        child: Column(
          children: [
        
        StreamBuilder(
        stream: FirebaseFirestore.instance.collection('SoldQuantity').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SizedBox(
            height: double.maxFinite,
            child: ListView(
                children: snapshot.data!.docs.map((document) {
                  return Card(
                    child: ListTile(
                      title: Column(
                        children: [
                          Text(document['ProductName']),
                          Text(document['productId']),
                        ],
                      ),
                      subtitle: Text('Quantity: ${document['soldQuantity']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          _handleDelete(document['productId']);
                        },
                      ),
                    ),
                  );
                }).toList()
            ),
          );
        })
            ],
        ),
      ),
    );
  }
}
