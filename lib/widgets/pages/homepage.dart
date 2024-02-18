import 'dart:ui';
import 'package:malcolm_erp/widgets/pages/addfarm.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:malcolm_erp/Assistant/assistantmethods.dart';
import 'package:malcolm_erp/models/Admin.dart';

import '../../color_palette.dart';
import '../../models/addedFarm.dart';
import '../../progressDialog.dart';
import '../farm_group_card.dart';
import 'allexpenses.dart';
import 'farm_group_page.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final TextEditingController _newProductGroup = TextEditingController();

  final addedFarm newfarm = addedFarm();
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
          right: 10,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return ProgressDialog(
                    message: "Adding New Product,Please wait.....",
                  );
                });
            //   String? url = await  uploadImage(selectedImagePath!);
            //    uploadsFile();
            //uploadImage(selectedImagePath!);
            // Occupationdb();
            // newProduct.group = group;
            _firestore.collection("Expenses").add({
              //
              // 'image': url,
              // 'ExpenseType': group,
              //'FarmCodep': currentSelectedValue.toString(),
              // 'FarmCodes': FinalCode,

              //newProduct.name.toString(),
              'description': newProduct.description.toString(),
              // 'Farm': farm,
              // 'name': group,
              'Company': newProduct.company.toString(),
              'Cost': newProduct.cost,
              // 'location': farm,
              'quantity': newProduct.quantity,
              //newProduct.toMap()
            }).then((value) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // displayToast('Added Sucessfully!'context);
            }).catchError((e) {
              // displayToast('Failed!'context);
            });
            // Navigator.of(context).pop();
          },
          splashColor: Colors.blue,
          backgroundColor: Colors.white54,
          child: const Icon(
            Icons.done,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/backdrop.png'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 45,),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white
                  ),
                  child: IconButton(onPressed: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => addfarm())
                    );
                            //(Route<dynamic> route) => false);
                  }, icon: Icon(Icons.add_circle)),
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
