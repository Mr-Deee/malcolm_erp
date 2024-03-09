import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
                onTap:(){
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              AssignStockPage()));

      },
                child: Padding(

                  padding: const EdgeInsets.only(left: 38.0),
                  child: Container(
                    height: 91,
                    width: 121,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.redAccent
                    ),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Add User"),
                      )),
                ))
          ],
        ),
      ),
    );
  }
}
