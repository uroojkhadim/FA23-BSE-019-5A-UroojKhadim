import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers\product_provider.dart';
import '../models\product.dart';
import '../utils\constants.dart';
import 'add_product_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
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
                hintText: 'Search products...',
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
          
          // Products list
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                List<Product> products = productProvider.searchProducts(_searchQuery);
                
                if (products.isEmpty) {
                  return const Center(
                    child: Text('No products found'),
                  );
                }
                
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    Product product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingSmall,
                      ),
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SKU: ${product.sku}'),
                            Text('Price: \$${product.price.toStringAsFixed(2)}'),
                            Text('Quantity: ${product.quantity}'),
                            Text('Category: ${product.category}'),
                          ],
                        ),
                        trailing: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                        ),
                        onTap: () {
                          _showProductDetails(context, product);
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

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('SKU: ${product.sku}'),
                Text('Price: \$${product.price.toStringAsFixed(2)}'),
                Text('Cost: \$${product.cost.toStringAsFixed(2)}'),
                Text('Quantity: ${product.quantity}'),
                Text('Category: ${product.category}'),
                if (product.description != null) Text('Description: ${product.description}'),
                Text('Added: ${product.createdAt}'),
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