import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
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
      int result = await _productService.updateProduct(product);
      if (result > 0) {
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