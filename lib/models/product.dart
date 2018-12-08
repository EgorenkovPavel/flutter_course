import 'package:flutter/material.dart';
import './location_data.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final bool isFavorite;
  final String userId;
  final String userEmail;
  final LocationData location;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.image,
      @required this.userId,
      @required this.userEmail,
      @required this.location,
      this.isFavorite = false});
}
