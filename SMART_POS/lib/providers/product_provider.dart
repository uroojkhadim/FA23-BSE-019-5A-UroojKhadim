import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/inventory.dart';
import '../services/product_service.dart';
import '../services/inventory_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final InventoryService _inventoryService = InventoryService();
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.getAllProducts();
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      int result = await _productService.addProduct(product);
      if (result != 0) {
        // Create inventory transaction for initial stock
        if (product.quantity > 0) {
          final inventoryTransaction = InventoryTransaction(
            id: 'inv_in_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
            productId: product.id.toString(),
            productName: product.name,
            transactionType: 'in',
            quantity: product.quantity,
            unitCost: product.cost,
            totalCost: product.cost * product.quantity,
            date: DateTime.now(),
            referenceId: 'product_addition',
            notes: 'Initial stock for product ${product.name}',
          );
          await _inventoryService.insertInventoryTransaction(inventoryTransaction);
        }
        
        await loadProducts(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get the current product to compare quantities
      Product? currentProduct = _products.firstWhere((p) => p.id == product.id, orElse: () => product);
      int quantityDifference = product.quantity - (currentProduct.quantity ?? 0);
      
      int result = await _productService.updateProduct(product);
      if (result > 0) {
        // Create inventory transaction if quantity changed
        if (quantityDifference != 0) {
          String transactionType = quantityDifference > 0 ? 'in' : 'out';
          int absQuantity = quantityDifference.abs();
          double totalCost = product.cost * absQuantity;
          
          final inventoryTransaction = InventoryTransaction(
            id: 'inv_${transactionType}_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
            productId: product.id.toString(),
            productName: product.name,
            transactionType: transactionType,
            quantity: absQuantity,
            unitCost: product.cost,
            totalCost: totalCost,
            date: DateTime.now(),
            referenceId: 'product_update',
            notes: 'Quantity update for product ${product.name}',
          );
          await _inventoryService.insertInventoryTransaction(inventoryTransaction);
        }
        
        await loadProducts(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      int result = await _productService.deleteProduct(productId);
      if (result > 0) {
        await loadProducts(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProductQuantity(int productId, int newQuantity) async {
    try {
      bool success = await _productService.updateProductQuantity(productId, newQuantity);
      if (success) {
        await loadProducts(); // Refresh the list
      }
      return success;
    } catch (e) {
      print('Error updating product quantity: $e');
      return false;
    }
  }

  Future<bool> addStock(int productId, int quantityToAdd) async {
    try {
      bool success = await _productService.addStock(productId, quantityToAdd);
      if (success) {
        // Get product details to create inventory transaction
        Product? product = _products.firstWhere((p) => p.id == productId, orElse: () => Product(
          id: productId,
          name: 'Unknown Product',
          sku: 'N/A',
          price: 0.0,
          cost: 0.0,
          quantity: 0,
          category: 'N/A',
          description: '',
          imageUrl: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        // Create inventory transaction for stock addition
        final inventoryTransaction = InventoryTransaction(
          id: 'inv_in_${productId}_${DateTime.now().millisecondsSinceEpoch}',
          productId: productId.toString(),
          productName: product.name,
          transactionType: 'in',
          quantity: quantityToAdd,
          unitCost: product.cost,
          totalCost: product.cost * quantityToAdd,
          date: DateTime.now(),
          referenceId: 'stock_addition',
          notes: 'Stock addition for product ${product.name}',
        );
        await _inventoryService.insertInventoryTransaction(inventoryTransaction);
        
        await loadProducts(); // Refresh the list
      }
      return success;
    } catch (e) {
      print('Error adding stock: $e');
      return false;
    }
  }

  Future<bool> removeStock(int productId, int quantityToRemove) async {
    try {
      bool success = await _productService.removeStock(productId, quantityToRemove);
      if (success) {
        // Get product details to create inventory transaction
        Product? product = _products.firstWhere((p) => p.id == productId, orElse: () => Product(
          id: productId,
          name: 'Unknown Product',
          sku: 'N/A',
          price: 0.0,
          cost: 0.0,
          quantity: 0,
          category: 'N/A',
          description: '',
          imageUrl: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        // Create inventory transaction for stock removal
        final inventoryTransaction = InventoryTransaction(
          id: 'inv_out_${productId}_${DateTime.now().millisecondsSinceEpoch}',
          productId: productId.toString(),
          productName: product.name,
          transactionType: 'out',
          quantity: quantityToRemove,
          unitCost: product.cost,
          totalCost: product.cost * quantityToRemove,
          date: DateTime.now(),
          referenceId: 'stock_removal',
          notes: 'Stock removal for product ${product.name}',
        );
        await _inventoryService.insertInventoryTransaction(inventoryTransaction);
        
        await loadProducts(); // Refresh the list
      }
      return success;
    } catch (e) {
      print('Error removing stock: $e');
      return false;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) {
      return _products;
    }
    
    return _products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.sku.toLowerCase().contains(query.toLowerCase()) ||
      product.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<Product> getLowStockProducts({int threshold = 5}) {
    return _products.where((product) => product.quantity <= threshold).toList();
  }

  List<String> getCategories() {
    Set<String> categories = _products.map((product) => product.category).toSet();
    return categories.toList();
  }
}