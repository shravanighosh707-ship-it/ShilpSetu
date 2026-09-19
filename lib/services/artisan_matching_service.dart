import 'package:cloud_firestore/cloud_firestore.dart';

class ArtisanMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates or updates the public matching information
  /// for an artisan.
  ///
  /// Only non-sensitive information required by the
  /// matching engine should be stored here.
  Future<void> createOrUpdateMatchingProfile({
    required String artisanId,
    required String location,
  }) async {
    await _firestore.collection('artisan_matching').doc(artisanId).set({
      'artisanId': artisanId,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Gets matching information for a single artisan.
  Future<DocumentSnapshot<Map<String, dynamic>>> getMatchingProfile(
    String artisanId,
  ) async {
    return await _firestore.collection('artisan_matching').doc(artisanId).get();
  }

  /// Gets matching information for multiple artisans.
  Future<Map<String, String>> getArtisanLocations(
    Set<String> artisanIds,
  ) async {
    final Map<String, String> artisanLocations = {};

    for (final artisanId in artisanIds) {
      final snapshot = await getMatchingProfile(artisanId);

      if (!snapshot.exists) {
        continue;
      }

      final data = snapshot.data();

      if (data == null) {
        continue;
      }

      artisanLocations[artisanId] = (data['location'] ?? '').toString();
    }

    return artisanLocations;
  }
}
