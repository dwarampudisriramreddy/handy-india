import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class ProductGuideScreen extends StatefulWidget {
  final List<Product> allProducts;
  const ProductGuideScreen({super.key, required this.allProducts});

  @override
  State<ProductGuideScreen> createState() => _ProductGuideScreenState();
}

class _ProductGuideScreenState extends State<ProductGuideScreen> {
  ProductType? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Me to Products'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: _selectedCategory == null
          ? _buildCategorySelection()
          : _buildProductDecision(),
    );
  }

  Widget _buildCategorySelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What are you looking for?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildGuideButton(ProductType.camera, 'Intraoral Cameras', Icons.camera_alt),
          _buildGuideButton(ProductType.rvg, 'RVG Sensors', Icons.biotech),
          _buildGuideButton(ProductType.xRay, 'Portable X-Ray Units', Icons.flash_on),
        ],
      ),
    );
  }

  Widget _buildGuideButton(ProductType type, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _selectedCategory = type),
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFD32F2F),
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFD32F2F))),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDecision() {
    final products = widget.allProducts.where((p) => p.type == _selectedCategory).toList();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: () => setState(() => _selectedCategory = null), icon: const Icon(Icons.arrow_back)),
              const Text('Select your requirement:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
          child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
          final product = products[index];
          return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  product.comparableSpecs['Guide Description'] ?? 'Click to view product details',
                  maxLines: 3, 
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: product.comparableSpecs.containsKey('Guide Description') ? Colors.black87 : Colors.grey.shade600,
                    fontStyle: product.comparableSpecs.containsKey('Guide Description') ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),

            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
          ),
          );
          },
          ),
          ),

        ],
      ),
    );
  }
}
