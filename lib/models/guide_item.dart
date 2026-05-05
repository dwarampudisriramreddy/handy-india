import 'package:cloud_firestore/cloud_firestore.dart';

class GuideItem {
  final String id;
  final String title;
  final String description;
  final String category; // 'camera', 'rvg', 'xRay'

  GuideItem({required this.id, required this.title, required this.description, required this.category});

  factory GuideItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return GuideItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'camera',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'description': description, 'category': category};
  }
}
