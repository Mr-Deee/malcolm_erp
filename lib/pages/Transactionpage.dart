import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Transactionpage extends StatefulWidget {
  const Transactionpage({super.key});

  @override
  State<Transactionpage> createState() => _TransactionpageState();
}

class _TransactionpageState extends State<Transactionpage> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('utils').doc('ProductCategory').snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.hasData && snapshot.data!.exists) {
              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> categories = data['list'];
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String categoryName = categories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = categoryName;
                      });
                    },
                    child: GestureDetector(
                      onTap:(){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => CategoryDetailsPage(categoryName),
                        )
                        );},
                      child: Card(
                        child: ListTile(
                          title: Text(categoryName),
                          leading: Icon(Icons.category),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return Text('No categories found');
          },
        ),
      ),

    );
  }
}




class CategoryDetailsPage extends StatefulWidget {
  final String categoryName;
  CategoryDetailsPage(this.categoryName);

  @override
  _CategoryDetailsPageState createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Category Details - ${widget.categoryName}"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search by first three letters',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Product')
                  .where('Category', isEqualTo: widget.categoryName)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  var products = snapshot.data!.docs;
                  var filteredProducts = searchText.length >= 3
                      ? products.where((product) =>
                      product['Product']
                          .toString()
                          .toLowerCase()
                          .startsWith(searchText.toLowerCase().substring(0, 3)))
                      : products;
                  if (filteredProducts.isEmpty) {
                    return Text('No products found matching the search');
                  }
                  return _buildProductList(filteredProducts.toList());
                }
                return Text('No products found in this category');
              },
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController quantityController = TextEditingController();

  // Widget _buildProductList(List<DocumentSnapshot> products) {
  //   return ListView.builder(
  //     itemCount: products.length,
  //     itemBuilder: (context, index) {
  //       var product = products[index].data() as Map<String, dynamic>;
  //       var productName = product['Product'] as String;
  //       var productCost = (product['Cost'] as num).toDouble();
  //       var productQuantity = product['quantity'] as int;
  //       var productTotal = productCost * productQuantity;
  //
  //       return Card(
  //         color: Colors.black87,
  //         elevation: 4,
  //         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //         child: ListTile(
  //           title: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(productName,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
  //               Text('Cost: $productCost',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
  //             ],
  //           ),
  //           subtitle: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //
  //               // Text('Quantity: $productQuantity'),
  //               // Text('Total: $productTotal'),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //
  //                 children: [
  //
  //                   SizedBox(
  //                     width: 80,
  //                     child: TextField(
  //
  //                       controller: quantityController,
  //                       cursorColor: Colors.white,
  //                       keyboardType: TextInputType.number,
  //                       onChanged: (value) {
  //                         // You can add your logic to update quantity sold here
  //                       },
  //                       decoration: InputDecoration(
  //                         hintText: 'QTY ',
  //                         hintStyle: TextStyle(
  //                           color: Colors.black, // Change color of hint text
  //                           fontStyle: FontStyle.italic, // Apply italic style to hint text
  //                           fontSize: 16, // Adjust font size of hint text
  //                           fontWeight: FontWeight.normal, // Adjust font weight of hint text
  //                           // Add more text style properties as needed
  //                         ),
  //                         fillColor: Colors.white, // Add color for the text field background
  //                         filled: true,
  //                       ),
  //
  //                     ),
  //
  //                   ),
  //                   SizedBox(width: 12),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       // Parse the quantity entered in TextField
  //                       double soldQuantity = double.tryParse(quantityController.text) ?? 0;
  //
  //                       // Check if quantity is valid and greater than 0
  //                       if (soldQuantity <= 0) {
  //                         showDialog(
  //                           context: context,
  //                           builder: (context) {
  //                             return AlertDialog(
  //                               title: Text('Invalid Quantity'),
  //                               content: Text('Please enter a valid quantity.'),
  //                               actions: [
  //                                 TextButton(
  //                                   onPressed: () {
  //                                     Navigator.of(context).pop();
  //                                   },
  //                                   child: Text('OK'),
  //                                 ),
  //                               ],
  //                             );
  //                           },
  //                         );
  //                         return; // Exit the function if quantity is invalid
  //                       }
  //
  //                       double soldPrice = productCost * soldQuantity;
  //
  //                       FirebaseFirestore.instance.runTransaction((transaction) async {
  //                         // Retrieve the document reference of the product
  //                         DocumentReference productRef = FirebaseFirestore.instance.collection('Product').doc(products[index].id);
  //
  //                         // Get the latest data of the product
  //                         DocumentSnapshot snapshot = await transaction.get(productRef);
  //
  //                         // Update the quantity and total amount
  //                         int newQuantity = (snapshot['quantity'] as int) - soldQuantity.toInt();
  //                         double newTotal = (snapshot['Sum'] as int) - soldPrice;
  //
  //                         // Check if new quantity is valid
  //                         if (newQuantity < 0) {
  //                           showDialog(
  //                             context: context,
  //                             builder: (context) {
  //                               return AlertDialog(
  //                                 title: Text('Invalid Quantity'),
  //                                 content: Text('The quantity entered exceeds the available quantity.'),
  //                                 actions: [
  //                                   TextButton(
  //                                     onPressed: () {
  //                                       Navigator.of(context).pop();
  //                                     },
  //                                     child: Text('OK'),
  //                                   ),
  //                                 ],
  //                               );
  //                             },
  //                           );
  //                           return; // Exit the transaction if quantity is invalid
  //                         }
  //
  //                         // Update the product data in Firestore
  //                         transaction.update(productRef, {
  //                           'quantity': newQuantity,
  //                           'sum': newTotal,
  //                         });
  //                         // Show dialog for approved amount
  //                         showDialog(
  //                             context: context,
  //                             builder: (context)
  //                         {
  //                           return AlertDialog(
  //                             title: Text('Sale Approved'),
  //                             content: Text(
  //                                 'The approved Quantity is $soldQuantity & Total is $soldPrice.'),
  //                             actions: [
  //                               TextButton(
  //                                 onPressed: () {
  //                                   Navigator.of(context).popUntil((
  //                                       route) => route.isFirst);
  //                                 },
  //                                 child: Text('Done'),
  //                               ),
  //                             ],
  //                           );
  //
  //                     });
  //                         // Optionally, you can update the total amount in another document or collection
  //                       });
  //                     },
  //                     child: Text('Approve',style: TextStyle(color: Colors.black),),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildProductList(List<DocumentSnapshot> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        var product = products[index];
        return ListTile(
          title: Text(product['Product']),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Price: \GHS${product['Cost']}'),
              Text('Quantity: ${product['quantity']}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () {
                  _showQuantityDialog(context, product);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuantityDialog(BuildContext context, DocumentSnapshot product) {
    var productName = product['Product'] as String;
    var productCost = (product['Cost'] as num).toDouble();
    var productQuantity = product['quantity'] as int;
    var productTotal = productCost * productQuantity;

    int soldQuantity = 1; // default sold quantity

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                        title: Text('Select Quantity'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  soldQuantity = int.tryParse(value) ?? 1;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (soldQuantity <= 0) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Invalid Quantity'),
                                      content: Text(
                                          'Please enter a valid quantity.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return; // Exit the function if quantity is invalid
                              }

                              double soldPrice = productCost * soldQuantity;

                              FirebaseFirestore.instance.runTransaction((
                                  transaction) async {
                                // Retrieve the document reference of the product
                                DocumentReference productRef = FirebaseFirestore
                                    .instance
                                    .collection('Product').doc(product.id);

                                // Get the latest data of the product
                                DocumentSnapshot snapshot = await transaction
                                    .get(
                                    productRef);

                                // Update the quantity and total amount
                                int newQuantity = (snapshot['quantity'] as int) -
                                    soldQuantity;
                                double newTotal = (snapshot['Sum'] as int) -
                                    soldPrice;

                                // Check if new quantity is valid
                                if (newQuantity < 0) {
                                  showDialog(
                                    context: Navigator
                                        .of(context)
                                        .context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Quantity'),
                                        content: Text(
                                            'The quantity entered exceeds the available quantity.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return; // Exit the transaction if quantity is invalid
                                }

                                // Update the product data in Firestore
                                transaction.update(productRef, {
                                  'quantity': newQuantity,
                                  'sum': newTotal,
                                });

                                // Show dialog for approved amount
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return
                                        AlertDialog(
                                          title: Text('Sale Approved'),
                                          content: Text(
                                              'The approved Quantity is $soldQuantity & Total is $soldPrice.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).popUntil((
                                                    route) => route.isFirst);
                                              },
                                              child: Text('Done'),
                                            ),
                                          ],
                                        );
                                    }
                                );
                              },
                              );
                              // Optionally, you can update the total amount in another document or collection
                            }, child: Text('Approve'),
                          )
                        ]
                    );

                    Navigator.pop(context); // Close the dialog
                  },

                );
              }

          );
        }
    );
  }

}


