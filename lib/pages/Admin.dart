import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:malcolm_erp/pages/Sold.dart';
import '../Assistant/assistantmethods.dart';
import '../models/Admin.dart';
import 'AssignStock.dart';
import 'Inventory.dart';
import 'addproduct.dart';

class Adminpage extends StatefulWidget {
  const Adminpage({Key? key}) : super(key: key);

  @override
  State<Adminpage> createState() => _AdminpageState();
}

class _AdminpageState extends State<Adminpage> {
  final Map<String, double> _itemTotals = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _selectedChartIndex = 0; // 0 for Pie, 1 for Bar
  bool _showChart = true;

  // Colors for charts
  final List<Color> _chartColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lime,
    Colors.brown,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _refreshData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }


  Future<void> _initializeData() async {
    try {
      // Load admin info
      await AssistantMethod.getAminInfo(context);
      if (!mounted) return;

      // Load sales data
      await _fetchProductCategories();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e, stack) {
      debugPrint('Error initializing data: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }
  Future<void> _fetchProductCategories() async {
    try {
      // Use get() with timeout to avoid hanging
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('SoldQuantity')
          .get()
          .timeout(const Duration(seconds: 10));

      final Map<String, double> categoryTotals = {};

      if (snapshot.docs.isNotEmpty) {
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final String category = data['ProductName']?.toString() ?? 'Unknown';
            final price = (data['totalSales'] is num)
                ? (data['totalSales'] as num).toDouble()
                : double.tryParse(data['totalSales']?.toString() ?? '0') ?? 0.0;

            if (category.isNotEmpty && price > 0) {
              categoryTotals[category] = (categoryTotals[category] ?? 0) + price;
            }
          } catch (e) {
            print('Error processing document ${doc.id}: $e');
          }
        }

        if (mounted) {
          setState(() {
            _itemTotals.clear();
            _itemTotals.addAll(categoryTotals);
          });
        }
      } else {
        // No data in collection - this is not an error, just empty state
        if (mounted) {
          setState(() {
            _itemTotals.clear();
          });
        }
      }
    } catch (error) {
      print('Error fetching product categories: $error');
      // Don't set error state here - let _initializeData handle it
      rethrow; // Re-throw to be caught by _initializeData
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context,
            "/SignIn",
                (route) => false
        );
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _showSignOutConfirmation() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you certain you want to Sign Out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleSignOut();
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      await _fetchProductCategories();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to refresh data: $e';
        });
      }
    }
  }
  double get _totalSales {
    if (_itemTotals.isEmpty) return 0.0;
    return _itemTotals.values.fold(0.0, (sum, value) => sum + value);
  }

  List<Map<String, dynamic>> get _sortedItems {
    final items = _itemTotals.entries.map((entry) {
      final percentage = _totalSales > 0 ? (entry.value / _totalSales) * 100 : 0;
      return {
        'name': entry.key,
        'value': entry.value,
        'percentage': percentage,
        'color': _getColorForProduct(entry.key),
      };
    }).toList();

    items.sort((a, b) => (b['value'] as num).compareTo(a['value'] as num));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final String companyName = Provider.of<Admin>(context)
        .admininfo
        ?.CompanyName ?? "Jolynda";

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            companyName,
            style: const TextStyle(
              fontFamily: "Nunito",
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSignOutConfirmation,
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading ? _buildLoadingBody() : _buildBody(),
      ),
    );
  }

  Widget _buildLoadingBody() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Loading dashboard...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSalesSummaryCard(),
          const SizedBox(height: 20),
          _buildChartToggle(),
          const SizedBox(height: 20),
          _buildChartSection(),
          const SizedBox(height: 30),
          _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Admin Dashboard",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Sales Analytics & Management",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Sales",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "GHC ${_totalSales.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_itemTotals.length} Product${_itemTotals.length == 1 ? '' : 's'} Sold",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Sales Distribution",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _showChart = !_showChart);
                },
                icon: Icon(
                  _showChart ? Icons.list : Icons.pie_chart,
                  color: Colors.black87,
                ),
                tooltip: _showChart ? 'Show List' : 'Show Chart',
              ),
              if (_showChart) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Pie'),
                  selected: _selectedChartIndex == 0,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedChartIndex = 0);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bar'),
                  selected: _selectedChartIndex == 1,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedChartIndex = 1);
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    if (_hasError) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Center(
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
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_itemTotals.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: _showChart
              ? (_selectedChartIndex == 0
              ? _buildPieChart()
              : _buildBarChart())
              : _buildProductList(),
        ),
        const SizedBox(height: 20),
        _buildChartLegend(),
      ],
    );
  }

  Widget _buildPieChart() {
    if (_itemTotals.isEmpty) {
      return const Center(
        child: Text('No data available for chart'),
      );
    }

    return PieChart(
      PieChartData(
        sections: _getPieChartSections(),
        centerSpaceRadius: 60,
        sectionsSpace: 2,
        startDegreeOffset: 180,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final sections = <PieChartSectionData>[];
    final sortedItems = _sortedItems;

    for (int i = 0; i < sortedItems.length; i++) {
      final item = sortedItems[i];
      sections.add(
        PieChartSectionData(
          color: item['color'],
          value: item['value'],
          title: '${item['percentage'].toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
    }

    return sections;
  }

  Widget _buildBarChart() {
    final maxY = _itemTotals.values.isNotEmpty
        ? _itemTotals.values.reduce((a, b) => a > b ? a : b) * 1.2
        : 100;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // maxY: maxY,
        barGroups: _getBarGroups(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _itemTotals.length) {
                  final category = _sortedItems[index]['name'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      category.length > 10
                          ? '${category.substring(0, 10)}...'
                          : category,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  'GHC ${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    final groups = <BarChartGroupData>[];
    final sortedItems = _sortedItems;

    for (int i = 0; i < sortedItems.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: sortedItems[i]['value'],
              color: sortedItems[i]['color'],
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return groups;
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _itemTotals.length,
      itemBuilder: (context, index) {
        final item = _sortedItems[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: item['color'],
            child: Text(
              item['name'][0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            item['name'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${item['percentage'].toStringAsFixed(1)}% of total sales',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Text(
            'GHC ${item['value'].toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Product Sales Breakdown",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ..._sortedItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['name'],
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'GHC ${item['value'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${item['percentage'].toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getColorForProduct(String productName) {
    final index = _itemTotals.keys.toList().indexOf(productName) % _chartColors.length;
    return _chartColors[index];
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 18.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No Sales Data Available",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Sales data will appear here once products are sold",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.add_circle,
            label: "Add Product",
            color: Colors.orange[800]!,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => addproduct()),
            ),
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.inventory,
            label: "Inventory",
            color: Colors.blue[800]!,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Inventory()),
            ),
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.monetization_on,
            label: "Sold Items",
            color: Colors.green[800]!,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Soldpage()),
            ),

          ),
          const SizedBox(width: 16),


          _buildActionButton(
            icon: Icons.monetization_on,
            label: "Assign Stock",
            color: Colors.green[800]!,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AssignStock()),
            ),
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.history,
            label: "History",
            color: Colors.purple[800]!,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Soldpage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}