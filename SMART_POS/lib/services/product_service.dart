import '../models/product.dart';
import 'database_service.dart';

class ProductService {
  final DatabaseService _databaseService = DatabaseService();

  // Add a new product
  Future<int> addProduct(Product product) async {
    return await _databaseService.insertProduct(product);
  }

  // Get a product by ID
  Future<Product?> getProduct(int id) async {
    return await _databaseService.getProduct(id);
  }

  // Get a product by SKU
  Future<Product?> getProductBySku(String sku) async {
    return await _databaseService.getProductBySku(sku);
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    return await _databaseService.getAllProducts();
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    return await _databaseService.getProductsByCategory(category);
  }

  // Update a product
  Future<int> updateProduct(Product product) async {
    return await _databaseService.updateProduct(product);
  }

  // Delete a product
  Future<int> deleteProduct(int id) async {
    return await _databaseService.deleteProduct(id);
  }

  // Update product quantity (for inventory management)
  Future<bool> updateProductQuantity(int productId, int newQuantity) async {
    try {
      Product? product = await _databaseService.getProduct(productId);
      if (product != null) {
        Product updatedProduct = product.copyWith(
          quantity: newQuantity,
          updatedAt: DateTime.now(),
        );
        int result = await _databaseService.updateProduct(updatedProduct);
        return result > 0;
      }
      return false;
    } catch (e) {
      print('Error updating product quantity: $e');
      return false;
    }
  }

  // Add quantity to existing product (for stock in)
  Future<bool> addStock(int productId, int quantityToAdd) async {
    try {
      Product? product = await _databaseService.getProduct(productId);
      if (product != null) {
        int newQuantity = product.quantity + quantityToAdd;
        return await updateProductQuantity(productId, newQuantity);
      }
      return false;
    } catch (e) {
      print('Error adding stock: $e');
      return false;
    }
  }

  // Remove quantity from existing product (for stock out)
  Future<bool> removeStock(int productId, int quantityToRemove) async {
    try {
      Product? product = await _databaseService.getProduct(productId);
      if (product != null) {
        if (product.quantity >= quantityToRemove) {
          int newQuantity = product.quantity - quantityToRemove;
          return await updateProductQuantity(productId, newQuantity);
        } else {
          // Not enough stock
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Error removing stock: $e');
      return false;
    }
  }

  // Check if product is low in stock
  Future<bool> isLowStock(int productId, {int threshold = 5}) async {
    Product? product = await _databaseService.getProduct(productId);
    if (product != null) {
      return product.quantity <= threshold;
    }
    return false;
  }

  // Get low stock products
  Future<List<Product>> getLowStockProducts({int threshold = 5}) async {
    List<Product> allProducts = await _databaseService.getAllProducts();
    return allProducts.where((product) => product.quantity <= threshold).toList();
  }

  // Search products by name
  Future<List<Product>> searchProductsByName(String name) async {
    List<Product> allProducts = await _databaseService.getAllProducts();
    return allProducts.where((product) => 
      product.name.toLowerCase().contains(name.toLowerCase()) ||
      product.sku.toLowerCase().contains(name.toLowerCase())
    ).toList();
  }
}