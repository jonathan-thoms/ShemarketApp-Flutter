import 'package:flutter/material.dart';

class Product {
  final String? id; // Use String for Firestore id
  final String title, description;
  final List<String> images;
  final double rating, price;
  final bool isFavourite, isPopular;
  final String? category;

  Product({
    this.id,
    required this.images,
    this.rating = 0.0,
    this.isFavourite = false,
    this.isPopular = false,
    required this.title,
    required this.price,
    required this.description,
    this.category,
  });

  factory Product.fromMap(Map<String, dynamic> map, {String? id}) {
    return Product(
      id: id,
      images: List<String>.from(map['images'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      isFavourite: map['isFavourite'] ?? false,
      isPopular: map['isPopular'] ?? false,
      title: map['title'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'],
    );
  }
}

// Our demo Products

List<Product> demoProducts = [
  Product(
    id: '1',
    images: [
      "assets/images/ps4_console_white_1.png",
      "assets/images/ps4_console_white_2.png",
      "assets/images/ps4_console_white_3.png",
      "assets/images/ps4_console_white_4.png",
    ],
    title: "Wireless Controller for PS4™",
    price: 64.99,
    description: description,
    rating: 4.8,
    isFavourite: true,
    isPopular: true,
  ),
  Product(
    id: '2',
    images: [
      "assets/images/Image Popular Product 2.png",
    ],
    title: "Nike Sport White - Man Pant",
    price: 50.5,
    description: description,
    rating: 4.1,
    isPopular: true,
  ),
  Product(
    id: '3',
    images: [
      "assets/images/glap.png",
    ],
    title: "Gloves XC Omega - Polygon",
    price: 36.55,
    description: description,
    rating: 4.1,
    isFavourite: true,
    isPopular: true,
  ),
  Product(
    id: '4',
    images: [
      "assets/images/wireless headset.png",
    ],
    title: "Logitech Head",
    price: 20.20,
    description: description,
    rating: 4.1,
    isFavourite: true,
  ),
];

const String description =
    "Wireless Controller for PS4™ gives you what you want in your gaming from over precision control your games to sharing …";
