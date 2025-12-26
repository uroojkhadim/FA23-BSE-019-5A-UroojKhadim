class TransactionItem {
  final int? id;
  final String transactionId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      transactionId: map['transactionId'] ?? '',
      productId: map['productId'] ?? 0,
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0.0) is String
          ? double.tryParse(map['unitPrice']) ?? 0.0
          : (map['unitPrice'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0) is String
          ? double.tryParse(map['total']) ?? 0.0
          : (map['total'] ?? 0.0).toDouble(),
    );
  }

  TransactionItem copyWith({
    int? id,
    String? transactionId,
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? total,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
    );
  }
}