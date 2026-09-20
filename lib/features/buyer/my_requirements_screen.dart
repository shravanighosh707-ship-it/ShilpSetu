import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'matching_results_screen.dart';

class MyRequirementsScreen extends StatelessWidget {
  const MyRequirementsScreen({super.key});

  static const Color navy = Color(0xFF051A37);
  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFF5E6C8);
  static const Color cardColor = Color(0xFF0B2547);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: navy,
        body: Center(
          child: Text('Please login again.', style: TextStyle(color: cream)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: cream),
        title: const Text(
          'My Requirements',
          style: TextStyle(color: cream, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('requirements')
            .where('buyerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: gold));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load your requirements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cream.withOpacity(0.7), fontSize: 14),
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: gold,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Requirements Yet',
                      style: TextStyle(
                        color: cream,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Post a requirement to tell artisans what you are looking for.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cream.withOpacity(0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = {
                ...documents[index].data(),
                'id': documents[index].id,
              };

              return _RequirementCard(data: data);
            },
          );
        },
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _RequirementCard({required this.data});

  static const Color navy = Color(0xFF051A37);
  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFF5E6C8);
  static const Color cardColor = Color(0xFF0B2547);

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'Untitled Requirement';
    final description = data['description']?.toString() ?? '';
    final category = data['category']?.toString() ?? '';
    final craftType = data['craftType']?.toString() ?? '';
    final location = data['location']?.toString() ?? '';
    final quantity = data['quantity']?.toString() ?? '0';

    final budgetMin = data['budgetMin'];
    final budgetMax = data['budgetMax'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.assignment_outlined, color: gold),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: cream,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cream.withOpacity(0.68),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.category_outlined, text: category),
              _InfoChip(icon: Icons.handyman_outlined, text: craftType),
              _InfoChip(icon: Icons.numbers, text: 'Qty: $quantity'),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.currency_rupee, color: gold, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_formatNumber(budgetMin)} - ${_formatNumber(budgetMax)}',
                  style: const TextStyle(
                    color: cream,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Icon(Icons.location_on_outlined, color: gold, size: 18),
              const SizedBox(width: 4),

              Flexible(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cream.withOpacity(0.7), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                final requirementId = data['id']?.toString();

                if (requirementId == null || requirementId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Requirement ID not found.')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MatchingResultsScreen(requirementId: requirementId),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text(
                'Find Matches',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';

    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }

      return value.toStringAsFixed(2);
    }

    return value.toString();
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFF5E6C8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: cream.withOpacity(0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
