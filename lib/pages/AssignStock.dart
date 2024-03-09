import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AssignStockDetails.dart';

class AssignStock extends StatefulWidget {
  const AssignStock({super.key});

  @override
  State<AssignStock> createState() => _AssignStockState();
}

class _AssignStockState extends State<AssignStock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AssignStockPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: Container(
                    height: 111,
                    width: 121,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black),
                    child: Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 28.0),
                            child: Icon(Icons.add_circle),
                          ),
                          Text(
                            "Assign User",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
            Container(
              height: 209,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('AssignedStock')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return AssignedUserCard(user: user);
                      },
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class AssignedUserCard extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> user;

  const AssignedUserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) => AssignStockPage(user: user),
        // ));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          title: Text(user['User']),
          // Assuming 'name' is a field in your document
          subtitle: Row(

            children: [
              Text('Total: GHS ${user['total']}'),
              Text('QTY: ${user['quantity']}'),
            ],
          ), // Assuming 'email' is a field in your document
          // Add more fields as needed
        ),
      ),
    );
  }
}
