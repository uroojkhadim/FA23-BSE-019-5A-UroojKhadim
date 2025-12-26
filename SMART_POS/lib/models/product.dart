class Product {
  final int? id;
  final String name;
  final String sku;
  final double price;
  final double cost;
  final int quantity;
  final String category;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.category,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      price: (map['price'] ?? 0.0) is String
          ? double.tryParse(map['price']) ?? 0.0
          : (map['price'] ?? 0.0).toDouble(),
      cost: (map['cost'] ?? 0.0) is String
          ? double.tryParse(map['cost']) ?? 0.0
          : (map['cost'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      category: map['category'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? sku,
    double? price,
    double? cost,
    int? quantity,
    String? category,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}