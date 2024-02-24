import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory"),
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 230,
                  width: 392,
                  child: Text("Category1"),

                ),

                Container(
                  height: 230,
                  width: 392,
                  child: Text("Category"),

                ),
              ],
            ),

            Container()
          ],
        ),
      ),
    );
  }
}
