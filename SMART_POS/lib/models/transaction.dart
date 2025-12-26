class Transaction {
  final int? id;
  final String transactionId;
  final int? customerId;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final String status; // 'completed', 'pending', 'cancelled'
  final DateTime transactionDate;
  final String? notes;
  final bool isOnline; // true if online, false if offline

  Transaction({
    this.id,
    required this.transactionId,
    this.customerId,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.transactionDate,
    this.notes,
    required this.isOnline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'customerId': customerId,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionDate': transactionDate.toIso8601String(),
      'notes': notes,
      'isOnline': isOnline ? 1 : 0,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      transactionId: map['transactionId'] ?? '',
      customerId: map['customerId'],
      subtotal: (map['subtotal'] ?? 0.0) is String
          ? double.tryParse(map['subtotal']) ?? 0.0
          : (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0) is String
          ? double.tryParse(map['tax']) ?? 0.0
          : (map['tax'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0) is String
          ? double.tryParse(map['discount']) ?? 0.0
          : (map['discount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0) is String
          ? double.tryParse(map['total']) ?? 0.0
          : (map['total'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? 'pending',
      transactionDate: DateTime.parse(map['transactionDate']),
      notes: map['notes'],
      isOnline: (map['isOnline'] == 1),
    );
  }

  Transaction copyWith({
    int? id,
    String? transactionId,
    int? customerId,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    String? paymentMethod,
    String? status,
    DateTime? transactionDate,
    String? notes,
    bool? isOnline,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      customerId: customerId ?? this.customerId,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}