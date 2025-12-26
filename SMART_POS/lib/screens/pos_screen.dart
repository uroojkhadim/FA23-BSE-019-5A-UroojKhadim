import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers\product_provider.dart';
import '../providers\pos_cart_provider.dart';
import '../models\product.dart';
import '../utils\constants.dart';
import 'add_product_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({Key? key}) : super(key: key);

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS System'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Product search section
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
          
          // Product list
          Expanded(
            flex: 2,
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                List<Product> products = productProvider.searchProducts(_searchQuery);
                
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    Product product = products[index];
                    return Card(
                      child: InkWell(
                        onTap: () => _addItemToCart(context, product),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${product.quantity}',
                                style: TextStyle(
                                  color: product.quantity < 5 ? Colors.red : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Cart section
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // Cart header
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    color: Colors.grey[300],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Consumer<PosCartProvider>(
                          builder: (context, cartProvider, child) {
                            return Text(
                              'Total: \$${cartProvider.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: AppConstants.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Cart items
                  Expanded(
                    child: Consumer<PosCartProvider>(
                      builder: (context, cartProvider, child) {
                        if (cartProvider.cartItems.isEmpty) {
                          return const Center(
                            child: Text('Add items to cart'),
                          );
                        }
                        
                        return ListView.builder(
                          itemCount: cartProvider.cartItems.length,
                          itemBuilder: (context, index) {
                            var item = cartProvider.cartItems[index];
                            return ListTile(
                              title: Text(item.productName),
                              subtitle: Text('Qty: ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}'),
                              trailing: Text('\$${item.total.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => cartProvider.updateItemQuantity(item.productId, item.quantity - 1),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => cartProvider.updateItemQuantity(item.productId, item.quantity + 1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => cartProvider.removeItem(item.productId),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Clear cart
                      context.read<PosCartProvider>().clearCart();
                    },
                    child: const Text('Clear Cart'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Consumer<PosCartProvider>(
                    builder: (context, cartProvider, child) {
                      return ElevatedButton(
                        onPressed: cartProvider.cartItems.isEmpty
                            ? null
                            : () => _processPayment(context, cartProvider),
                        child: const Text('Process Payment'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addItemToCart(BuildContext context, Product product) {
    if (product.quantity > 0) {
      context.read<PosCartProvider>().addItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          backgroundColor: Color(AppConstants.successColorValue),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient stock for ${product.name}'),
          backgroundColor: Color(AppConstants.errorColorValue),
        ),
      );
    }
  }

  void _processPayment(BuildContext context, PosCartProvider cartProvider) {
    // For now, just show a simple dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Cash'),
                onTap: () {
                  cartProvider.setPaymentMethod('Cash');
                  Navigator.of(context).pop();
                  _confirmTransaction(context, cartProvider);
                },
              ),
              ListTile(
                title: const Text('Card'),
                onTap: () {
                  cartProvider.setPaymentMethod('Card');
                  Navigator.of(context).pop();
                  _confirmTransaction(context, cartProvider);
                },
              ),
              ListTile(
                title: const Text('Mobile Payment'),
                onTap: () {
                  cartProvider.setPaymentMethod('Mobile');
                  Navigator.of(context).pop();
                  _confirmTransaction(context, cartProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmTransaction(BuildContext context, PosCartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Transaction'),
          content: Consumer<PosCartProvider>(
            builder: (context, cartProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal: \$${cartProvider.subTotal.toStringAsFixed(2)}'),
                  Text('Tax: \$${cartProvider.tax.toStringAsFixed(2)}'),
                  Text('Discount: \$${cartProvider.discount.toStringAsFixed(2)}'),
                  const Divider(),
                  Text('Total: \$${cartProvider.total.toStringAsFixed(2)}'),
                  Text('Payment Method: ${cartProvider.paymentMethod}'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                bool success = await cartProvider.processTransaction();
                Navigator.of(context).pop(); // Close dialog
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction completed successfully!'),
                      backgroundColor: Color(AppConstants.successColorValue),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction failed. Please try again.'),
                      backgroundColor: Color(AppConstants.errorColorValue),
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}