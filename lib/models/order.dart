import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double shippingCharge;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final String? paymentId;
  final String? paymentStatus;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingCharge,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.paymentId,
    this.paymentStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((i) => i.toMap()).toList(),
      'shippingCharge': shippingCharge,
      'totalAmount': totalAmount,
      'status': status.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentId': paymentId,
      'paymentStatus': paymentStatus,
    };
  }

  factory OrderModel.fromFirestore(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((i) => OrderItem.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      shippingCharge: (data['shippingCharge'] ?? (data['deliveryCharge'] ?? 0)).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values[data['status'] ?? 0],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentId: data['paymentId'],
      paymentStatus: data['paymentStatus'],
    );
  }
}
