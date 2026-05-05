import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import 'add_product_screen.dart';
import 'manage_inventory_screen.dart';
import 'orders_screen.dart';
import 'payment_settings_screen.dart';
import 'product_summary_screen.dart';
import 'product_guide_admin_screen.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Handy Admin Panel'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Management Console',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _AdminActionTile(
              icon: Icons.cloud_upload_outlined,
              title: 'Sync Local Products to Cloud',
              onTap: () async {
                try {
                  await firestoreService.syncProducts(mockProducts);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Products synced to cloud successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sync failed: $e')),
                    );
                  }
                }
              },
            ),
            _AdminActionTile(
              icon: Icons.add_shopping_cart,
              title: 'Add New Product',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
              },
            ),
            _AdminActionTile(
              icon: Icons.inventory_2_outlined,
              title: 'Manage Inventory',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageInventoryScreen()),
                );
              },
            ),
            _AdminActionTile(
              icon: Icons.table_chart_outlined,
              title: 'Product Summary Table',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductSummaryScreen()),
                );
              },
            ),
            _AdminActionTile(
              icon: Icons.help_outline,
              title: 'Manage Product Guide',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductGuideAdminScreen()),
                );
              },
            ),
            _AdminActionTile(
              icon: Icons.list_alt,
              title: 'View Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
            ),
            _AdminActionTile(
              icon: Icons.payments_outlined,
              title: 'Payment Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentSettingsScreen()),
                );
              },
            ),
            _AdminActionTile(
              icon: Icons.analytics_outlined,
              title: 'Sales Analytics',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminActionTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD32F2F)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
