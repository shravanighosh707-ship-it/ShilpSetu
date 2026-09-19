import 'package:cloud_firestore/cloud_firestore.dart';

import 'artisan_matching_service.dart';

class ArtisanProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ArtisanMatchingService _matchingService = ArtisanMatchingService();

  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String location,
    required String craft,
    required String experience,
    required String bio,
  }) async {
    await _firestore.collection('artisan_profiles').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'craft': craft,
      'experience': experience,
      'bio': bio,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _matchingService.createOrUpdateMatchingProfile(
      artisanId: uid,
      location: location,
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(String uid) async {
    return await _firestore.collection('artisan_profiles').doc(uid).get();
  }

  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('artisan_profiles').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (data.containsKey('location')) {
      await _matchingService.createOrUpdateMatchingProfile(
        artisanId: uid,
        location: data['location'].toString(),
      );
    }
  }
}
