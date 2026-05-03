import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';
import '../services/razorpay_service.dart';
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
      final videoId = YoutubePlayer.convertUrlToId(widget.product.videoUrl!);
      if (videoId != null) {
        _ytController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            forceHD: false, // Ensure quality is set to auto, not forced high-res
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _razorpayService.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    // Payment verified, create order in Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final order = OrderModel(
      id: '', // Firestore will generate
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
            // Main Product Image
            GestureDetector(
              onTap: () => _showFullScreenImage(context, widget.product.imageUrl),
              child: Container(
                height: 350,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Icon(
                    widget.product.type == ProductType.camera
                        ? Icons.camera_alt
                        : (widget.product.type == ProductType.xRay ? Icons.flash_on : Icons.biotech),
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
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
                            '₹${widget.product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'In Stock',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_outlined),
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
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.red,
                        progressColors: const ProgressBarColors(
                          playedColor: Colors.red,
                          handleColor: Colors.redAccent,
                        ),
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

                  // Detailed Features with Images
                  if (widget.product.features.isNotEmpty) ...[
                    const Text('Key Features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...widget.product.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            feature.description,
                            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                          ),
                          if (feature.imageUrl != null) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _showFullScreenImage(context, feature.imageUrl!),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  feature.imageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 200,
                                      color: Colors.grey.shade50,
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
                  ],

                  // Technical Specs
                  const Text('Technical Specifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: widget.product.comparableSpecs.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(entry.key, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 40),
                  // WhatsApp Support
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.support_agent, color: Colors.green, size: 40),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Need expert advice?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Speak to our dental specialist.'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('WhatsApp'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: _isProcessing
            ? const Center(heightFactor: 1, child: CircularProgressIndicator())
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleAddToCart(context),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54), side: BorderSide(color: Theme.of(context).primaryColor)),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleBuyNow(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 54),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
