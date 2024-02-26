import 'dart:io';
import 'dart:io' as io;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../color_palette.dart';
import '../../main.dart';
import '../models/addedProduct.dart';
import '../progressDialog.dart';

class addproduct extends StatefulWidget {
  const addproduct({Key? key, this.group, this.Farm, this.FinalCode})
      : super(key: key);
  final String? group;
  final String? FinalCode;
  final String? Farm;

  @override
  State<addproduct> createState() => _addproductState(
        group,
        Farm,
      );
}

class _addproductState extends State<addproduct> {
  List<String> dropdownOptions = [];
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  @override
  void initState() {
    super.initState();
    fetchDropdownOptions().then((options) {
      setState(() {
        dropdownOptions = options;
      });
    });
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  String? _selectedImage;
  String? group;
  String? farm;

  _addproductState(
    this.group,
    this.farm,
  );

  // final picker = ImagePicker();
  double val = 0;

  // final ImagePicker imagePicker = ImagePicker();
  bool uploading = false;
  final addedproduct newProduct = addedproduct();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? imgRef;
  firebase_storage.Reference? ref;

  String code = '';
  String randomCode = '';

  String generatedCode = '';
  String? setselectedval;

  final storage = FirebaseStorage.instance;
  final storageReference = FirebaseStorage.instance.ref();

  String? selectedImagePath;
  String? uploadedImageUrl;

  @override
  Widget build(BuildContext context) {
    String? currentSelectedValue;
    // var firstname = Provider
    //     .of<Users>(context)
    //     .userInfo
    //     ?.id!;
    var newprojectname = newProduct.name;

    // List<String> Category = ["Soap", "WashingPowder", "Diapers"];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Color(0xff202020),
        backgroundColor: Colors.white54,
        title: Row(
          children: [
            const Text(
              "New Product",
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 28,
                color: ColorPalette.timberGreen,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
          right: 10,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            calculateTotalSum();
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
            Occupationdb();
            newProduct.group = group;
            _firestore.collection("Product").add({
              //
              // 'image': url,
              'Category': currentSelectedValue,
              'Description': newProduct.description.toString(),
              'Product': newProduct.name,
              'Company': newProduct.company.toString(),
              'Cost': newProduct.cost,
              'location': newProduct.location,
              'quantity': newProduct.quantity,
              'Sum': calculateTotalSum(),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 50,
                                  ),
                                  margin: const EdgeInsets.only(top: 75),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffd5e2e3),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            bottom: 12,
                                          ),
                                          child: Column(
                                            children: [],
                                          ),
                                        ),
                                        DropdownButton<String>(
                                          value: currentSelectedValue,
                                          hint: Text("Choose Category"),
                                          items: dropdownOptions
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.category,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          8), // Add some space between icon and text
                                                  Text(value),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              currentSelectedValue = newValue;
                                              setselectedval == newValue;
                                              print(
                                                  'Selected value: $currentSelectedValue'); // Add this line
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: ColorPalette.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: const Offset(0, 3),
                                                blurRadius: 6,
                                                color: ColorPalette.nileBlue
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          height: 50,
                                          child: TextFormField(
                                            initialValue: newProduct.name ?? '',
                                            onChanged: (value) {
                                              newProduct.name = value;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            key: UniqueKey(),
                                            keyboardType: TextInputType.text,
                                            style: const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Product Name",
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              hintStyle: TextStyle(
                                                fontFamily: "Nunito",
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            cursorColor: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: ColorPalette.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      offset:
                                                          const Offset(0, 3),
                                                      blurRadius: 6,
                                                      color: ColorPalette
                                                          .nileBlue
                                                          .withOpacity(0.1),
                                                    ),
                                                  ],
                                                ),
                                                height: 50,
                                                child: TextFormField(
                                                  initialValue:
                                                      newProduct.cost == null
                                                          ? ''
                                                          : newProduct.cost
                                                              .toString(),
                                                  onChanged: (value) {
                                                    newProduct.cost =
                                                        int.parse(value);
                                                  },
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  key: UniqueKey(),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: const TextStyle(
                                                    fontFamily: "Nunito",
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Cost",
                                                    filled: true,
                                                    fillColor:
                                                        Colors.transparent,
                                                    hintStyle: TextStyle(
                                                      fontFamily: "Nunito",
                                                      fontSize: 16,
                                                      color: ColorPalette
                                                          .nileBlue
                                                          .withOpacity(0.58),
                                                    ),
                                                  ),
                                                  cursorColor: Colors.green,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: ColorPalette.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      offset:
                                                          const Offset(0, 3),
                                                      blurRadius: 6,
                                                      color: ColorPalette
                                                          .nileBlue
                                                          .withOpacity(0.1),
                                                    ),
                                                  ],
                                                ),
                                                height: 50,
                                                child: TextFormField(
                                                  initialValue:
                                                      newProduct.quantity ==
                                                              null
                                                          ? ''
                                                          : newProduct.quantity
                                                              .toString(),
                                                  onChanged: (value) {
                                                    newProduct.quantity =
                                                        int.parse(value);
                                                  },
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  key: UniqueKey(),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: const TextStyle(
                                                    fontFamily: "Nunito",
                                                    fontSize: 16,
                                                    color:
                                                        ColorPalette.nileBlue,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Quantity",
                                                    filled: true,
                                                    fillColor:
                                                        Colors.transparent,
                                                    hintStyle: TextStyle(
                                                      fontFamily: "Nunito",
                                                      fontSize: 16,
                                                      color: ColorPalette
                                                          .nileBlue
                                                          .withOpacity(0.58),
                                                    ),
                                                  ),
                                                  cursorColor:
                                                      ColorPalette.timberGreen,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: ColorPalette.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: const Offset(0, 3),
                                                blurRadius: 6,
                                                color: ColorPalette.nileBlue
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          height: 50,
                                          child: TextFormField(
                                            initialValue:
                                                newProduct.company ?? '',
                                            onChanged: (value) {
                                              newProduct.company = value;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            key: UniqueKey(),
                                            keyboardType: TextInputType.text,
                                            style: const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 16,
                                              color: ColorPalette.nileBlue,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Company",
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              hintStyle: TextStyle(
                                                fontFamily: "Nunito",
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            cursorColor: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white70,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: const Offset(0, 3),
                                                blurRadius: 6,
                                                color: ColorPalette.nileBlue
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          height: 50,
                                          child: TextFormField(
                                            initialValue:
                                                newProduct.description ?? '',
                                            onChanged: (value) {
                                              newProduct.description = value;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            key: UniqueKey(),
                                            keyboardType: TextInputType.text,
                                            style: const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Description",
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              hintStyle: TextStyle(
                                                fontFamily: "Nunito",
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            cursorColor:
                                                ColorPalette.timberGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white70,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: const Offset(0, 3),
                                                blurRadius: 6,
                                                color: ColorPalette.nileBlue
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          height: 50,
                                          child: TextFormField(
                                            initialValue:
                                                newProduct.location ?? '',
                                            onChanged: (value) {
                                              newProduct.location = value;
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            key: UniqueKey(),
                                            keyboardType: TextInputType.text,
                                            style: const TextStyle(
                                              fontFamily: "Nunito",
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Location",
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              hintStyle: TextStyle(
                                                fontFamily: "Nunito",
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            cursorColor:
                                                ColorPalette.timberGreen,
                                          ),
                                        ),

                                        SizedBox(height: 20),
                                        // Text(
                                        //   'Total: ${calculateTotalSum()}',
                                        //   style: TextStyle(fontSize: 16),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Occupationdb() async {
    Map userDataMap = {
      'ProductImage': url.toString(),
      'Name': group,
      'description': newProduct.description.toString(),
      'group': newProduct.group.toString(),
      'Company': newProduct.company.toString(),
      'Cost': newProduct.cost,
      'quantity': newProduct.quantity.toString(),
    };

    Products.child("Product").set(userDataMap);
  }

  Future<List<String>> fetchDropdownOptions() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('utils')
        .doc('ProductCategory')
        .get();
    List<String> options = [];
    if (documentSnapshot.exists) {
      dynamic data = documentSnapshot.data();
      if (data != null && data['list'] != null) {
        List<dynamic> values = data['list'];
        options.addAll(values.map((value) => value.toString()));
      }
    }
    return options;
  }

  int calculateTotalSum() {
    int sum = 0;
    int? quantity = int.tryParse(newProduct.quantity.toString());
    int? cost = int.tryParse(newProduct.cost.toString());
    if (quantity != null && cost != null) {
      sum = quantity * cost;
    }
    return sum;
  }
}
