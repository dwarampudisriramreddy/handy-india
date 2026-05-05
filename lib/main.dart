import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'models/product.dart';
import 'models/workflow_demo.dart';
import 'screens/product_detail_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_panel.dart';
import 'screens/product_summary_screen.dart';
import 'screens/product_guide_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/currency_helper.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HandyIndiaApp());
}

class HandyIndiaApp extends StatelessWidget {
  const HandyIndiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handy India Dental - Equipment Manufacturer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          primary: const Color(0xFFD32F2F),
          secondary: const Color(0xFFB71C1C),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Open to Splash Screen first
      home: const SplashScreen(),
    );
  }
}

class MainNavigationLayout extends StatefulWidget {
  const MainNavigationLayout({super.key});

  @override
  State<MainNavigationLayout> createState() => _MainNavigationLayoutState();
}

class _MainNavigationLayoutState extends State<MainNavigationLayout> {
  int _selectedIndex = 0;
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isAdmin = user?.email == AuthService.adminEmail;

        final List<Widget> screens = [
          const HomeScreen(),
          const DashboardScreen(),
        ];

        final List<BottomNavigationBarItem> navItems = [
          const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Store'),
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize_outlined), label: 'My Practice'),
        ];

        if (isAdmin) {
          screens.add(const AdminPanel());
          navItems.add(const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'));
        }

        // Ensure index doesn't go out of bounds if admin logs out
        int safeIndex = _selectedIndex >= screens.length ? 0 : _selectedIndex;

        return Scaffold(
          body: screens[safeIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: safeIndex,
            selectedItemColor: const Color(0xFFD32F2F),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: navItems,
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  ProductType? _selectedType;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildFilterChip(ProductType? type, String label) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedType = type;
          });
        },
        selectedColor: const Color(0xFFD32F2F),
        backgroundColor: Colors.grey.shade100,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/assets/company_logo.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => const Text('Handy India'),
        ),
        actions: [
          StreamBuilder<User?>(
            stream: AuthService().user,
            builder: (context, snapshot) {
              if (snapshot.hasData) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Login', style: TextStyle(color: Color(0xFFD32F2F))),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final List<Product> displayProducts = snapshot.data!;
          final List<Product> filteredProducts = _selectedType == null 
              ? displayProducts 
              : displayProducts.where((p) => p.type == _selectedType).toList();
              
          final List<Product> videoProducts = displayProducts.where((p) => p.videoUrl != null && p.videoUrl!.isNotEmpty).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildFilterChip(null, 'All'),
                        _buildFilterChip(ProductType.camera, 'Cameras'),
                        _buildFilterChip(ProductType.rvg, 'RVG Sensors'),
                        _buildFilterChip(ProductType.xRay, 'X-Ray Units'),
                        _buildFilterChip(ProductType.accessory, 'Accessories'),
                      ],
                    ),
                  ),
                ),
                
                // Product Videos Section
                if (videoProducts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text('Product Demos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: videoProducts.length,
                      itemBuilder: (context, index) {
                        final product = videoProducts[index];
                        
                        return _ProductVideoItem(product: product);
                      },
                    ),
                  ),
                ],

                // Workflow Demos Section
                StreamBuilder<List<WorkflowDemo>>(
                  stream: _firestoreService.getWorkflowDemos(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      debugPrint('Workflow Demos Error: ${snapshot.error}');
                      return const SizedBox.shrink();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                    final demos = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text('Workflow Demos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: demos.length,
                            itemBuilder: (context, index) {
                              return _WorkflowVideoItem(demo: demos[index]);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Featured Products
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedType == null 
                            ? 'Featured Imaging Solutions' 
                            : '${_selectedType!.name.toUpperCase()} Solutions', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProductSummaryScreen(isAdmin: false)),
                          );
                        },
                        icon: const Icon(Icons.compare_arrows, size: 18),
                        label: const Text('Compare All', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _ProductCard(product: filteredProducts[index]);
                  },
                ),
                const SizedBox(height: 16),
                
                // Bottom Guide Me Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final all = snapshot.data!;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductGuideScreen(allProducts: all)));
                    },
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Guide me to the right product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductVideoItem extends StatefulWidget {
  final Product product;
  const _ProductVideoItem({required this.product});

  @override
  State<_ProductVideoItem> createState() => _ProductVideoItemState();
}

class _ProductVideoItemState extends State<_ProductVideoItem> {
  late YoutubePlayerController _controller;

  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;
    final videoId = YoutubePlayerController.convertUrlToId(url);
    if (videoId != null) return videoId;

    // Fallback for formats that convertUrlToId might miss (like some Shorts formats)
    final regex = RegExp(
      r'^(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.product.videoUrl!);
    if (videoId != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          mute: false,
          showControls: true,
          showFullscreenButton: true,
          loop: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (mounted) {
      final videoId = _extractVideoId(widget.product.videoUrl!);
      if (videoId != null) {
        _controller.close();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _extractVideoId(widget.product.videoUrl!);
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: videoId != null 
                  ? YoutubePlayer(controller: _controller)
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Center(child: Icon(Icons.video_library_outlined, color: Colors.grey)),
                    ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailScreen(product: widget.product)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowVideoItem extends StatefulWidget {
  final WorkflowDemo demo;
  const _WorkflowVideoItem({required this.demo});

  @override
  State<_WorkflowVideoItem> createState() => _WorkflowVideoItemState();
}

class _WorkflowVideoItemState extends State<_WorkflowVideoItem> {
  late YoutubePlayerController _controller;

  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;
    final videoId = YoutubePlayerController.convertUrlToId(url);
    if (videoId != null) return videoId;

    final regex = RegExp(
      r'^(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.demo.videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          mute: false,
          showControls: true,
          showFullscreenButton: true,
          loop: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (mounted) {
      final videoId = _extractVideoId(widget.demo.videoUrl);
      if (videoId != null) {
        _controller.close();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _extractVideoId(widget.demo.videoUrl);
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: videoId != null 
                  ? YoutubePlayer(controller: _controller)
                  : Container(
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.video_library_outlined, color: Colors.grey),
                            const SizedBox(height: 4),
                            Text(
                              widget.demo.videoUrl, 
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.demo.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  void _handlePurchase(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
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
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        product.type == ProductType.camera
                            ? Icons.camera_alt
                            : (product.type == ProductType.xRay ? Icons.flash_on : Icons.biotech),
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(CurrencyHelper.format(product.price), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _handlePurchase(context),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        foregroundColor: const Color(0xFFD32F2F),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
