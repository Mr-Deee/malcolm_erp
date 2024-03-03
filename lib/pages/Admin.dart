import 'package:flutter/cupertino.dart';
import '../Assistant/assistantmethods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}
Map<String, int> _categoryTotals = {};

class _AdminState extends State<Admin> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
    _fetchProductCategories();
  }

  Future<void> _fetchProductCategories() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('Product').get();

      Map<String, int> categoryTotals = {};

      snapshot.docs.forEach((doc) {
        String category = doc['Category'];
        int price = doc['Sum'];

        categoryTotals[category] = (categoryTotals[category] ?? 0) + price;
      });

      setState(() {
        _categoryTotals = categoryTotals;
      });
    } catch (error) {
      print('Error fetching product categories: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Widget _buildTotals() {
  return ListView(
    scrollDirection: Axis.horizontal,
    children: _categoryTotals.entries.map((entry) {
      String category = entry.key;
      int total = entry.value ?? 0;
      return Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            category,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'GHC: $total',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],

      );
    }).toList(),
  )

  ;
}
