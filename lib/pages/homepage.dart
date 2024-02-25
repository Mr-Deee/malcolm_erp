import 'dart:ui';
import 'package:malcolm_erp/pages/Inventory.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:malcolm_erp/Assistant/assistantmethods.dart';
import 'package:malcolm_erp/models/Admin.dart';
import '../../color_palette.dart';
import '../../progressDialog.dart';
import '../models/addedProduct.dart';
import 'Transactionpage.dart';
import 'addproduct.dart';
import 'allexpenses.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final TextEditingController _newProductGroup = TextEditingController();

  final addedproduct newfarm = addedproduct();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    String CompanyName = Provider.of<Admin>(context).admininfo?.CompanyName ?? "getting name...";
    double _sigmaX = 5; // from 0-10
    double _sigmaY = 5; // from 0-10
    double _opacity = 0.2;
    double _width = 350;
    double _height = 300;
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
                SizedBox(height: 45,),

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
                          child:  Text(
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
                                          style: TextStyle(
                                              color: Colors.black),
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
                                          style:
                                          TextStyle(color: Colors.red),
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

                SizedBox(height: 45,),
                Row(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.blue                 ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 18.0),
                                  child: IconButton(onPressed: (){
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => addproduct())
                                    );
                                            //(Route<dynamic> route) => false);
                                  }, icon: Icon(Icons.add_circle)),
                                ),
                                Text("Add New\n Product",style: TextStyle(fontWeight: FontWeight.bold),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 45,),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black87                 ),
                            child: Column(
                              children: [

                                Padding(
                                  padding:  EdgeInsets.only(top: 18.0),
                                  child: IconButton(onPressed: (){
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => Transactionpage())
                                    );
                                    //(Route<dynamic> route) => false);
                                  }, icon: Icon(Icons.inventory)),
                                ),
                                Text("Transaction",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),

                SizedBox(height: 45,),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black87                 ),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: IconButton(onPressed: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => Inventory())
                                );
                                //(Route<dynamic> route) => false);
                              }, icon: Icon(Icons.inventory)),
                            ),
                            Text("View\nInventory",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)
                          ],
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
    ;
  }
}

displayToast(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
