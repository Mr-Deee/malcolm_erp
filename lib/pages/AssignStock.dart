import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malcolm_erp/pages/COB.dart';
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
      appBar: AppBar(
        title: Text("Assign Stock"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height:168,
                  child: Card(
                    elevation: 3.0,
                    color: Colors.white, // Set background color of the card
                    child:
                  Row(
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
                                  color: Colors.white),
                              child: Container(
                                height: 130,
                                width: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black87),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 28.0),
                                      child: Icon(Icons.add_circle,color: Colors.white,),
                                    ),
                                    Text(
                                      "Assign User",
                                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),

                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => COB()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 38.0),
                            child: Container(
                              height: 111,
                              width: 121,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white),
                              child: Container(
                                height: 130,
                                width: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black87),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 28.0),
                                      child: Icon(Icons.close,color: Colors.white,),
                                    ),
                                    Text(
                                      "COB",
                                      style: TextStyle( color: Colors.white,fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),

                    ],
                  ),
                  ),
                ),
              ),
              SizedBox(height: 29,),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height:  MediaQuery.of(context).size.height,
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
                  ),
                ),
              )
            ],
          ),
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [


              Row(

                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Icon(Icons.border_inner,color: Colors.black,),
                  ),
                  Text(user['ProductName']),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Icon(Icons.person,color: Colors.black,),
                  ),
                  Text(user['User']),
                ],
              ),

            ],
          ),
          // Assuming 'name' is a field in your document
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Icon(Icons.money_rounded,color: Colors.black,),
                  ),
                  Text('Total: GHS ${user['total']}'),

                ],
              ),
                   Text('QTY: ${user['quantity']}'),
            ],
          ), // Assuming 'email' is a field in your document
          // Add more fields as needed
        ),
      ),
    );
  }
}
