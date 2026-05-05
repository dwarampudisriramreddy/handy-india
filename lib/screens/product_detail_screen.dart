import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';
import '../services/razorpay_service.dart';
import '../services/currency_helper.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final RazorpayService _razorpayService = RazorpayService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _razorpayService.setCallbacks(
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentFailure,
    );

    if (widget.product.videoUrl != null && widget.product.videoUrl!.isNotEmpty) {
      final videoId = YoutubePlayerController.convertUrlToId(widget.product.videoUrl!);
      if (videoId != null) {
        _ytController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: true, // Mute the video by default
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ytController?.close();
    _razorpayService.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final order = OrderModel(
      id: '',
      userId: user.uid,
      items: [
        OrderItem(
          productId: widget.product.id,
          productName: widget.product.name,
          quantity: 1,
          price: widget.product.price,
        ),
      ],
      shippingCharge: widget.product.shippingCharge,
      totalAmount: widget.product.price + widget.product.shippingCharge,
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
      paymentId: response.paymentId,
      paymentStatus: 'PAID',
    );

    await _firestoreService.createOrder(order);

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful! Order placed.')),
      );
    }
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}')),
      );
    }
  }

  void _handleBuyNow(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final config = await _firestoreService.getAppConfig();
      _razorpayService.setApiKey(config.razorpayKey);

      _razorpayService.openCheckout(
        amount: widget.product.price + widget.product.shippingCharge,
        name: widget.product.name,
        description: 'Buying ${widget.product.name}',
        email: user.email ?? 'customer@example.com',
        contact: user.phoneNumber ?? '9999999999',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load payment settings: $e')),
        );
      }
    }
  }

  void _handleAddToCart(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to Cart!')),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator(color: Colors.white);
                },
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.name, style: const TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showFullScreenImage(context, widget.product.imageUrl),
              child: Container(
                height: 350,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyHelper.format(widget.product.price),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (widget.product.shippingCharge > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '+ ₹${widget.product.shippingCharge.toStringAsFixed(0)} shipping charge',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Free Shipping',
                            style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Gallery Section
                  if (widget.product.imageGallery.isNotEmpty) ...[
                    const Text('Product Showcase', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.product.imageGallery.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullScreenImage(context, widget.product.imageGallery[index]),
                            child: Container(
                              width: 240,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.product.imageGallery[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Video Section
                  if (_ytController != null) ...[
                    const Text('Product Video', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: YoutubePlayer(
                        controller: _ytController!,
                        aspectRatio: 16 / 9,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Bullet Specifications
                  if (widget.product.specs.isNotEmpty) ...[
                    const Text('Key Specifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...widget.product.specs.map((spec) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: Icon(Icons.circle, size: 6, color: Color(0xFFD32F2F)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(spec, style: const TextStyle(fontSize: 15, color: Colors.black87))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 32),
                  ],

                  // Product Features (Detailed)
                  if (widget.product.features.isNotEmpty) ...[
                    const Text('Product Features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...widget.product.features.map((feature) => _FeatureTile(feature: feature)),
                    const SizedBox(height: 16),
                  ],

                  // Technical Data Table
                  if (widget.product.comparableSpecs.isNotEmpty) ...[
                    const Text('Technical Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(3),
                          },
                          children: widget.product.comparableSpecs.entries.map((e) {
                            final isEven = widget.product.comparableSpecs.keys.toList().indexOf(e.key) % 2 == 0;
                            return TableRow(
                              decoration: BoxDecoration(
                                color: isEven ? Colors.grey.shade50 : Colors.white,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(e.value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleAddToCart(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFD32F2F)),
                    foregroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ADD TO CART', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _handleBuyNow(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isProcessing 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('BUY NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final ProductFeature feature;
  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (feature.imageUrl != null && feature.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                feature.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: 12),
          Text(feature.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}
