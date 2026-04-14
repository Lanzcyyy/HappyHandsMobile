class Product {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;
  final String description;
  final int? stock;
  final String? category;
  final List<String> imageUrls;
  final double? rating;
  final int? reviewCount;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.description,
    this.stock,
    this.category,
    this.imageUrls = const [],
    this.rating,
    this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle multiple image URLs from comma-separated string
    String? imagePath = json['image_path']?.toString() ?? 
                      json['image']?.toString() ?? 
                      json['main_image']?.toString() ?? 
                      json['imageurl']?.toString();
    
    List<String> images = [];
    if (imagePath != null && imagePath.isNotEmpty) {
      images = imagePath.split(',').map((url) => url.trim()).where((url) => url.isNotEmpty).toList();
    }
    
    return Product(
      id: (json['id'] ?? json['productID'] ?? json['product_id'] ?? 0) is num 
          ? (json['id'] ?? json['productID'] ?? json['product_id'] as num).toInt()
          : int.tryParse('${json['id'] ?? json['productID'] ?? json['product_id']}') ?? 0,
      name: (json['name'] ?? json['title'] ?? '').toString(),
      price: json['price'] is num 
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}') ?? 0.0,
      imageUrl: images.isNotEmpty ? images.first : null,
      description: (json['description'] ?? json['desc'] ?? json['details'] ?? json['productdesc'] ?? '').toString(),
      stock: json['stock'] is num ? (json['stock'] as num).toInt() : null,
      category: json['category']?.toString(),
      imageUrls: images,
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] is num ? (json['review_count'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'stock': stock,
      'category': category,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? imageUrl,
    String? description,
    int? stock,
    String? category,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: ₱$price, stock: $stock}';
  }
}

