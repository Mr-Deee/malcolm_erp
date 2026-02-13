import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class COB extends StatefulWidget {
  const COB({super.key});

  @override
  State<COB> createState() => _COBState();
}

class _COBState extends State<COB> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool loading = false;

  /* ---------------- CONFIRM DIALOG ---------------- */

  Future<bool> _confirmCOB(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Confirm Close Of Business",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Close"),
          ),
        ],
      ),
    ) ??
        false;
  }

  /* ---------------- CORE COB LOGIC ---------------- */

  Future<void> _closeBusiness(DocumentSnapshot assignedDoc) async {
    final batch = firestore.batch();
    final now = FieldValue.serverTimestamp();
    final businessDate =
    DateTime.now().toIso8601String().substring(0, 10);

    final assignedRef = assignedDoc.reference;
    final assigned =
    assignedDoc.data() as Map<String, dynamic>;

    final String productId = assigned['ProductID'];

    final int openingStock = assigned['quantity'] ?? 0;
    final double costPer =
    (assigned['Costper'] ?? 0).toDouble();
    final double openingValue = openingStock * costPer;

    /* -------- GET SOLD DATA -------- */

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

    /* -------- CALCULATE CLOSING -------- */

    final int closingStock =
    (openingStock - soldQty).clamp(0, openingStock);

    final double closingValue = closingStock * costPer;

    /* -------- MOVE TO SALES HISTORY -------- */

    final salesRef =
    firestore.collection('Sales').doc();

    batch.set(salesRef, {
      'productId': productId,
      'productName': assigned['ProductName'],
      'user': assigned['User'],
      'email': assigned['Email'],

      'openingStock': openingStock,
      'openingValue': openingValue,

      'soldQuantity': soldQty,
      'totalSales': soldTotal,

      'closingStock': closingStock,
      'closingValue': closingValue,

      'costPer': costPer,
      'businessDate': businessDate,
      'cobAt': now,
      'createdAt': now,
    });

    /* -------- UPDATE MASTER PRODUCT -------- */

    final productRef =
    firestore.collection('Product').doc(productId);

    batch.update(productRef, {
      'quantity': closingStock,
      'totalCost': closingValue,
      'status':
      closingStock > 0 ? 'Available' : 'Out of Stock',
      'lastCOB': now,
    });

    /* -------- DELETE SOLD RECORDS -------- */

    for (var doc in soldSnapshot.docs) {
      batch.delete(doc.reference);
    }

    /* -------- DELETE ASSIGNED STOCK -------- */

    batch.delete(assignedRef);

    await batch.commit();
  }

  /* ---------------- CLOSE ALL ---------------- */

  Future<void> _closeAllBusiness() async {
    final snapshot = await firestore
        .collection('AssignedStock')
        .where('COB', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      await _closeBusiness(doc);
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Close Of Business",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Approve All",
            onPressed: () async {
              final confirm = await _confirmCOB(
                context,
                "Are you sure you want to close business for ALL products?",
              );
              if (confirm) {
                setState(() => loading = true);
                await _closeAllBusiness();
                setState(() => loading = false);

                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                        content: Text(
                            "All products closed successfully")),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('AssignedStock')
            .where('COB', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                  "No items pending Close Of Business"),
            );
          }

          return ListView(
            padding:
            const EdgeInsets.symmetric(vertical: 8),
            children: snapshot.data!.docs.map((doc) {
              final data =
              doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    data['ProductName'] ?? '',
                    style: const TextStyle(
                        fontWeight:
                        FontWeight.w600),
                  ),
                  subtitle: Text(
                      "Product ID: ${data['ProductID']}"),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    tooltip: "Approve",
                    onPressed: () async {
                      final confirm =
                      await _confirmCOB(
                        context,
                        "Close business for ${data['ProductName']}?",
                      );

                      if (confirm) {
                        setState(
                                () => loading = true);
                        await _closeBusiness(doc);
                        setState(
                                () => loading = false);

                        if (mounted) {
                          ScaffoldMessenger.of(
                              context)
                              .showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Business closed successfully")),
                          );
                        }
                      }
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