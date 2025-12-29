import 'package:flutter/foundation.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  Map<String, dynamic>? _salesSummary;
  Map<String, dynamic>? _customerAnalytics;
  Map<String, dynamic>? _productAnalytics;
  List<Map<String, dynamic>>? _dailySalesTrend;
  Map<String, dynamic>? _paymentMethodAnalysis;
  
  Map<String, dynamic>? get salesSummary => _salesSummary;
  Map<String, dynamic>? get customerAnalytics => _customerAnalytics;
  Map<String, dynamic>? get productAnalytics => _productAnalytics;
  List<Map<String, dynamic>>? get dailySalesTrend => _dailySalesTrend;
  Map<String, dynamic>? get paymentMethodAnalysis => _paymentMethodAnalysis;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> loadDashboardData({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load all analytics data
      _salesSummary = await _analyticsService.getSalesSummary(
        startDate: startDate,
        endDate: endDate,
      );
      
      _customerAnalytics = await _analyticsService.getCustomerAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      
      _productAnalytics = await _analyticsService.getProductAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      
      _dailySalesTrend = await _analyticsService.getDailySalesTrend(
        startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate: endDate ?? DateTime.now(),
      );
      
      _paymentMethodAnalysis = await _analyticsService.getPaymentMethodAnalysis(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get sales summary for specific period
  Future<Map<String, dynamic>> getSalesSummary({DateTime? startDate, DateTime? endDate}) async {
    return await _analyticsService.getSalesSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  // Get customer analytics for specific period
  Future<Map<String, dynamic>> getCustomerAnalytics({DateTime? startDate, DateTime? endDate}) async {
    return await _analyticsService.getCustomerAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  // Get product analytics for specific period
  Future<Map<String, dynamic>> getProductAnalytics({DateTime? startDate, DateTime? endDate}) async {
    return await _analyticsService.getProductAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  // Get daily sales trend
  Future<List<Map<String, dynamic>>> getDailySalesTrend({DateTime? startDate, DateTime? endDate}) async {
    return await _analyticsService.getDailySalesTrend(
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate: endDate ?? DateTime.now(),
    );
  }
  
  // Get monthly sales summary
  Future<List<Map<String, dynamic>>> getMonthlySalesSummary({int? year}) async {
    return await _analyticsService.getMonthlySalesSummary(
      year: year ?? DateTime.now().year,
    );
  }
  
  // Refresh all data
  Future<void> refreshData() async {
    await loadDashboardData();
  }
}