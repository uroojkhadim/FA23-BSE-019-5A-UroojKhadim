import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../models/inventory.dart';
import '../services/transaction_service.dart';
import '../services/inventory_service.dart';
import '../utils/constants.dart';

class PosCartProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final InventoryService _inventoryService = InventoryService();
  List<TransactionItem> _cartItems = [];
  double _subTotal = 0.0;
  double _tax = 0.0;
  double _discount = 0.0;
  double _total = 0.0;
  String _paymentMethod = 'Cash';
  int? _customerId;

  List<TransactionItem> get cartItems => _cartItems;
  double get subTotal => _subTotal;
  double get tax => _tax;
  double get discount => _discount;
  double get total => _total;
  String get paymentMethod => _paymentMethod;
  int? get customerId => _customerId;

  // Add item to cart
  void addItem(Product product, {int quantity = 1}) {
    // Check if item already exists in cart
    int existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      // Update quantity if item exists
      TransactionItem existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        total: (existingItem.unitPrice * (existingItem.quantity + quantity)),
      );
    } else {
      // Add new item
      TransactionItem newItem = TransactionItem(
        transactionId: 'temp', // Will be updated when transaction is created
        productId: product.id!,
        productName: product.name,
        quantity: quantity,
        unitPrice: product.price,
        total: product.price * quantity,
      );
      _cartItems.add(newItem);
    }
    
    _calculateTotals();
    notifyListeners();
  }

  // Update item quantity in cart
  void updateItemQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    
    int index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      TransactionItem item = _cartItems[index];
      _cartItems[index] = item.copyWith(
        quantity: newQuantity,
        total: item.unitPrice * newQuantity,
      );
      _calculateTotals();
      notifyListeners();
    }
  }

  // Remove item from cart
  void removeItem(int productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    _calculateTotals();
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    _subTotal = 0.0;
    _tax = 0.0;
    _discount = 0.0;
    _total = 0.0;
    notifyListeners();
  }

  // Calculate totals
  void _calculateTotals() {
    _subTotal = _cartItems.fold(0, (sum, item) => sum + item.total);
    _tax = _subTotal * (AppConstants.defaultTaxRate / 100);
    _discount = 0.0; // This could be updated based on business logic
    _total = _subTotal + _tax - _discount;
  }

  // Set discount
  void setDiscount(double discountAmount) {
    _discount = discountAmount;
    _calculateTotals();
    notifyListeners();
  }

  // Set tax rate
  void setTaxRate(double taxRate) {
    // For now, we'll use the constant tax rate
    _calculateTotals();
    notifyListeners();
  }

  // Set payment method
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  // Set customer
  void setCustomer(int? customerId) {
    _customerId = customerId;
    notifyListeners();
  }

  // Process transaction
  Future<bool> processTransaction() async {
    if (_cartItems.isEmpty) {
      return false;
    }

    try {
      // Create transaction
      String transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      Transaction transaction = Transaction(
        transactionId: transactionId,
        customerId: _customerId,
        subtotal: _subTotal,
        tax: _tax,
        discount: _discount,
        total: _total,
        paymentMethod: _paymentMethod,
        status: AppConstants.transactionCompleted,
        transactionDate: DateTime.now(),
        notes: 'POS Transaction',
        isOnline: false, // Will be updated based on connectivity
      );

      // Save transaction
      String result = await _transactionService.addTransaction(transaction);
      
      if (result.isNotEmpty) {
        // Update transaction items with actual transaction ID
        for (TransactionItem item in _cartItems) {
          TransactionItem updatedItem = item.copyWith(
            transactionId: transactionId,
          );
          await _transactionService.addTransactionItem(updatedItem);
          
          // Create inventory transaction to reduce stock
          final inventoryTransaction = InventoryTransaction(
            id: 'inv_${transactionId}_${item.productId}',
            productId: item.productId.toString(),
            productName: item.productName,
            transactionType: 'out',
            quantity: item.quantity,
            unitCost: item.unitPrice,
            totalCost: item.total,
            date: DateTime.now(),
            referenceId: transactionId,
            notes: 'POS sale transaction',
          );
          await _inventoryService.insertInventoryTransaction(inventoryTransaction);
        }
        
        // Clear cart after successful transaction
        clearCart();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error processing transaction: $e');
      return false;
    }
  }
}