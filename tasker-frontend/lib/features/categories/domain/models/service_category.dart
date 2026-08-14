import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final double basePrice;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.basePrice,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? '',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
    );
  }

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'plumbing': return Icons.plumbing;
      case 'landscaping': return Icons.grass;
      case 'laundry': return Icons.local_laundry_service;
      case 'furniture_assembly': return Icons.chair;
      case 'mounting': return Icons.handyman;
      case 'electrical': return Icons.electrical_services;
      case 'moving': return Icons.local_shipping;
      case 'carpentry': return Icons.carpenter;
      case 'painting': return Icons.format_paint;
      case 'appliance_repair': return Icons.kitchen;
      case 'cleaning': return Icons.cleaning_services;
      case 'roofing': return Icons.roofing;
      case 'pest_control': return Icons.pest_control;
      default: return Icons.home_repair_service;
    }
  }
}
