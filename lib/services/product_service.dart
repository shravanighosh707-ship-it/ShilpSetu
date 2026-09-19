import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE PRODUCT
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

  // READ - Get products of a specific artisan
  Future<QuerySnapshot<Map<String, dynamic>>> getArtisanProducts(
    String artisanId,
  ) async {
    return await _firestore
        .collection('products')
        .where('artisanId', isEqualTo: artisanId)
        .get();
  }

  // READ - Get all products
  Future<QuerySnapshot<Map<String, dynamic>>> getAllProducts() async {
    return await _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();
  }

  // SEARCH & FILTER PRODUCTS
  Future<QuerySnapshot<Map<String, dynamic>>> searchProducts({
    String? category,
    String? craftType,
    double? minPrice,
    double? maxPrice,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('products');

    // Filter by category
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    // Filter by craft type
    if (craftType != null && craftType.isNotEmpty) {
      query = query.where('craftType', isEqualTo: craftType);
    }

    // Filter by minimum price
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    // Filter by maximum price
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    return await query.get();
  }

  // UPDATE PRODUCT
  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('products').doc(productId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE PRODUCT
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}
