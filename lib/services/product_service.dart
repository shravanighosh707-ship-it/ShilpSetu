import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct({
    required String artisanId,
    required String name,
    required String description,
    required String category,
    required String craftType,
    required double price,
  }) async {
    await _firestore.collection('products').add({
      'artisanId': artisanId,
      'name': name,
      'description': description,
      'category': category,
      'craftType': craftType,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getArtisanProducts(
    String artisanId,
  ) async {
    return await _firestore
        .collection('products')
        .where('artisanId', isEqualTo: artisanId)
        .get();
  }

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('products').doc(productId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}
