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
import 'homepage.dart';

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
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime)
      setState(() {
        _selectedTime = pickedTime;
      });
  }

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
  String? currentSelectedValue;

  final storage = FirebaseStorage.instance;
  final storageReference = FirebaseStorage.instance.ref();

  @override
  Widget build(BuildContext context) {
    bool _validateForm() {
      if (newProduct.name == null || newProduct.name!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a product name'),
          ),
        );
        return false;
      }  if (newProduct.name == null || newProduct.name!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a product name'),
          ),
        );
        return false;
      }

      // Add validations for other fields if needed...

      return true;
    }
    // var firstname = Provider
    //     .of<Users>(context)
    //     .userInfo
    //     ?.id!;
    var newprojectname = newProduct.name;
    inventorydb() async {
      _firestore.collection("Inventory").add({
        'Date': _selectedDate.toString(),
        'Time': _selectedTime.toString(),
        'Category': currentSelectedValue,
        'Product': newProduct.name,
        'Cost': newProduct.cost,
        'quantity': newProduct.quantity,
        'Sum': calculateTotalSum(),
      }).then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }).catchError((e) {
        // displayToast('Failed!'context);
      });
    }

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
            inventorydb();
            Occupationdb();
            newProduct.group = group;
            _firestore.collection("Product").add({
              'Date': _selectedDate.toString(),
              'Time': _selectedTime.toString(),
              'Category': currentSelectedValue,
              'Product': newProduct.name,
              'Company': newProduct.company.toString(),
              'Cost': newProduct.cost,
              'location': newProduct.location,
              'quantity': newProduct.quantity,
              'Sum': calculateTotalSum(),
            }).then((value) {

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Product added successfully!'),
                duration: Duration(seconds: 2),
              ));

              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
              // displayToast('Added Sucessfully!'context);
            }).catchError((e) {

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to add product. Please try again.'),
              duration: Duration(seconds: 2),));
            });
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
                                          hint: Text(
                                              currentSelectedValue.toString()),
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



                                        SizedBox(height: 20),

                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time),
                                            SizedBox(width: 10),
                                            Text(
                                              "${_selectedTime.format(context)}",
                                            ),
                                            SizedBox(width: 10),
                                            Icon(Icons.calendar_today),
                                            SizedBox(width: 10),
                                            Text(
                                              "${_selectedDate.toLocal()}"
                                                  .split(' ')[0],
                                            ),
                                          ],
                                        ),

                                        // Your existing TextFormField widgets
                                        SizedBox(height: 20),
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
      'Sum':calculateTotalSum(),
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
