import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malcolm_erp/Assistant/assistantmethods.dart';

class EmployeePage extends StatefulWidget {
   EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
   String? userName;
  String? userEmail;
   List<Map<String, dynamic>>? assignedStock;

  @override
  void initState() {
    super.initState();
    // AssistantMethod.getUserInfo(context);
    // fetchUserData();
    // fetchAssignedStock();
  }
   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Future<void> fetchUserData() async {
  //
  //   final userDoc = await FirebaseFirestore.instance.collection('users').doc(_firebaseAuth.currentUser?.uid).get();
  //   setState(() {
  //     userName = userDoc['FullName'];
  //     userEmail = userDoc['Email'];
  //   });
  // }

   // Future<void> fetchAssignedStock() async {
   //   // Fetch assigned stock data from Firestore
   //   final assignedStockSnapshot = await FirebaseFirestore.instance
   //       .collection('AssignedStock')
   //       .where('Email', isEqualTo: userEmail.toString())
   //       .get();
   //
   //   // Update the state with the retrieved data
   //   setState(() {
   //     assignedStock = assignedStockSnapshot.docs.map((doc) => doc.data()).toList();
   //   });
   // }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Page'),
      ),
      body: Column(
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
              ],
            ),
          ),
          // Divider(),
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
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: assignedStock?.length,
                  itemBuilder: (context, index) {
                    final item = assignedStock?[index];
                    // return ListTile(
                    //   // title: Text(item?['ProductName'] ),
                    //   subtitle: Text('Quantity: ${item?['quantity']}'),
                    //   trailing: Text('Total Import: \$${item?['total']}'),
                    // );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
