import 'package:cloud_firestore/cloud_firestore.dart';

class RequirementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE
  Future<void> createRequirement({
    required String buyerId,
    required String title,
    required String description,
    required String category,
    required String craftType,
    required int quantity,
    required double budgetMin,
    required double budgetMax,
    required String location,
  }) async {
    await _firestore.collection('requirements').add({
      'buyerId': buyerId,
      'title': title,
      'description': description,
      'category': category,
      'craftType': craftType,
      'quantity': quantity,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // READ - Buyer's requirements
  Future<QuerySnapshot<Map<String, dynamic>>> getBuyerRequirements(
    String buyerId,
  ) async {
    return await _firestore
        .collection('requirements')
        .where('buyerId', isEqualTo: buyerId)
        .get();
  }

  // READ - All requirements
  Future<QuerySnapshot<Map<String, dynamic>>> getAllRequirements() async {
    return await _firestore
        .collection('requirements')
        .orderBy('createdAt', descending: true)
        .get();
  }

  // UPDATE
  Future<void> updateRequirement({
    required String requirementId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('requirements').doc(requirementId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE
  Future<void> deleteRequirement(String requirementId) async {
    await _firestore.collection('requirements').doc(requirementId).delete();
  }
}
