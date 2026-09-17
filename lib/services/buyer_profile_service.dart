import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String location,
    required String organization,
    required String interest,
    required String bio,
  }) async {
    await _firestore.collection('buyer_profiles').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'organization': organization,
      'interest': interest,
      'bio': bio,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(String uid) async {
    return await _firestore.collection('buyer_profiles').doc(uid).get();
  }

  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('buyer_profiles').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
