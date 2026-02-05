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
  double? sumone;
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

  bool _validateForm() {
    if (newProduct.name!.isEmpty) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Please enter a product name'),
        ),
      );
      return false;
    } else if (newProduct.cost == null || newProduct.cost! <= 0) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid cost'),
        ),
      );
      return false;
    } else if (newProduct.quantity == null || newProduct.quantity! <= 0) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid quantity'),
        ),
      );
      return false;
    }

    // Add validations for other fields if needed...

    return true;
  }

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
      }
      if (newProduct.name == null || newProduct.name!.isEmpty) {
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
      _firestore.collection("History").add({
        'Date': _selectedDate.toString(),
        'Time': _selectedTime.toString(),
        'Category': currentSelectedValue,
        'Product': newProduct.name,
        'Cost': newProduct.cost,
        'quantity': newProduct.quantity,
        'Sum': calculateTotalSum(),
      }).then((value) {
        Navigator.of(context).pop();

      }).catchError((e) {
        // displayToast('Failed!'context);
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Color(0xff202020),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Text(
              "Add New Product",
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 24,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Help',
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 30,
          right: 20,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            if (!_validateForm()) {
              return;
            }

            calculateTotalSum();
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return ProgressDialog(
                    message: "Adding New Product, Please wait...",
                  );
                });

            inventorydb();

            final QuerySnapshot snapshot = await _firestore
                .collection("Product")
                .where("Product", isEqualTo: newProduct.name)
                .get();
            newProduct.group = group;
            if (snapshot.docs.isNotEmpty) {
              final DocumentSnapshot firstDoc = snapshot.docs.first;

              int existingQuantity = firstDoc['quantity'];
              double existingSum = firstDoc['Sum'];

              int newQuantity = existingQuantity;
              double newSum = existingSum;

              newQuantity += newProduct.quantity!;
              newSum += calculateTotalSum() as double;

              await firstDoc.reference.update({
                'Date': _selectedDate.toString(),
                'Time': _selectedTime.toString(),
                'Category': currentSelectedValue,
                'Product': newProduct.name,
                'Cost': newProduct.cost,
                'quantity': newQuantity,
                'Sum': newSum,
              }).then((value) {
                displayToast('Added Successfully!',context);
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to add product. Please try again.'),
                  duration: Duration(seconds: 2),
                ));
              });
            } else {
              _firestore.collection("Product").add({
                'Date': _selectedDate.toString(),
                'Time': _selectedTime.toString(),
                'Category': currentSelectedValue,
                'Product': newProduct.name,
                'Cost': newProduct.cost,
                'quantity': newProduct.quantity,
                'Sum': calculateTotalSum(),
              }).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Product added successfully!'),
                  duration: Duration(seconds: 2),
                ));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }).catchError((e) {
                displayToast('Added Successfully!',context);
              });
            }
          },
          splashColor: Colors.blue,
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.done,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_circle_outlined,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Product Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fill in the details below to add a new product',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date and Time Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimeCard(
                            icon: Icons.calendar_today,
                            title: 'Date',
                            value: "${_selectedDate.toLocal()}".split(' ')[0],
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateTimeCard(
                            icon: Icons.access_time,
                            title: 'Time',
                            value: _selectedTime.format(context),
                            onTap: () => _selectTime(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        // marginBottom: 20,
                      ),
                    ),

                    // Category Dropdown
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                currentSelectedValue?.toString() ?? 'Select Category',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              items: dropdownOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.category,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  currentSelectedValue = newValue;
                                  setselectedval == newValue;
                                });
                              },
                              underline: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Product Name
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Name *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextFormField(
                              initialValue: newProduct.name ?? '',
                              onChanged: (value) {
                                newProduct.name = value;
                              },
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Product Name",
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                hintStyle: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              cursorColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cost and Quantity
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cost (GHS) *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: TextFormField(
                                    initialValue: newProduct.cost == null
                                        ? ''
                                        : newProduct.cost.toString(),
                                    onChanged: (value) {
                                      newProduct.cost = double.tryParse(value);
                                      calculateSum();
                                    },
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontFamily: "Nunito",
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Cost",
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      hintStyle: TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    cursorColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: TextFormField(
                                    initialValue: newProduct.quantity == null
                                        ? ''
                                        : newProduct.quantity.toString(),
                                    onChanged: (value) {
                                      newProduct.quantity = int.tryParse(value);
                                      calculateSum();
                                    },
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontFamily: "Nunito",
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Quantity",
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      hintStyle: TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    cursorColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: calculateSum,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate Total'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Calculation Result
              if (sumone != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Value',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'GHS ${sumone!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${newProduct.quantity ?? 0} units × GHS ${newProduct.cost?.toStringAsFixed(2) ?? '0.00'} each',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit, size: 16, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
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

  void calculateSum() {
    int? quantity = int.tryParse(newProduct.quantity.toString());
    double? cost = double.tryParse(newProduct.cost.toString());
    if (quantity != null && cost != null) {
      sumone = quantity * cost;
    }

    setState(() {
      if (quantity != null && cost != null) {
        sumone = quantity * cost;
      }
    });
  }

  double calculateTotalSum() {
    double sum = 0;
    int? quantity = int.tryParse(newProduct.quantity.toString());
    double? cost = double.tryParse(newProduct.cost.toString());
    if (quantity != null && cost != null) {
      sum = quantity * cost;
    }
    return sum;
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Product Guide'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpItem(
                  icon: Icons.category,
                  title: 'Category',
                  description: 'Select the product category from the dropdown list',
                ),
                _buildHelpItem(
                  icon: Icons.shopping_bag,
                  title: 'Product Name',
                  description: 'Enter the name of the product you want to add',
                ),
                _buildHelpItem(
                  icon: Icons.attach_money,
                  title: 'Cost & Quantity',
                  description: 'Enter the unit price and quantity of the product',
                ),
                _buildHelpItem(
                  icon: Icons.calculate,
                  title: 'Calculate',
                  description: 'Click calculate to see the total value',
                ),
                _buildHelpItem(
                  icon: Icons.save,
                  title: 'Save',
                  description: 'Save the product to your inventory',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}