import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerService _customerService = CustomerService();
  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  CustomerProvider() {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _customerService.getAllCustomers();
    } catch (e) {
      print('Error loading customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    _isLoading = true;
    notifyListeners();

    try {
      int result = await _customerService.addCustomer(customer);
      if (result != 0) {
        await loadCustomers(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding customer: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    _isLoading = true;
    notifyListeners();

    try {
      int result = await _customerService.updateCustomer(customer);
      if (result > 0) {
        await loadCustomers(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating customer: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(int? customerId) async {
    if (customerId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      int result = await _customerService.deleteCustomer(customerId);
      if (result > 0) {
        await loadCustomers(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting customer: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) {
      return _customers;
    }
    
    return _customers.where((customer) =>
      customer.name.toLowerCase().contains(query.toLowerCase()) ||
      (customer.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (customer.phone?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  List<Customer> getTopCustomers({int limit = 10}) {
    List<Customer> sortedCustomers = List.from(_customers);
    sortedCustomers.sort((a, b) => b.totalPurchase.compareTo(a.totalPurchase));
    return sortedCustomers.take(limit).toList();
  }
}