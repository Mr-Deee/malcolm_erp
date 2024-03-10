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
    // AssistantMethod.getUserInfo(context);
    fetchUserData();
    fetchAssignedStock();
  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  Future<void> fetchUserData() async {

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_firebaseAuth.currentUser?.uid).get();
    setState(() {
      userName = userDoc['FullName'];
      userEmail = userDoc['Email'];
    });
  }

  Future<void> fetchAssignedStock() async {
  //   // Fetch assigned stock data from Firestore
    final assignedStockSnapshot = await FirebaseFirestore.instance
        .collection('AssignedStock')
        .where('Email', isEqualTo: _firebaseAuth.currentUser?.email)
        .get();

    // Update the state with the retrieved data
    setState(() {
      assignedStock = assignedStockSnapshot.docs.map((doc) => doc.data()).toList();
      print(assignedStock);
      print(userEmail);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Employee Page'),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Name: $userName'),
                    Text('Email: $userEmail'),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(height: 8),
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
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Product Name: ${stockItem['ProductName']}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text('Quantity: ${stockItem['quantity']}'),
                                          Text(
                                            'Total: \GHS${(stockItem['total'])}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            if (assignedStock == null || assignedStock!.isEmpty)
                              Text('No assigned stock found.'),
                          ],
                        ),
                      )],
                      ),
                    ),
                  ])),


        ]));
  }
}
