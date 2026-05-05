import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/app_config.dart';
import '../models/workflow_demo.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Config Operations ---

  Future<AppConfig> getAppConfig() async {
    final doc = await _db.collection('settings').doc('app_config').get();
    if (!doc.exists) {
      return AppConfig(razorpayKey: 'rzp_test_Sjh2VmcaT2ndLx');
    }
    return AppConfig.fromFirestore(doc.data()!);
  }

  Future<void> updateAppConfig(AppConfig config) async {
    await _db.collection('settings').doc('app_config').set(config.toMap());
  }

  // --- Workflow Demo Operations ---

  Future<void> addWorkflowDemo(String title, String videoUrl) async {
    await _db.collection('workflow_demos').add({
      'title': title,
      'videoUrl': videoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<WorkflowDemo>> getWorkflowDemos() {
    return _db.collection('workflow_demos').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkflowDemo.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> deleteWorkflowDemo(String id) async {
    await _db.collection('workflow_demos').doc(id).delete();
  }

  // --- Product Operations ---

  // Add Product
  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  // Sync Local Products to Firestore
  Future<void> syncProducts(List<Product> products) async {
    final batch = _db.batch();
    for (var product in products) {
      final docRef = _db.collection('products').doc(product.id);
      batch.set(docRef, product.toMap());
    }
    await batch.commit();
  }

  // Update Product
  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  // Delete Product
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // Get Products Stream
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      print("Firestore Debug: Found ${snapshot.docs.length} products");
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  // --- Order Operations ---

  // Create Order
  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').add(order.toMap());
  }

  // Get Orders Stream (All for Admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _db.collection('orders').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  // Get User Orders Stream
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db.collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }
}
