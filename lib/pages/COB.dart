import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class COB extends StatefulWidget {
  const COB({super.key});

  @override
  State<COB> createState() => _COBState();
}

class _COBState extends State<COB> {

  /// CLOSE OF BUSINESS LOGIC
  Future<void> _closeBusiness(String productId) async {
    final firestore = FirebaseFirestore.instance;

    /// 1️⃣ GET SOLD DATA FIRST
    final soldSnapshot = await firestore
        .collection('SoldQuantity')
        .where('productId', isEqualTo: productId)
        .get();

    int soldQty = 0;
    double soldTotal = 0;

    for (var doc in soldSnapshot.docs) {
      soldQty += (doc['soldQuantity'] ?? 0) as int;
      soldTotal += (doc['totalSales'] ?? 0).toDouble();
    }

    /// 2️⃣ GET PRODUCT
    final productRef = firestore.collection('Product').doc(productId);
    final productSnap = await productRef.get();

    if (!productSnap.exists) return;

    final int currentQty = productSnap['quantity'];
    final double cost = productSnap['Cost'];

    final int remainingQty = currentQty - soldQty;
    final double newTotalCost = remainingQty * cost;
    final double remainingSum = newTotalCost - soldTotal;

    /// 3️⃣ UPDATE PRODUCT INVENTORY
    await productRef.update({
      'quantity': remainingQty,
      'totalCost': newTotalCost,
      'Sum': remainingSum,
      'status': remainingQty > 0 ? 'Available' : 'Out of Stock',
    });

    /// 4️⃣ DELETE SOLD RECORDS
    for (var doc in soldSnapshot.docs) {
      await doc.reference.delete();
    }

    /// 5️⃣ REMOVE FROM ASSIGNED STOCK
    await firestore.collection('AssignedStock').doc(productId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Close Of Business",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        /// ✅ SHOW ONLY ASSIGNED STOCK WHERE COB == TRUE
        stream: FirebaseFirestore.instance
            .collection('AssignedStock')
            .where('COB', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No items for COB"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc['ProductName']),
                  subtitle: Text("Product ID: ${doc['ProductID']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      _closeBusiness(doc['ProductID']);
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
