import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Assistant/assistantmethods.dart';
import '../models/Item.dart';
import 'Inventorydetails.dart';

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  List<InventoryItem> _inventoryItems = [];
  Map<String, double> _categoryCosts = {};
  Map<String, int> _categoryQuantities = {};
  double _totalInventoryValue = 0.0;
  int _totalItemsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
    _fetchInventoryData();
  }

  Future<void> _fetchInventoryData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Product')
          .get();

      Map<String, double> categoryCostMap = {};
      Map<String, int> categoryQuantityMap = {};
      double totalValue = 0.0;
      int totalCount = 0;

      List<InventoryItem> items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        String name = data['Product']?.toString() ?? 'Unknown';
        String category = data['Category']?.toString() ?? 'Uncategorized';
        int quantity = (data['quantity'] is num)
            ? (data['quantity'] as num).toInt()
            : int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
        double sum = (data['Sum'] is num)
            ? (data['Sum'] as num).toDouble()
            : double.tryParse(data['Sum']?.toString() ?? '0') ?? 0.0;

        // Update category totals
        categoryCostMap[category] = (categoryCostMap[category] ?? 0) + sum;
        categoryQuantityMap[category] =
            (categoryQuantityMap[category] ?? 0) + quantity;

        totalValue += sum;
        totalCount += quantity;

        return InventoryItem(
          name: name,
          category: category,
          quantity: quantity,
          price: quantity > 0 ? sum / quantity : 0,
          totalCost: sum,
        );
      }).toList();

      setState(() {
        _inventoryItems = items;
        _categoryCosts = categoryCostMap;
        _categoryQuantities = categoryQuantityMap;
        _totalInventoryValue = totalValue;
        _totalItemsCount = totalCount;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching inventory: $error');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inventory Management",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchInventoryData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with stats
          _buildInventoryStats(),
          const SizedBox(height: 20),

          // Categories title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Product Categories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Chip(
                  label: Text(
                    "${_categoryCosts.length} Categories",
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Categories grid
          Expanded(
            child: _buildCategoriesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            "Loading Inventory...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            icon: Icons.inventory_2,
            title: "Total Value",
            value: "GHC ${_totalInventoryValue.toStringAsFixed(2)}",
            color: Colors.green,
          ),
          Container(
            height: 60,
            width: 1,
            color: Colors.grey[200],
          ),
          _buildStatItem(
            icon: Icons.warehouse,
            title: "Total Items",
            value: _totalItemsCount.toString(),
            color: Colors.blue,
          ),
          Container(
            height: 60,
            width: 1,
            color: Colors.grey[200],
          ),
          _buildStatItem(
            icon: Icons.category,
            title: "Categories",
            value: _categoryCosts.length.toString(),
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('utils')
          .doc('ProductCategory')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildEmptyState();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> categories = data['list'] ?? [];

        if (categories.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            String categoryName = categories[index].toString();
            double categoryValue = _categoryCosts[categoryName] ?? 0.0;
            int categoryQuantity = _categoryQuantities[categoryName] ?? 0;

            return _buildCategoryCard(
              categoryName: categoryName,
              categoryValue: categoryValue,
              categoryQuantity: categoryQuantity,
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String categoryName,
    required double categoryValue,
    required int categoryQuantity,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Inventorydetails(categoryName: categoryName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCategoryColor(categoryName).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(categoryName),
                color: _getCategoryColor(categoryName),
                size: 30,
              ),
            ),
            const SizedBox(height: 12),

            // Category Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),

            // Category Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Value:",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "GHC ${categoryValue.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Qty:",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        categoryQuantity.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchInventoryData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Categories Found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add product categories to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];
    final index = categoryName.hashCode % colors.length;
    return colors[index];
  }

  IconData _getCategoryIcon(String categoryName) {
    // Map common categories to appropriate icons
    final iconMap = {
      'Electronics': Icons.electrical_services,
      'Clothing': Icons.checkroom,
      'Food': Icons.restaurant,
      'Books': Icons.menu_book,
      'Furniture': Icons.chair,
      'Toys': Icons.toys,
      'Sports': Icons.sports_basketball,
      'Beauty': Icons.spa,
      'Home': Icons.home,
      'Office': Icons.work,
      'Tools': Icons.build,
      'Medical': Icons.medical_services,
      'Automotive': Icons.directions_car,
      'Garden': Icons.grass,
      'Pet': Icons.pets,
      'Jewelry': Icons.diamond,
      'Music': Icons.music_note,
      'Art': Icons.palette,
      'Baby': Icons.child_care,
      'Shoes': Icons.shopping_bag,
    };

    // Check for partial matches
    final lowerName = categoryName.toLowerCase();
    for (final entry in iconMap.entries) {
      if (lowerName.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Default icon
    return Icons.category;
  }
}