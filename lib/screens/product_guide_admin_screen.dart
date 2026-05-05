import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductGuideAdminScreen extends StatefulWidget {
  const ProductGuideAdminScreen({super.key});

  @override
  State<ProductGuideAdminScreen> createState() => _ProductGuideAdminScreenState();
}

class _ProductGuideAdminScreenState extends State<ProductGuideAdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _editGuideDescription(Product product) {
    final controller = TextEditingController(text: product.comparableSpecs['Guide Description'] ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Guide for ${product.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Guide Description', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newSpecs = Map<String, String>.from(product.comparableSpecs);
              newSpecs['Guide Description'] = controller.text;
              
              // Update using existing FirestoreService (requires adding/updating the map)
              final updatedProduct = Product(
                id: product.id,
                name: product.name,
                description: product.description,
                price: product.price,
                shippingCharge: product.shippingCharge,
                imageUrl: product.imageUrl,
                videoUrl: product.videoUrl,
                imageGallery: product.imageGallery,
                features: product.features,
                type: product.type,
                specs: product.specs,
                comparableSpecs: newSpecs,
                isFeatured: product.isFeatured,
              );
              await _firestoreService.updateProduct(updatedProduct);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Product Guide Text'), backgroundColor: const Color(0xFFD32F2F)),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data!;
          
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(product.comparableSpecs['Guide Description'] ?? 'No guide text set.'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFD32F2F)),
                    onPressed: () => _editGuideDescription(product),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
