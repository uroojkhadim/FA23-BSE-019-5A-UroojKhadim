import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../utils/date_formatter.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadDashboardData(
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  Future<void> _selectDateRange() async {
    final DateTime? start = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (start != null) {
      final DateTime? end = await showDatePicker(
        context: context,
        initialDate: _endDate ?? DateTime.now(),
        firstDate: start,
        lastDate: DateTime.now(),
      );
      
      if (end != null) {
        setState(() {
          _startDate = start;
          _endDate = end;
        });
        
        // Reload data with new date range
        context.read<AnalyticsProvider>().loadDashboardData(
          startDate: _startDate,
          endDate: _endDate,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = context.watch<AnalyticsProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: analyticsProvider.refreshData,
          ),
        ],
      ),
      body: analyticsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => analyticsProvider.refreshData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date range display
                    if (_startDate != null && _endDate != null)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Period: ${DateFormatter.formatDate(_startDate!)} - ${DateFormatter.formatDate(_endDate!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    
                    // Sales Summary Cards
                    _buildSalesSummaryCards(analyticsProvider),
                    
                    const SizedBox(height: 16.0),
                    
                    // Charts and Analytics
                    _buildSalesTrendChart(analyticsProvider),
                    
                    const SizedBox(height: 16.0),
                    
                    _buildTopProductsSection(analyticsProvider),
                    
                    const SizedBox(height: 16.0),
                    
                    _buildTopCustomersSection(analyticsProvider),
                    
                    const SizedBox(height: 16.0),
                    
                    _buildPaymentMethodAnalysis(analyticsProvider),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSalesSummaryCards(AnalyticsProvider analyticsProvider) {
    final salesSummary = analyticsProvider.salesSummary;
    
    if (salesSummary == null) {
      return const SizedBox.shrink();
    }
    
    final totalSales = salesSummary['totalSales'] as double? ?? 0.0;
    final transactionCount = salesSummary['transactionCount'] as int? ?? 0;
    final totalItemsSold = salesSummary['totalItemsSold'] as int? ?? 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Sales Summary',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(
                  'Total Sales',
                  '₹${totalSales.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Transactions',
                  transactionCount.toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(
                  'Items Sold',
                  totalItemsSold.toString(),
                  Icons.inventory,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  'Avg. Value',
                  totalSales > 0 && transactionCount > 0 
                      ? '₹${(totalSales / transactionCount).toStringAsFixed(2)}' 
                      : '₹0.00',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.0),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTrendChart(AnalyticsProvider analyticsProvider) {
    final dailySales = analyticsProvider.dailySalesTrend;
    
    if (dailySales == null || dailySales.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No sales data available'),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Sales Trend',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailySales.length,
                itemBuilder: (context, index) {
                  final data = dailySales[index];
                  final date = DateTime.parse(data['date']);
                  final dailyTotal = (data['dailyTotal'] as num?)?.toDouble() ?? 0.0;
                  
                  return Container(
                    width: 60.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: (dailyTotal / 1000.0) * 150, // Scale based on max value
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(fontSize: 10.0),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsSection(AnalyticsProvider analyticsProvider) {
    final productAnalytics = analyticsProvider.productAnalytics;
    final topProducts = productAnalytics?['bestSellingProducts'] as List? ?? [];
    
    if (topProducts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Selling Products',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ...topProducts.take(5).map((product) {
              final productName = product['productName'] ?? 'Unknown';
              final totalQuantity = (product['totalQuantity'] as int?) ?? 0;
              final totalRevenue = (product['totalRevenue'] as num?)?.toDouble() ?? 0.0;
              
              return ListTile(
                title: Text(productName.toString()),
                subtitle: Text('Quantity: $totalQuantity'),
                trailing: Text('₹${totalRevenue.toStringAsFixed(2)}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomersSection(AnalyticsProvider analyticsProvider) {
    final customerAnalytics = analyticsProvider.customerAnalytics;
    final topCustomers = customerAnalytics?['topCustomers'] as List? ?? [];
    
    if (topCustomers.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Customers',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ...topCustomers.take(5).map((customer) {
              final customerName = customer['name'] ?? 'Unknown';
              final totalSpent = (customer['totalSpent'] as num?)?.toDouble() ?? 0.0;
              final transactionCount = (customer['transactionCount'] as int?) ?? 0;
              
              return ListTile(
                title: Text(customerName.toString()),
                subtitle: Text('Transactions: $transactionCount'),
                trailing: Text('₹${totalSpent.toStringAsFixed(2)}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodAnalysis(AnalyticsProvider analyticsProvider) {
    final paymentMethodAnalysis = analyticsProvider.paymentMethodAnalysis;
    final paymentMethods = paymentMethodAnalysis?['paymentMethods'] as List? ?? [];
    
    if (paymentMethods.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method Analysis',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ...paymentMethods.map((method) {
              final methodName = method['paymentMethod'] ?? 'Unknown';
              final count = (method['count'] as int?) ?? 0;
              final totalAmount = (method['totalAmount'] as num?)?.toDouble() ?? 0.0;
              
              return ListTile(
                title: Text(methodName.toString()),
                subtitle: Text('Count: $count'),
                trailing: Text('₹${totalAmount.toStringAsFixed(2)}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}