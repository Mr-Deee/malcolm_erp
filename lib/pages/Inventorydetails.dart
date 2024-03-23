import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Inventorydetails extends StatefulWidget {
  Inventorydetails({Key? key, this.categoryName}) : super(key: key);
  final String? categoryName;

  @override
  State<Inventorydetails> createState() => _InventorydetailsState();
}

class _InventorydetailsState extends State<Inventorydetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Details"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Product') // Assuming inventory data is stored in a collection named 'inventory'
              .where('Category', isEqualTo: widget.categoryName) // Filter by category name
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var document = snapshot.data!.docs[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            document['Product'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'GHS: ${document['Sum']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),

                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),

                          SizedBox(height: 5),
                          Text(
                            'QTY: ${document['quantity']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Date: ${document['Date']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(document);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteDialog(document);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Text(
                'No inventory items found for this category.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Inventory Item'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && _passwordController.text == 'your_predefined_password') {
                  // Perform edit operation
                  // Example: Navigator.of(context).pop(); to close the dialog
                  // Implement your edit logic here
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Inventory Item'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform delete operation
                // Example: Navigator.of(context).pop(); to close the dialog
                // Implement your delete logic here
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
