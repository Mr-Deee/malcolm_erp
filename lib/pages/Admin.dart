import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:malcolm_erp/pages/Sold.dart';
import '../Assistant/assistantmethods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../models/Admin.dart';
import 'Inventory.dart';

class Adminpage extends StatefulWidget {
  const Adminpage({super.key});

  @override
  State<Adminpage> createState() => _AdminpageState();
}

Map<String, int> _categoryTotals = {};

class _AdminpageState extends State<Adminpage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethod.getAminInfo(context);
    _fetchProductCategories();
  }

  Future<void> _fetchProductCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Product').get();

      Map<String, int> categoryTotals = {};

      snapshot.docs.forEach((doc) {
        String category = doc['Category'];
        int price = doc['Sum'];

        categoryTotals[category] = (categoryTotals[category] ?? 0) + price;
      });

      setState(() {
        _categoryTotals = categoryTotals;
      });
    } catch (error) {
      print('Error fetching product categories: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    String CompanyName =
        Provider.of<Admin>(context).admininfo?.CompanyName ?? "Jolynda";
    return Scaffold(
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
                SizedBox(
                  height: 45,
                ),
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
                          padding: const EdgeInsets.all(10.0),
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
                SizedBox(
                  height: 15,
                ),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Expanded(
                          child: _categoryTotals.isNotEmpty
                              ? _buildTotals()
                              : CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
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
                                    icon: Icon(
                                      Icons.inventory,
                                      color: Colors.white,
                                    )),
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
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Soldpage()));
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
                                  padding: EdgeInsets.only(top: 28.0),
                                  child: Icon(
                                    Icons.monetization_on,
                                    color: Colors.white,
                                  )),
                              Text(
                                "SoldItems",
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
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Soldpage()));
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
                                  padding: EdgeInsets.only(top: 28.0),
                                  child: Icon(
                                    Icons.history,
                                    color: Colors.white,
                                  )),
                              Text(
                                "History",
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

Widget _buildTotals() {
  return ListView(
    scrollDirection: Axis.horizontal,
    children: _categoryTotals.entries.map((entry) {
      String category = entry.key;
      int total = entry.value ;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            category,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'GHC: $total',
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
