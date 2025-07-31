import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewReportsScreen extends StatefulWidget {
  static const routeName = '/view-reports';

  const ViewReportsScreen({super.key});

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  String searchQuery = '';

  Future<void> _deleteReport(String docId) async {
    await FirebaseFirestore.instance.collection('concerns').doc(docId).delete();
  }

  void _editReportDialog(BuildContext context, DocumentSnapshot report) {
    final TextEditingController messageController = TextEditingController(
      text: report['message'],
    );

    showDialog(
      context: context,
      builder: (_) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text("Edit Report", style: theme.textTheme.titleLarge),
          content: TextField(
            controller: messageController,
            maxLines: 3,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('concerns')
                    .doc(report.id)
                    .update({'message': messageController.text.trim()});
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged:
                  (value) =>
                      setState(() => searchQuery = value.trim().toLowerCase()),
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.white,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade600),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('concerns')
                      .where('userEmail', isEqualTo: user?.email)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reports =
                    snapshot.data!.docs.where((doc) {
                      final message =
                          doc['message']?.toString().toLowerCase() ?? '';
                      return message.contains(searchQuery);
                    }).toList();

                if (reports.isEmpty) {
                  return const Center(child: Text('No reports found.'));
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final timestamp = report['timestamp'] as Timestamp?;
                    final formattedTime =
                        timestamp != null
                            ? DateFormat.yMMMd().add_jm().format(
                              timestamp.toDate(),
                            )
                            : 'Unknown time';

                    return Card(
                      color: theme.cardColor,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          report['message'] ?? '',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          formattedTime,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed:
                                  () => _editReportDialog(context, report),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text("Delete Report"),
                                        content: const Text(
                                          "Are you sure you want to delete this report?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  await _deleteReport(report.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
