import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:malcolm_erp/pages/AssignStock.dart';
import 'package:malcolm_erp/pages/Inventory.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:malcolm_erp/Assistant/assistantmethods.dart';
import 'package:malcolm_erp/models/Admin.dart';
import '../models/Item.dart';
import '../models/addedProduct.dart';
import 'Transactionpage.dart';
import 'addproduct.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final TextEditingController _newProductGroup = TextEditingController();

  final addedproduct newfarm = addedproduct();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _productCategories = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
    _fetchInventoryData();
  }
  List<InventoryItem> _inventoryItems = [];
  Map<String, int> _categoryTotals = {};
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


// Call this function after `_fetchInventoryData` to display the total cost for each category
  void displayCategoryTotalCost(Map<String, double> categoryCostMap) {
    categoryCostMap.forEach((category, totalCost) {
      print('Total cost for category $category: $totalCost');
    });
  }



  Map<String, int> _calculateCategoryTotals() {
    Map<String, int> categoryTotals = {};
    for (var item in _inventoryItems) {
      if (categoryTotals.containsKey(item.category)) {
        categoryTotals[item.category] = categoryTotals[item.category]! + item.quantity;
      } else {
        categoryTotals[item.category] = item.quantity;
      }
    }
    return categoryTotals;
  }


  @override
  Widget build(BuildContext context) {
    String CompanyName =
        Provider.of<Admin>(context).admininfo?.CompanyName ?? "getting name...";
    double _sigmaX = 5; // from 0-10
    double _sigmaY = 5; // from 0-10
    double _opacity = 0.2;
    double _width = 350;
    double _height = 300;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding:  EdgeInsets.all(10.0),
          child: Text(
            CompanyName,
            style: TextStyle(
              fontFamily: "Nunito",
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.black,
            ),
          ),

        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          barrierDismissible:
                          false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Sign Out'),
                              backgroundColor: Colors.white,
                              content: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                        'Are you certain you want to Sign Out?'),
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
                                            (route) => false);
                                    // Navigator.of(context).pop();
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
            ),
          ),

        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage(
            //       'assets/images/backdrop.png'), // Replace with your image path
            //   fit: BoxFit.cover,
            // ),
            ),
        child: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    height: 130,
                    width: 340,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white),
                    child: Column(
                      children: [
                        Text(
                          "DashBoard",
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                        ),

                        Expanded(
                          child: _inventoryItems.isNotEmpty ? _buildTotals() : CircularProgressIndicator(),
                        ),

                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding:  EdgeInsets.all(28.0),
                          child: GestureDetector(
                            onTap: (){

                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          addproduct()));
                            },
                            child: Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.blue),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 38.0),
                                    child: Icon(

                                       Icons.add_circle),
                                  ),
                                  Text(
                                    "Add New\n Product",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 45,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AssignStock()));
                            },
                            child: Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black87),
                              child: Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(top:28.0),
                                      child: Icon(Icons.share,color: Colors.white,)),

                                  Text(
                                    "Assign Stock",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),



                Row(
                  children: [

                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Transactionpage()));
                            },
                            child: Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black87),
                              child: Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(top:28.0),
                                      child: Icon(Icons.monetization_on,color: Colors.white,)),

                                  Text(
                                    "Transaction",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Inventory()));
                        },
                        child: Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black87),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 18.0),
                                child: IconButton(
                                    onPressed: () {

                                      //(Route<dynamic> route) => false);
                                    },
                                    icon: Icon(Icons.inventory,color: Colors.white,)),
                              ),
                              Text(
                                "Inventory",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


displayToast(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}

