import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeTill extends StatefulWidget {
  const EmployeeTill({super.key});

  @override
  State<EmployeeTill> createState() => _EmployeeTillState();
}

class _EmployeeTillState extends State<EmployeeTill> {
  // User information
  String? userName;
  String? userEmail;

  // Stock data
  List<Map<String, dynamic>>? assignedStock;

  // Firebase instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UI state
  int _selectedIndex = 0; // 0 for sales, 1 for products
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    fetchUserData();
    fetchAssignedStock();
  }

  Future<void> fetchUserData() async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .get();

      if (mounted) {
        setState(() {
          userName = userDoc['FullName'];
          userEmail = userDoc['Email'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchAssignedStock() async {
    try {
      final assignedStockSnapshot = await _firestore
          .collection('AssignedStock')
          .where('Email', isEqualTo: _firebaseAuth.currentUser?.email)
          .get();

      if (mounted) {
        setState(() {
          assignedStock = assignedStockSnapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Include document ID
            return data;
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching assigned stock: $e');
    }
  }

  Future<void> _addNewProduct() async {
    final productName = _productNameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (productName.isEmpty || quantity <= 0 || price <= 0) {
      _showErrorDialog('Invalid Input', 'Please enter valid product details.');
      return;
    }

    try {
      await _firestore.collection('AssignedStock').add({
        'ProductName': productName,
        'quantity': quantity,
        'Costper': price,
        'total': quantity * price,
        'totalSales': 0.0,
        'soldQuantity': 0,
        'Email': _firebaseAuth.currentUser?.email,
        'assignedAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _productNameController.clear();
      _quantityController.clear();
      _priceController.clear();

      // Refresh stock list
      fetchAssignedStock();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to add product: $e');
    }
  }

  Future<void> makeSale(String productId, String productName) async {
    // Get product data first
    double costPerUnit = 0.0;
    int? availableQuantity;

    try {
      final productDoc = _firestore.collection('AssignedStock').doc(productId);
      final currentData = (await productDoc.get()).data()!;
      costPerUnit = currentData['Costper'];
      availableQuantity = currentData['quantity'];
    } catch (e) {
      _showErrorDialog('Error', 'Failed to fetch product details: $e');
      return;
    }

    // Variables for sale dialog
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController clientNameController = TextEditingController();
    final TextEditingController companyController = TextEditingController();

    // Get sale details from dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double saleAmount = 0.0;

        return StatefulBuilder(
          builder: (context, setState) {
            void calculateTotal() {
              final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
              if (quantity > 0) {
                setState(() {
                  saleAmount = quantity * costPerUnit;
                });
              } else {
                setState(() {
                  saleAmount = 0.0;
                });
              }
            }

            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('Make Sale'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Info
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Available: $availableQuantity units',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  'GHS ${costPerUnit.toStringAsFixed(2)}/unit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Client Information Section
                    Text(
                      'Client Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Client Name
                    TextField(
                      controller: clientNameController,
                      decoration: InputDecoration(
                        labelText: 'Client Name *',
                        hintText: 'Enter client name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                        suffixIcon: clientNameController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () {
                            clientNameController.clear();
                            setState(() {});
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    SizedBox(height: 12),

                    // Company Name (Optional)
                    TextField(
                      controller: companyController,
                      decoration: InputDecoration(
                        labelText: 'Company Name (Optional)',
                        hintText: 'Enter company name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business_outlined),
                        suffixIcon: companyController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () {
                            companyController.clear();
                            setState(() {});
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    SizedBox(height: 20),

                    // Sale Details Section
                    Text(
                      'Sale Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Quantity Input
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_list_numbered),
                        suffixIcon: quantityController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () {
                            quantityController.clear();
                            calculateTotal();
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) => calculateTotal(),
                    ),
                    SizedBox(height: 16),

                    // Total Amount Display
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'GHS ${saleAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.monetization_on,
                            color: Colors.green,
                            size: 36,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),

                    // Breakdown
                    if (quantityController.text.isNotEmpty && int.tryParse(quantityController.text.trim())! > 0)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${quantityController.text} × GHS ${costPerUnit.toStringAsFixed(2)} = GHS ${saleAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Warning message if quantity exceeds available
                    // Warning message if quantity exceeds available
                    if ((int.tryParse(quantityController.text.trim()) ?? 0) > (availableQuantity ?? 0))
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange[800], size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Insufficient stock! Available: $availableQuantity',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
                    final clientName = clientNameController.text.trim();

                    // Validation
                    if (clientName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter client name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a valid quantity'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (quantity > availableQuantity!) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Quantity exceeds available stock!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop({
                      'quantity': quantity,
                      'clientName': clientName,
                      'company': companyController.text.trim(),
                      'totalAmount': saleAmount,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 20),
                      SizedBox(width: 8),
                      Text('Process Sale'),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final soldQuantity = result['quantity'] as int;
    final clientName = result['clientName'] as String;
    final company = result['company'] as String;
    final totalAmount = result['totalAmount'] as double;

    try {
      final productDoc = _firestore.collection('AssignedStock').doc(productId);
      final currentData = (await productDoc.get()).data()!;

      final int availableQuantity = currentData['quantity'];
      final int availableSoldQuantity = currentData['soldQuantity'] ?? 0;
      final double costPerQuantity = currentData['Costper'];
      final double total = currentData['total'];
      final double availableTotal = currentData['totalSales'] ?? 0.0;

      if (availableQuantity >= soldQuantity) {
        final int remainingQuantity = availableQuantity - soldQuantity;
        final double newTotal = total - totalAmount;
        final int newSoldQuantity = availableSoldQuantity + soldQuantity;
        final double newTotalSales = availableTotal + totalAmount;

        // Update assigned stock
        await productDoc.update({
          'soldQuantity': newSoldQuantity,
          'quantity': remainingQuantity,
          'totalSales': newTotalSales,
          'total': newTotal,
          'lastSold': FieldValue.serverTimestamp(),
        });

        // Record sale in separate collection with client info
        await _firestore.collection('SoldQuantity').add({
          'ProductName': productName,
          'productId': currentData['ProductID'],
          'soldQuantity': soldQuantity,
          'perUnit': costPerQuantity,
          'totalSales': totalAmount,
          'soldBy': _firebaseAuth.currentUser?.email,
          'soldTo': clientName,
          'company': company.isNotEmpty ? company : null,
          'clientName': clientName,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
        });

        // Refresh stock list
        fetchAssignedStock();

        if (mounted) {
          // Show detailed success message
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('Sale Successful'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sale has been recorded successfully!'),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receipt',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Product:'),
                            Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Client:'),
                            Text(clientName, style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (company.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Company:'),
                              Text(company),
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantity:'),
                            Text('$soldQuantity units'),
                          ],
                        ),
                        Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'GHS ${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        _showErrorDialog(
          'Insufficient Stock',
          'Available: $availableQuantity, Requested: $soldQuantity',
        );
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to record sale: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text('Sign Out'),
          ],
        ),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _firebaseAuth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/SignIn",
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              userName ?? 'Loading...',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.grey, size: 18),
                      SizedBox(width: 8),
                      Text(
                        userEmail ?? 'Loading...',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Sales Statistics (Optional - can be expanded)
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Available Products',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          assignedStock?.length.toString() ?? '0',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Total Items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        // Text(
                        //   assignedStock?.fold(0, (sum, item) => sum + (item['quantity'] ?? 0)).toString() ?? '0',
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.blue[700],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Assigned Stock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Stock',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: fetchAssignedStock,
                icon: Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          SizedBox(height: 16),

          if (assignedStock == null)
            Center(child: CircularProgressIndicator())
          else if (assignedStock!.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No stock assigned yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add products or wait for assignment',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: assignedStock!.map((stockItem) {
                final productId = stockItem['id'];
                final productName = stockItem['ProductName'];
                final quantity = stockItem['quantity'];
                final total = stockItem['total'];
                final soldQuantity = stockItem['soldQuantity'] ?? 0;
                final costPerUnit = stockItem['Costper'] ?? 0.0;

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(Icons.inventory, color: Colors.blue, size: 24),
                    ),
                    title: Text(
                      productName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                'Qty: $quantity',
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.green[50],
                            ),
                            SizedBox(width: 8),
                            Chip(
                              label: Text(
                                'Sold: $soldQuantity',
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.orange[50],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'GHS ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'GHS ${costPerUnit.toStringAsFixed(2)} per unit',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () => makeSale(productId, productName),
                      icon: Icon(Icons.shopping_cart, size: 18),
                      label: Text('Sell'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Product',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add products to your inventory',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _productNameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      hintText: 'e.g., Sugar, Rice, Oil',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity *',
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price per Unit (GHS) *',
                      hintText: 'e.g., 10.50',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money_outlined),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _addNewProduct,
                      icon: Icon(Icons.add_circle_outline),
                      label: Text('Add Product to Inventory'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32),

          // Recently Added Products
          if (assignedStock != null && assignedStock!.isNotEmpty) ...[
            Text(
              'Recent Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...assignedStock!.take(5).map((product) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(product['ProductName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${product['quantity']}'),
                      Text('Price: GHS ${product['Costper']?.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                  trailing: Text(
                    'GHS ${product['total']?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Dashboard'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildSalesView() : _buildSalesView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business_outlined),
            activeIcon: Icon(Icons.add_business),
            label: 'Products',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}