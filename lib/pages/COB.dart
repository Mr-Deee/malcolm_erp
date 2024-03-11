import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class COB extends StatefulWidget {
  const COB({super.key});

  @override
  State<COB> createState() => _COBState();
}

class _COBState extends State<COB> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Close Of Business"),
      ),
      backgroundColor: Colors.black38,

      body: Column(
        children: [

          Container(child: Text("",style: TextStyle(fontSize: 30,color: Colors.white),),)
        ],
      ),
    );
  }
}
