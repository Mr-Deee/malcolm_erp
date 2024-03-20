import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Soldpage extends StatefulWidget {
  const Soldpage({Key? key}) : super(key: key);

  @override
  State<Soldpage> createState() => _SoldpageState();
}

class _SoldpageState extends State<Soldpage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sold Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    // Show date picker and update selected date
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    'Select Date: ${_selectedDate != null ? _selectedDate!.toString().split(' ')[0] : "None"}',
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = null; // Reset selected date to null
                    });
                  },
                  child: Text('Show All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedDate != null
                  ? FirebaseFirestore.instance
                  .collection('SoldQuantity')
                  .where('timestamp',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(
                      DateTime(_selectedDate!.year,
                          _selectedDate!.month, _selectedDate!.day)))
                  .where('timestamp',
                  isLessThanOrEqualTo: Timestamp.fromDate(
                      DateTime(_selectedDate!.year,
                          _selectedDate!.month, _selectedDate!.day, 23, 59, 59)))
                  .snapshots()
                  : FirebaseFirestore.instance.collection('SoldQuantity').snapshots(),
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
                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No data available for the selected date.'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var productName = doc['ProductName'];
                    var quantitySold = doc['soldQuantity'];
                    var amountSold = doc['totalSales'];
                    var perUnit = doc['perUnit'];

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: Icon(Icons.money_rounded),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(productName),
                            Text('Per Unit: $perUnit'),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Quantity Sold: $quantitySold'),
                            Text('Total: $amountSold'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Add functionality for tapping on the item if needed
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
