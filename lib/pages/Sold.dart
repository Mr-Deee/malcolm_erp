import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Soldpage extends StatefulWidget {
  const Soldpage({Key? key}) : super(key: key);

  @override
  State<Soldpage> createState() => _SoldpageState();
}

class _SoldpageState extends State<Soldpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sold Products'),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('SoldQuantity').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data?.docs[index];
                var productName = doc?['ProductName'];
                var quantitySold = doc?['soldQuantity'];
                var amountSold = doc?['totalSales'];
                var perUnit = doc?['perUnit'];

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Row(
                      children: [
                        Text(productName),
                        Text('Per Unit: $perUnit'),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Quantity Sold: $quantitySold'),
                        Text('Total: $amountSold'),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      // Add functionality for tapping on the item if needed
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
