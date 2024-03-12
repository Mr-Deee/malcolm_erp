import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class employeetill extends StatefulWidget {
  const employeetill({super.key});

  @override
  State<employeetill> createState() => _employeetillState();
}

class _employeetillState extends State<employeetill> {
  String? userName;
  String? userEmail;
  List<Map<String, dynamic>>? assignedStock;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchAssignedStock();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> fetchUserData() async {
    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(_firebaseAuth.currentUser?.uid).get();
    setState(() {
      userName = userDoc['FullName'];
      userEmail = userDoc['Email'];
    });
  }
String? data;
  Future<void> fetchAssignedStock() async {
    final assignedStockSnapshot = await FirebaseFirestore.instance
        .collection('AssignedStock')
        .where('Email', isEqualTo: _firebaseAuth.currentUser?.email)
        .get();

    setState(() {
      assignedStock = assignedStockSnapshot.docs.map((doc) => doc.data()).toList();

      assignedStock = assignedStockSnapshot.docs.map((doc) {
        // Extracting document ID along with other data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;  print(data);
        return data;

      }).toList();
    });
  }

  Future<void> makeSale(String productId,productname) async {
    int? soldQuantity;

    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Quantity'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              soldQuantity = int.tryParse(value);
            },
            decoration: InputDecoration(
              hintText: 'Enter quantity',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(soldQuantity);
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );

    if (soldQuantity != null) {
      final assignedStockRef = FirebaseFirestore.instance.collection('AssignedStock');
      final productDoc = assignedStockRef.doc(productId);
      final currentData = await productDoc.get();


      final int availableQuantity = currentData['quantity'];
      final String  productid = currentData['ProductID'];
      final int  costperquantity = currentData['Costper'];
      final double total = currentData['total'];

      if (availableQuantity >= soldQuantity!) {
        final int remainingQuantity = availableQuantity - soldQuantity!;
        final double totalSales = soldQuantity! * costperquantity.toDouble();

        await productDoc.update({
          'quantity': remainingQuantity,
          'RemainingTotal': total - totalSales,
          // Assuming total remains unchanged
        });


        // Save sold quantity and amount in a separate table or field in the AssignedStock document


        // Save sold quantity and amount in a separate table or field in the AssignedStock document
    await FirebaseFirestore.instance.collection('AssignedStock').doc(productId).update({
          'productId': productid,
          'soldQuantity': soldQuantity,
          'totalSales': totalSales,
          'soldBy': _firebaseAuth.currentUser?.email,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance.collection('SoldQuantity').doc().set({
          'ProductName':productname,
          'productId': productid,
          'soldQuantity': soldQuantity,
          'totalSales': totalSales,
          'soldBy': _firebaseAuth.currentUser?.email,
          'timestamp': FieldValue.serverTimestamp(),
        });


        // Refresh assigned stock list
        fetchAssignedStock();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Insufficient Quantity'),
            content: Text('The available quantity is not enough to fulfill this sale.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Page'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Sign Out'),
                      backgroundColor: Colors.white,
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text('Are you certain you want to Sign Out?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            print('yes');
                            FirebaseAuth.instance.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/SignIn",
                                  (route) => false,
                            );
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Information:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Name: $userName'),
                  Text('Email: $userEmail'),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assigned Stock:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        // Display assigned stock in cards
                        if (assignedStock != null)
                          Column(
                            children: assignedStock!.map((stockItem) {
                              final docid = stockItem['id'];
                              final productname =stockItem['ProductName'];
                              return SizedBox(
                                width: 440,
                                height: 120,
                                child: Card(

                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              ' ${stockItem['ProductName']}',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text('Qty: ${stockItem['quantity']}'),
                                          ],
                                        ),
                                        SizedBox(height: 4),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              'GHS${(stockItem['total'])}',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                print(docid);

                                                // Example of making sale for 1 quantity, you can adjust it according to your UI
                                                makeSale(docid, productname);
                                              },
                                              child: Text('Make Sale'),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        if (assignedStock == null || assignedStock!.isEmpty)
                          Text('No assigned stock found.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
