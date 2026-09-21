import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CREATE ORDER
  Future<String> createOrder({
    required String productId,
    required String productName,
    required String artisanId,
    required double price,
    required int quantity,
    String? productImage,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to place an order.');
    }

    if (quantity <= 0) {
      throw Exception('Quantity must be at least 1.');
    }

    final totalAmount = price * quantity;

    final orderRef = await _firestore.collection('orders').add({
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'buyerId': user.uid,
      'artisanId': artisanId,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return orderRef.id;
  }

  // GET ORDERS FOR CURRENT BUYER
  Stream<QuerySnapshot<Map<String, dynamic>>> getBuyerOrders() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .snapshots();
  }

  // GET ORDERS FOR CURRENT ARTISAN
  Stream<QuerySnapshot<Map<String, dynamic>>> getArtisanOrders() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    return _firestore
        .collection('orders')
        .where('artisanId', isEqualTo: user.uid)
        .snapshots();
  }

  // UPDATE ORDER STATUS
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
