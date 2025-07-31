import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AllStreaksScreen extends StatelessWidget {
  static const routeName = '/full-progress';

  const AllStreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Full Progress')),
      body:
          userId == null
              ? const Center(child: Text('User not logged in.'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('learning_progress')
                        .where('userId', isEqualTo: userId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No progress found.'));
                  }

                  final progressDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: progressDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          progressDocs[index].data() as Map<String, dynamic>;

                      final title = data['title'] ?? 'No Title';
                      final description = data['description'] ?? '';
                      final timestamp =
                          (data['timestamp'] as Timestamp?)?.toDate();
                      final formattedDate =
                          timestamp != null
                              ? DateFormat('dd/MM/yyyy').format(timestamp)
                              : 'Unknown date';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(description),
                          trailing: Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
