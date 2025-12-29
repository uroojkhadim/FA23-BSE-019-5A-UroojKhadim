import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';
import '../utils/constants.dart';
import 'add_customer_screen.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({Key? key}) : super(key: key);

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCustomerScreen(),
            ),
          ).then((value) => setState(() {})); // Refresh after adding
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Customers list
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                if (customerProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                List<Customer> customers = customerProvider.searchCustomers(_searchQuery);
                
                if (customers.isEmpty) {
                  return const Center(
                    child: Text('No customers found'),
                  );
                }
                
                return ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    Customer customer = customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingSmall,
                      ),
                      child: ListTile(
                        title: Text(customer.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customer.email != null) Text('Email: ${customer.email}'),
                            if (customer.phone != null) Text('Phone: ${customer.phone}'),
                            Text('Total Purchase: \$${customer.totalPurchase.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Text(
                          '\$${customer.totalPurchase.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                        ),
                        onTap: () {
                          _showCustomerDetails(context, customer);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(customer.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                if (customer.email != null) Text('Email: ${customer.email}'),
                if (customer.phone != null) Text('Phone: ${customer.phone}'),
                if (customer.address != null) Text('Address: ${customer.address}'),
                Text('Total Purchase: \$${customer.totalPurchase.toStringAsFixed(2)}'),
                Text('Added: ${customer.createdAt}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}