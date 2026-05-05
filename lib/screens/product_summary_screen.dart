import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/currency_helper.dart';
import 'add_product_screen.dart';

class ProductSummaryScreen extends StatefulWidget {
  final bool isAdmin;
  const ProductSummaryScreen({super.key, this.isAdmin = true});

  @override
  State<ProductSummaryScreen> createState() => _ProductSummaryScreenState();
}

class _ProductSummaryScreenState extends State<ProductSummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _stickyScrollController = ScrollController();
  final ScrollController _dataScrollController = ScrollController();

  static const double _rowHeight = 110.0;
  static const double _headerHeight = 60.0;
  static const double _stickyWidth = 150.0;

  @override
  void initState() {
    super.initState();
    _stickyScrollController.addListener(() {
      if (_stickyScrollController.hasClients && _dataScrollController.hasClients) {
        if (_stickyScrollController.offset != _dataScrollController.offset) {
          _dataScrollController.jumpTo(_stickyScrollController.offset);
        }
      }
    });
    _dataScrollController.addListener(() {
      if (_dataScrollController.hasClients && _stickyScrollController.hasClients) {
        if (_dataScrollController.offset != _stickyScrollController.offset) {
          _stickyScrollController.jumpTo(_dataScrollController.offset);
        }
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _stickyScrollController.dispose();
    _dataScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.isAdmin ? 'Inventory Dashboard' : 'Compare Products',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final allSpecKeys = <String>{};
          for (var p in products) {
            allSpecKeys.addAll(p.comparableSpecs.keys);
          }
          final sortedSpecKeys = allSpecKeys.toList()..sort();

          return Column(
            children: [
              _buildHeaderSection(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        // Sticky Left Column
                        _buildStickyColumn(products),
                        // Scrollable Specs
                        Expanded(
                          child: _buildScrollableData(products, sortedSpecKeys),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFD32F2F),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Text(
            widget.isAdmin ? 'Master Inventory Matrix' : 'Technical Data Comparison',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isAdmin ? 'Edit values directly in the table.' : 'Side-by-side technical specification comparison.',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyColumn(List<Product> products) {
    return Container(
      width: _stickyWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1.5)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: _headerHeight,
            alignment: Alignment.center,
            color: const Color(0xFFF1F3F4),
            child: const Text('EQUIPMENT', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD32F2F), fontSize: 10, letterSpacing: 1.5)),
          ),
          // Rows
          Expanded(
            child: ListView.builder(
              controller: _stickyScrollController,
              physics: const ClampingScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final isEven = index % 2 == 0;
                final product = products[index];
                return Container(
                  height: _rowHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: isEven ? Colors.white : const Color(0xFFF8F9FA),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 45,
                        width: 45,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(product.imageUrl, fit: BoxFit.contain)
                            : const Icon(Icons.image_outlined, size: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, height: 1.2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableData(List<Product> products, List<String> sortedSpecKeys) {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      thickness: 6,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          controller: _dataScrollController,
          scrollDirection: Axis.vertical,
          physics: const ClampingScrollPhysics(),
          child: DataTable(
            columnSpacing: 40,
            horizontalMargin: 24,
            dataRowMaxHeight: _rowHeight,
            dataRowMinHeight: _rowHeight,
            headingRowHeight: _headerHeight,
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F3F4)),
            dividerThickness: 0.5,
            columns: [
              const DataColumn(label: _HeaderCell(label: 'PRICE')),
              const DataColumn(label: _HeaderCell(label: 'CATEGORY')),
              if (widget.isAdmin) const DataColumn(label: _HeaderCell(label: 'FEATURED')),
              ...sortedSpecKeys.map((key) => DataColumn(label: _HeaderCell(label: key.toUpperCase()))),
              if (widget.isAdmin) const DataColumn(label: _HeaderCell(label: 'ACTIONS')),
            ],
            rows: products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              final isEven = index % 2 == 0;
              return DataRow(
                color: MaterialStateProperty.all(isEven ? Colors.white : const Color(0xFFF8F9FA)),
                cells: [
                  DataCell(
                    Text(CurrencyHelper.format(product.price), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD32F2F), fontSize: 13)),
                    onTap: widget.isAdmin ? () => _editPrice(context, product) : null,
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                      child: Text(product.type.name.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black54)),
                    ),
                  ),
                  if (widget.isAdmin)
                    DataCell(
                      Switch(
                        value: product.isFeatured,
                        activeColor: const Color(0xFFD32F2F),
                        onChanged: (val) => _toggleFeatured(product, val),
                      ),
                    ),
                  ...sortedSpecKeys.map((key) => DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            product.comparableSpecs[key] ?? '-',
                            style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: widget.isAdmin ? () => _editSpec(context, product, key) : null,
                      )),
                  if (widget.isAdmin)
                    DataCell(
                      Row(
                        children: [
                          _ActionButton(icon: Icons.edit_outlined, color: Colors.blue, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen(product: product)))),
                          const SizedBox(width: 10),
                          _ActionButton(icon: Icons.delete_outline, color: Colors.red, onPressed: () => _showDeleteDialog(context, product)),
                        ],
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // --- Utility Methods (Same Logic, Preserved) ---

  void _editSpec(BuildContext context, Product product, String key) {
    final controller = TextEditingController(text: product.comparableSpecs[key] ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $key'),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: key, border: const OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final newSpecs = Map<String, String>.from(product.comparableSpecs);
              newSpecs[key] = controller.text;
              await _firestoreService.updateProduct(_copyWithSpecs(product, newSpecs));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
          ),
        ],
      ),
    );
  }

  void _editPrice(BuildContext context, Product product) {
    final controller = TextEditingController(text: product.price.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Price Update'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final price = double.tryParse(controller.text);
              if (price != null) {
                await _firestoreService.updateProduct(_copyWithPrice(product, price));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('UPDATE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
          ),
        ],
      ),
    );
  }

  void _toggleFeatured(Product product, bool isFeatured) async {
    await _firestoreService.updateProduct(_copyWithFeatured(product, isFeatured));
  }

  Product _copyWithSpecs(Product p, Map<String, String> specs) => Product(id: p.id, name: p.name, description: p.description, price: p.price, shippingCharge: p.shippingCharge, imageUrl: p.imageUrl, videoUrl: p.videoUrl, imageGallery: p.imageGallery, features: p.features, type: p.type, specs: p.specs, comparableSpecs: specs, isFeatured: p.isFeatured);
  Product _copyWithPrice(Product p, double price) => Product(id: p.id, name: p.name, description: p.description, price: price, shippingCharge: p.shippingCharge, imageUrl: p.imageUrl, videoUrl: p.videoUrl, imageGallery: p.imageGallery, features: p.features, type: p.type, specs: p.specs, comparableSpecs: p.comparableSpecs, isFeatured: p.isFeatured);
  Product _copyWithFeatured(Product p, bool featured) => Product(id: p.id, name: p.name, description: p.description, price: p.price, shippingCharge: p.shippingCharge, imageUrl: p.imageUrl, videoUrl: p.videoUrl, imageGallery: p.imageGallery, features: p.features, type: p.type, specs: p.specs, comparableSpecs: p.comparableSpecs, isFeatured: featured);

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Remove "${product.name}" from database?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await _firestoreService.deleteProduct(product.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, fontSize: 10, letterSpacing: 1.2));
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({required this.icon, required this.color, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: IconButton(icon: Icon(icon, color: color, size: 18), onPressed: onPressed, visualDensity: VisualDensity.compact),
    );
  }
}
