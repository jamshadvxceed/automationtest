class ProductModel {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.sizes,
    required this.colors,
    this.isFavorite = false,
  });

  // Calculate discount percentage
  double get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - price) / originalPrice * 100);
  }

  // Get formatted discount text
  String get discountText {
    final discount = discountPercentage;
    return discount > 0 ? '${discount.toInt()}% OFF' : '';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'sizes': sizes,
      'colors': colors,
      'isFavorite': isFavorite,
    };
  }

  // Create from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      price: json['price'].toDouble(),
      originalPrice: json['originalPrice'].toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      description: json['description'],
      sizes: List<String>.from(json['sizes']),
      colors: List<String>.from(json['colors']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Create a copy with updated values
  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? category,
    double? rating,
    int? reviewCount,
    String? description,
    List<String>? sizes,
    List<String>? colors,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
