import 'package:flutter/material.dart';

class CarouselResponseModel {
  final String image;
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;
  final double titleSize;
  final double subtitleSize;
  final int id;
  final bool is_product;

  CarouselResponseModel({
    required this.image,
    required this.title,
    required this.subtitle,
    this.titleColor = Colors.white,
    this.subtitleColor = Colors.white,
    this.titleSize = 24.0,
    this.subtitleSize = 16.0,
    this.id = 0,
    this.is_product = false,
  });

  factory CarouselResponseModel.fromJson(Map<String, dynamic> json) {
    return CarouselResponseModel(
      image: json['image'] ?? 'https://picsum.photos/400/200?random=${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? 'Başlık',
      subtitle: json['subtitle'] ?? 'Alt başlık',
      titleColor: _parseColor(json['titleColor'] ?? '#FFFFFF'),
      subtitleColor: _parseColor(json['subtitleColor'] ?? '#FFFFFF'),
      titleSize: (json['titleSize'] ?? 24).toDouble(),
      subtitleSize: (json['subtitleSize'] ?? 16).toDouble(),
      id: (json['id'] ?? 0),
      is_product: (json['is_product'] ?? false),
    );
  }

  static Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}