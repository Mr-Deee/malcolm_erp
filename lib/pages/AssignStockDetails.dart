import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignStockPage extends StatefulWidget {
  @override
  _AssignStockPageState createState() => _AssignStockPageState();
}

class _AssignStockPageState extends State<AssignStockPage> {
  String? _selectedUser;
  String? _selectedProduct;
  String? _selectedProductid;
  double _totalPrice = 0.0;
  double? _costPrice;
  TextEditingController _quantityController = TextEditingController();
  String? _selectedUserEmail;
  bool _isCalculating = false;
  bool _isAssigning = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> fetchUserEmail(String value) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('FullName', isEqualTo: value)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _selectedUserEmail = querySnapshot.docs.first['Email'] as String?;
      });
    }
  }

  Future<List<String>> _fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('FullName')
          .get();
      return snapshot.docs
          .map((doc) => doc['FullName'] as String)
          .toList();
    } catch (e) {
      _showErrorSnackbar('Failed to load users');
      return [];
    }
  }

  Future<Map<String, String>> _fetchProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Product')
          .orderBy('Product')
          .get();

      final products = snapshot.docs
          .map((doc) => doc['Product'] as String)
          .toList();
      final productIds = snapshot.docs
          .map((doc) => doc.id)
          .toList();

      return Map.fromIterables(products, productIds);
    } catch (e) {
      _showErrorSnackbar('Failed to load products');
      return {};
    }
  }

  Future<void> _calculateTotalPrice() async {
    if (_selectedProduct == null || _selectedProduct!.isEmpty) {
      _showErrorSnackbar('Please select a product');
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      _showErrorSnackbar('Please enter a valid quantity');
      return;
    }

    setState(() => _isCalculating = true);

    try {
      final productMap = await _fetchProducts();
      final productId = productMap[_selectedProduct];

      if (productId == null) {
        _showErrorSnackbar('Product not found');
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('Product')
          .doc(productId)
          .get();

      if (!doc.exists) {
        _showErrorSnackbar('Product details not found');
        return;
      }

      final price = doc.data()?['Cost'] as double? ?? 0.0;

      setState(() {
        _totalPrice = quantity * price;
        _costPrice = price;
        _selectedProductid = productId;
      });

      _showSuccessSnackbar('Total calculated: GHS ${_totalPrice.toStringAsFixed(2)}');
    } catch (e) {
      _showErrorSnackbar('Failed to calculate price');
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  Future<void> _assignStock() async {
    if (_selectedUser == null) {
      _showErrorSnackbar('Please select a user');
      return;
    }

    if (_selectedProduct == null) {
      _showErrorSnackbar('Please select a product');
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      _showErrorSnackbar('Please enter a valid quantity');
      return;
    }

    setState(() => _isAssigning = true);

    try {
      await _showConfirmationDialog();
    } catch (e) {
      _showErrorSnackbar('Operation cancelled');
    } finally {
      setState(() => _isAssigning = false);
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.assignment, color: Colors.blue),
            SizedBox(width: 12),
            Text(
              'Confirm Assignment',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfirmationRow('User:', _selectedUser ?? 'Not selected'),
              _buildConfirmationRow('Product:', _selectedProduct ?? 'Not selected'),
              _buildConfirmationRow('Cost per Unit:', 'GHS ${_costPrice?.toStringAsFixed(2) ?? "0.00"}'),
              _buildConfirmationRow('Quantity:', _quantityController.text),
              _buildConfirmationRow('Total Price:', 'GHS ${_totalPrice.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to assign this stock?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: _submitAssignment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Confirm & Assign',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAssignment() async {
    try {
      Navigator.of(context).pop();

      final int soldQuantity = int.tryParse(_quantityController.text.trim()) ?? 0;
      final double costPrice = _costPrice ?? 0.0;
      final String productName = _selectedProduct ?? '';
      final String productId = _selectedProductid ?? '';
      final String userEmail = _selectedUserEmail?.toLowerCase() ?? '';

      // Check for existing assignment
      final querySnapshot = await FirebaseFirestore.instance
          .collection('AssignedStock')
          .where('ProductID', isEqualTo: productId)
          .where('User', isEqualTo: _selectedUser)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update existing
        final doc = querySnapshot.docs.first;
        final int existingQuantity = doc['quantity'];
        final double existingTotal = doc['total'];
        final int newQuantity = existingQuantity + soldQuantity;
        final double newTotal = existingTotal + _totalPrice;

        await doc.reference.update({
          'quantity': newQuantity,
          'total': newTotal,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _showSuccessSnackbar('Stock updated successfully!');
      } else {
        // Create new assignment
        await FirebaseFirestore.instance.collection('AssignedStock').add({
          'quantity': soldQuantity,
          'Costper': costPrice,
          'total': _totalPrice,
          'ProductName': productName,
          'soldQuantity': 0,
          'totalSales': 0.0,
          'ProductID': productId,
          'COB': true,
          'User': _selectedUser,
          'Email': userEmail,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _showSuccessSnackbar('Stock assigned successfully!');
      }

      // Reset form
      _resetForm();
    } catch (e) {
      _showErrorSnackbar('Failed to assign stock: ${e.toString()}');
    }
  }

  void _resetForm() {
    setState(() {
      _selectedUser = null;
      _selectedProduct = null;
      _selectedProductid = null;
      _totalPrice = 0.0;
      _costPrice = null;
      _quantityController.clear();
      _selectedUserEmail = null;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assign Stock',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.blue[800],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Stock Assignment',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[900],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Assign stock items to users',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32),

              // User Selection
              _buildSectionHeader('Select User'),
              SizedBox(height: 12),
              FutureBuilder<List<String>>(
                future: _fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingDropdown('Loading users...');
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyDropdown('No users available');
                  }

                  final users = snapshot.data!;
                  return _buildDropdown(
                    value: _selectedUser,
                    items: users,
                    hint: 'Choose a user',
                    onChanged: (value) {
                      setState(() => _selectedUser = value);
                      fetchUserEmail(value!);
                    },
                  );
                },
              ),
              SizedBox(height: 24),

              // Product Selection
              _buildSectionHeader('Select Product'),
              SizedBox(height: 12),
              FutureBuilder<Map<String, String>>(
                future: _fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingDropdown('Loading products...');
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyDropdown('No products available');
                  }

                  final productMap = snapshot.data!;
                  final products = productMap.keys.toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdown(
                        value: _selectedProduct,
                        items: products,
                        hint: 'Choose a product',
                        onChanged: (value) {
                          setState(() => _selectedProduct = value);
                        },
                      ),
                      SizedBox(height: 20),

                      // Quantity Input
                      _buildSectionHeader('Quantity'),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter quantity',
                          prefixIcon: Icon(Icons.numbers, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue!),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity <= 0) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isCalculating ? null : _calculateTotalPrice,
                          icon: _isCalculating
                              ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : Icon(Icons.calculate, size: 20),
                          label: Text(_isCalculating ? 'Calculating...' : 'Calculate Total'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 32),

              // Total Price Display
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[100]!, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'GHS ${_totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.monetization_on,
                      size: 48,
                      color: Colors.blue[300],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Assign Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAssigning ? null : _assignStock,
                  icon: _isAssigning
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : Icon(Icons.assignment_turned_in, size: 20),
                  label: Text(_isAssigning ? 'Assigning...' : 'Assign Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[500]),
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingDropdown(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
          SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDropdown(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 20),
          SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}