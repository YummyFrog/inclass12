import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class InventoryItem {
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final String category;
  final DateTime lastUpdated;

  InventoryItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.category = 'Uncategorized',
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'lastUpdated': Timestamp.fromDate(lastUpdated), // Now recognizes Timestamp
    };
  }

  factory InventoryItem.fromMap(String id, Map<String, dynamic> map) {
    return InventoryItem(
      id: id,
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      category: map['category'],
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }
}