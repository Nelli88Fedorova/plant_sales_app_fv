// lib/models/product.dart
class Product {
  final int? id;
  final String name;
  final String category;
  final String? composition;
  final String? manufacturer;
  final String? package;
  final String? consumptionRate;
  final double? price;

  Product({
    this.id,
    required this.name,
    required this.category,
    this.composition,
    this.manufacturer,
    this.package,
    this.consumptionRate,
    this.price,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      composition: map['composition'] as String?,
      manufacturer: map['manufacturer'] as String?,
      package: map['package'] as String?,
      consumptionRate: map['consumption_rate'] as String?,
      price: (map['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'composition': composition,
      'manufacturer': manufacturer,
      'package': package,
      'consumption_rate': consumptionRate,
      'price': price,
    };
  }
}