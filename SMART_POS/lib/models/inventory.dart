class InventoryTransaction {
  final String id;
  final String productId;
  final String productName;
  final String transactionType; // 'in', 'out', 'adjustment', 'damage', 'return'
  final int quantity;
  final double unitCost;
  final double totalCost;
  final DateTime date;
  final String referenceId; // Reference to original transaction if applicable
  final String notes;

  InventoryTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.transactionType,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.date,
    required this.referenceId,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'transactionType': transactionType,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'date': date.toIso8601String(),
      'referenceId': referenceId,
      'notes': notes,
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      transactionType: map['transactionType'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      unitCost: map['unitCost']?.toDouble() ?? 0.0,
      totalCost: map['totalCost']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      referenceId: map['referenceId'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}

class ProductVariant {
  final String id;
  final String productId;
  final String variantName; // e.g., "Size", "Color", "Flavor"
  final String variantValue; // e.g., "Large", "Red", "Strawberry"
  final String sku;
  final int quantity;
  final double price;
  final double cost;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.variantName,
    required this.variantValue,
    required this.sku,
    required this.quantity,
    required this.price,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'variantName': variantName,
      'variantValue': variantValue,
      'sku': sku,
      'quantity': quantity,
      'price': price,
      'cost': cost,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      variantName: map['variantName'] ?? '',
      variantValue: map['variantValue'] ?? '',
      sku: map['sku'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      cost: map['cost']?.toDouble() ?? 0.0,
    );
  }
}
