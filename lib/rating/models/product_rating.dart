import 'package:flutter/foundation.dart';

class ProductRating {
  final String id; // UUID
  final String productId; // Foreign Key to Product
  final String? userId; // Foreign Key to User (nullable)
  final String? userName; // For displaying the user's name
  final int rating; // PositiveSmallIntegerField
  final String description; // TextField

  ProductRating({
    required this.id,
    required this.productId,
    this.userId,
    this.userName,
    required this.rating,
    required this.description,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      id: json['id'],
      productId: json['product'],
      userId: json['user']?['id'], // Null-safe access if user is optional
      userName: json['user']?['username'], // Null-safe access for user name
      rating: json['rating'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'user': userId,
      'rating': rating,
      'description': description,
    };
  }
}
