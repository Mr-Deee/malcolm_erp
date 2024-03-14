import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malcolm_erp/pages/Sold.dart';
import '../Assistant/assistantmethods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../models/Admin.dart';
import 'Inventory.dart';

class Adminpage extends StatefulWidget {
  const Adminpage({Key? key});

  @override
  State<Adminpage> createState() => _AdminpageState();
}

Map<String, double> _itemTotals = {};

class _AdminpageState extends State<Adminpage> {
  @override
  void initState() {
    super.initState();
    AssistantMethod.getAminInfo(context);
    _fetchProductCategories();
  }

  Future<void> _fetchProductCategories() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('SoldQuantity').get();

      Map<String, double> categoryTotals = {};

      snapshot.docs.forEach((doc) {
        String category = doc['ProductName'];
        double price = doc['totalSales'];

        categoryTotals[category] = (categoryTotals[category] ?? 0) + price;
      });

      setState(() {
        _itemTotals = categoryTotals;
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
      appBar: AppBar(
        title:  Text(
          CompanyName,
          style: TextStyle(
            fontFamily: "Nunito",
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        actions: [ IconButton(
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
                        FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/SignIn", (route) => false);
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
        ),],
      ),
      body: Container(

          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Dashboard",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),

              SizedBox(
                height: 55,
                child: Container(


                  child: _itemTotals.isNotEmpty
                      ? _buildTotals()
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Inventory()));
                        },
                        child: Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black87,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory,
                                color: Colors.white,
                                size: 40,
                              ),
                              SizedBox(height: 10),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Soldpage()));
                      },
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black87,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Sold Items",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Soldpage()));
                },
                child: Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black87,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 10),
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
            ],
          ),



      ),
    );
  }
}

Widget _buildTotals() {
  return ListView(
    scrollDirection: Axis.horizontal,
    children: _itemTotals.entries.map((entry) {
      String category = entry.key;
      double total = entry.value;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'GHC: $total',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
