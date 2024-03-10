import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignStockPage extends StatefulWidget {
  @override
  _AssignStockPageState createState() => _AssignStockPageState();
}

class _AssignStockPageState extends State<AssignStockPage> {
  String? _selectedUser;
  String? _selectedProduct;
  // String? Email;
  double _totalPrice = 0.0;
  TextEditingController _quantityController = TextEditingController();
  String? _selectedCategory;
  String? _selectedUserEmail;

  Future<void> fetchUserEmail(value) async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').where('FullName', isEqualTo: value).get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _selectedUserEmail = querySnapshot.docs.first['Email'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Stock'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select User:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              FutureBuilder(
                future: FirebaseFirestore.instance.collection('users').get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  final users = snapshot.data?.docs
                      .map((doc) => doc['FullName'] as String)
                      .toList();

                  return DropdownButton(
                    value: _selectedUser,
                    onChanged: (value) {
                      setState(() {
                        _selectedUser = value;
                        fetchUserEmail(value!);
                      });
                    },
                    items: users?.map<DropdownMenuItem<String>>((String user) {
                      return DropdownMenuItem<String>(
                        value: user,
                        child: Text(user),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 20.0),
              Text('Select Product:'),
              FutureBuilder(
                future: FirebaseFirestore.instance.collection('Product').get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  final products = snapshot.data?.docs
                      .map((doc) => doc['Product'] as String)
                      .toList();
                  final productIds = snapshot.data?.docs.map((doc) => doc.id).toList(); // Added
                  final productMap = Map.fromIterables(products!, productIds!);


                  return Column(
                    children: [
                      DropdownButton(
                        value: _selectedProduct,
                        onChanged: (value) {
                          setState(() {
                            _selectedProduct = value;
                          });
                          print(
                              "Selected Product ID: ${productMap[value]}"); // Added
                        },
                        items: products
                            ?.map<DropdownMenuItem<String>>((String product) {
                          return DropdownMenuItem<String>(
                            value: product,
                            child: Text(product),
                          );
                        }).toList(),
                      ),
                      Text('Enter Quantity:'),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          double quantity =
                              double.tryParse(_quantityController.text) ?? 0.0;
                          if (quantity <= 0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Invalid Quantity"),
                                  content:
                                      Text("Please enter a valid quantity."),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Fetch price of selected product from Firestore
                            FirebaseFirestore.instance
                                .collection('Product')
                                .doc(productMap[_selectedProduct])
                                .get()
                                .then((doc) {
                              String? productId = productMap[_selectedProduct];
                              int price = doc.data()?['Cost'];
                              setState(() {
                                _totalPrice = quantity * price;
                                print("price" '$quantity');
                                print("prod: " '$productId');
                                // print("int"'$price');
                                // print("select"'$_selectedProduct');
                              });
                            });
                          }
                        },
                        child: Text('Calculate Total Price'),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20.0),
              Text('Total Price: ${_totalPrice}'),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Assign Stock"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Selected User: $_selectedUser"),
                            Text("Selected Product: $_selectedProduct"),
                            Text("Quantity: ${_quantityController.text}"),
                            Text("Total Price: $_totalPrice"),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {

                              // Logic to assign stock

                              FirebaseFirestore.instance.collection('AssignedStock').add({
                                'quantity': _quantityController.text,
                                'total': _totalPrice,
                                'ProductName': _selectedProduct,
                                'User': _selectedUser,
                                'Email': _selectedUserEmail?.toLowerCase().toString(),
                              }).then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Data written successfully')),
                                );
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to write data: $error')),
                                ); Navigator.of(context).pop();
                              });
                            },
                            child: Text('Assign'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Assign Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }



}
