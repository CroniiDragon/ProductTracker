class Product {
  final String? id;
  final String name;
  final String quantity;
  final String category;
  final String expiryDate;
  final int daysLeft;
  final String price;
  final DateTime? addedDate;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.expiryDate,
    required this.daysLeft,
    required this.price,
    this.addedDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? '',
      category: json['category'] ?? 'General',
      expiryDate: json['expiryDate'] ?? '',
      daysLeft: json['daysLeft'] ?? 0,
      price: json['price'] ?? '0.00 MDL',
      addedDate: json['addedDate'] != null 
          ? DateTime.tryParse(json['addedDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'expiryDate': expiryDate,
      'daysLeft': daysLeft,
      'price': price,
      if (addedDate != null) 'addedDate': addedDate!.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? quantity,
    String? category,
    String? expiryDate,
    int? daysLeft,
    String? price,
    DateTime? addedDate,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      daysLeft: daysLeft ?? this.daysLeft,
      price: price ?? this.price,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}