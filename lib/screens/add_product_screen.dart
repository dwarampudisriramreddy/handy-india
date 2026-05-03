import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late String _name;
  late double _price;
  late double _shippingCharge;
  late String _description;
  late ProductType _selectedType;
  late bool _isFeatured;
  late String _imageUrl;
  late String _videoUrl;
  
  late List<TextEditingController> _galleryControllers;
  late List<FeatureController> _featureControllers;
  late List<TextEditingController> _specControllers;
  late List<CompSpecController> _compSpecControllers;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = p?.name ?? '';
    _price = p?.price ?? 0;
    _shippingCharge = p?.shippingCharge ?? (p?.toMap()['deliveryCharge']?.toDouble() ?? 0);
    _description = p?.description ?? '';
    _selectedType = p?.type ?? ProductType.camera;
    _isFeatured = p?.isFeatured ?? false;
    _imageUrl = p?.imageUrl ?? '';
    _videoUrl = p?.videoUrl ?? '';

    _galleryControllers = (p?.imageGallery ?? [])
        .map((url) => TextEditingController(text: url))
        .toList();

    _featureControllers = (p?.features ?? [])
        .map((f) => FeatureController(
              title: TextEditingController(text: f.title),
              desc: TextEditingController(text: f.description),
              url: TextEditingController(text: f.imageUrl ?? ''),
            ))
        .toList();

    _specControllers = (p?.specs ?? [])
        .map((s) => TextEditingController(text: s))
        .toList();
    
    _compSpecControllers = (p?.comparableSpecs ?? {})
        .entries
        .map((e) => CompSpecController(
              key: TextEditingController(text: e.key),
              val: TextEditingController(text: e.value),
            ))
        .toList();

    if (_galleryControllers.isEmpty) _galleryControllers.add(TextEditingController());
    if (_featureControllers.isEmpty) _featureControllers.add(FeatureController());
    if (_specControllers.isEmpty) _specControllers.add(TextEditingController());
    if (_compSpecControllers.isEmpty) _compSpecControllers.add(CompSpecController());
  }

  @override
  void dispose() {
    for (var c in _galleryControllers) c.dispose();
    for (var c in _featureControllers) c.dispose();
    for (var c in _specControllers) c.dispose();
    for (var c in _compSpecControllers) c.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      List<String> gallery = _galleryControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      List<ProductFeature> features = _featureControllers
          .where((c) => c.title.text.isNotEmpty && c.desc.text.isNotEmpty)
          .map((c) => ProductFeature(
                title: c.title.text.trim(),
                description: c.desc.text.trim(),
                imageUrl: c.url.text.trim().isEmpty ? null : c.url.text.trim(),
              ))
          .toList();

      List<String> specs = _specControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      Map<String, String> comparableSpecs = {};
      for (var c in _compSpecControllers) {
        if (c.key.text.isNotEmpty && c.val.text.isNotEmpty) {
          comparableSpecs[c.key.text.trim()] = c.val.text.trim();
        }
      }

      Product productData = Product(
        id: widget.product?.id ?? _name.toLowerCase().replaceAll(' ', '-'),
        name: _name,
        price: _price,
        shippingCharge: _shippingCharge,
        description: _description,
        type: _selectedType,
        imageUrl: _imageUrl,
        videoUrl: _videoUrl.isEmpty ? null : _videoUrl,
        imageGallery: gallery,
        features: features,
        specs: specs,
        comparableSpecs: comparableSpecs,
        isFeatured: _isFeatured,
      );

      try {
        if (widget.product == null) {
          await _firestoreService.addProduct(productData);
        } else {
          await _firestoreService.updateProduct(productData);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.product == null ? 'Product added successfully!' : 'Product updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add New Product' : 'Edit Product'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _price == 0 ? '' : _price.toString(),
                decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter price' : null,
                onSaved: (val) => _price = double.parse(val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _shippingCharge == 0 ? '' : _shippingCharge.toString(),
                decoration: const InputDecoration(labelText: 'Shipping Charge (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (val) => _shippingCharge = double.tryParse(val ?? '0') ?? 0,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Main Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
                onSaved: (val) => _description = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _imageUrl,
                decoration: const InputDecoration(labelText: 'Primary Image URL', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter image URL' : null,
                onSaved: (val) => _imageUrl = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _videoUrl,
                decoration: const InputDecoration(labelText: 'YouTube Video URL (Optional)', border: OutlineInputBorder(), hintText: 'https://www.youtube.com/watch?v=...'),
                onSaved: (val) => _videoUrl = val!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ProductType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: ProductType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              SwitchListTile(
                title: const Text('Featured on Home Screen'),
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
              ),

              const Divider(height: 40),
              _buildSectionTitle('Image Gallery'),
              ..._galleryControllers.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: entry.value, decoration: InputDecoration(hintText: 'Image URL ${entry.key + 1}', border: const OutlineInputBorder()))),
                    IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => _galleryControllers.removeAt(entry.key))),
                  ],
                ),
              )),
              TextButton.icon(onPressed: () => setState(() => _galleryControllers.add(TextEditingController())), icon: const Icon(Icons.add), label: const Text('Add Gallery Image')),

              const Divider(height: 40),
              _buildSectionTitle('Product Features'),
              ..._featureControllers.asMap().entries.map((entry) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: TextField(controller: entry.value.title, decoration: const InputDecoration(labelText: 'Feature Title'))),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _featureControllers.removeAt(entry.key))),
                        ],
                      ),
                      TextField(controller: entry.value.desc, decoration: const InputDecoration(labelText: 'Feature Description'), maxLines: 2),
                      TextField(controller: entry.value.url, decoration: const InputDecoration(labelText: 'Feature Image URL (Optional)')),
                    ],
                  ),
                ),
              )),
              TextButton.icon(onPressed: () => setState(() => _featureControllers.add(FeatureController())), icon: const Icon(Icons.add), label: const Text('Add Feature')),

              const Divider(height: 40),
              _buildSectionTitle('Bullet Specifications'),
              ..._specControllers.asMap().entries.map((entry) => Row(
                children: [
                  Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 8), child: TextField(controller: entry.value, decoration: const InputDecoration(hintText: 'e.g. 1080p Full HD', border: OutlineInputBorder())))),
                  IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => _specControllers.removeAt(entry.key))),
                ],
              )),
              TextButton.icon(onPressed: () => setState(() => _specControllers.add(TextEditingController())), icon: const Icon(Icons.add), label: const Text('Add Specification')),

              const Divider(height: 40),
              _buildSectionTitle('Comparable Technical Data'),
              ..._compSpecControllers.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: TextField(controller: entry.value.key, decoration: const InputDecoration(labelText: 'Spec Name', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(flex: 3, child: TextField(controller: entry.value.val, decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()))),
                    IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => _compSpecControllers.removeAt(entry.key))),
                  ],
                ),
              )),
              TextButton.icon(onPressed: () => setState(() => _compSpecControllers.add(CompSpecController())), icon: const Icon(Icons.add), label: const Text('Add Comparison Row')),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(widget.product == null ? 'CREATE PRODUCT IN CLOUD' : 'UPDATE CLOUD PRODUCT', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
    );
  }
}

class FeatureController {
  final TextEditingController title;
  final TextEditingController desc;
  final TextEditingController url;
  FeatureController({TextEditingController? title, TextEditingController? desc, TextEditingController? url}) 
    : title = title ?? TextEditingController(),
      desc = desc ?? TextEditingController(),
      url = url ?? TextEditingController();

  void dispose() {
    title.dispose();
    desc.dispose();
    url.dispose();
  }
}

class CompSpecController {
  final TextEditingController key;
  final TextEditingController val;
  CompSpecController({TextEditingController? key, TextEditingController? val})
    : key = key ?? TextEditingController(),
      val = val ?? TextEditingController();

  void dispose() {
    key.dispose();
    val.dispose();
  }
}
