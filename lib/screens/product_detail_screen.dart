import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
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
                  
                  // Features and Specs...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
