import '../models/customer.dart';
import 'database_service.dart';

class CustomerService {
  final DatabaseService _databaseService = DatabaseService();

  // Add a new customer
  Future<int> addCustomer(Customer customer) async {
    return await _databaseService.insertCustomer(customer);
  }

  // Get a customer by ID
  Future<Customer?> getCustomer(int? id) async {
    if (id == null) return null;
    return await _databaseService.getCustomer(id);
  }

  // Get a customer by name
  Future<Customer?> getCustomerByName(String name) async {
    return await _databaseService.getCustomerByName(name);
  }

  // Get all customers
  Future<List<Customer>> getAllCustomers() async {
    return await _databaseService.getAllCustomers();
  }

  // Update a customer
  Future<int> updateCustomer(Customer customer) async {
    if (customer.id == null) return 0;
    return await _databaseService.updateCustomer(customer);
  }

  // Delete a customer
  Future<int> deleteCustomer(int? id) async {
    if (id == null) return 0;
    return await _databaseService.deleteCustomer(id);
  }

  // Update customer's total purchase amount
  Future<bool> updateCustomerTotalPurchase(int? customerId, double newTotal) async {
    if (customerId == null) return false;
    try {
      Customer? customer = await _databaseService.getCustomer(customerId);
      if (customer != null) {
        Customer updatedCustomer = customer.copyWith(
          totalPurchase: newTotal,
          updatedAt: DateTime.now(),
        );
        int result = await _databaseService.updateCustomer(updatedCustomer);
        return result > 0;
      }
      return false;
    } catch (e) {
      print('Error updating customer total purchase: $e');
      return false;
    }
  }

  // Add to customer's total purchase amount
  Future<bool> addToCustomerTotalPurchase(int? customerId, double amount) async {
    if (customerId == null) return false;
    try {
      Customer? customer = await _databaseService.getCustomer(customerId);
      if (customer != null) {
        double newTotal = customer.totalPurchase + amount;
        return await updateCustomerTotalPurchase(customerId, newTotal);
      }
      return false;
    } catch (e) {
      print('Error adding to customer total purchase: $e');
      return false;
    }
  }

  // Search customers by name
  Future<List<Customer>> searchCustomersByName(String name) async {
    List<Customer> allCustomers = await _databaseService.getAllCustomers();
    return allCustomers.where((customer) => 
      customer.name.toLowerCase().contains(name.toLowerCase()) ||
      (customer.phone?.toLowerCase().contains(name.toLowerCase()) ?? false) ||
      (customer.email?.toLowerCase().contains(name.toLowerCase()) ?? false)
    ).toList();
  }

  // Get top customers by purchase amount
  Future<List<Customer>> getTopCustomers({int limit = 10}) async {
    List<Customer> allCustomers = await _databaseService.getAllCustomers();
    allCustomers.sort((a, b) => b.totalPurchase.compareTo(a.totalPurchase));
    return allCustomers.take(limit).toList();
  }
}