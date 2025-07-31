import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ReportConcernScreen extends StatefulWidget {
  const ReportConcernScreen({super.key});

  @override
  State<ReportConcernScreen> createState() => _ReportConcernScreenState();
}

class _ReportConcernScreenState extends State<ReportConcernScreen> {
  final _formKey = GlobalKey<FormState>();
  final _concernController = TextEditingController();
  final List<File> _images = [];
  bool _isLoading = false;

  InputDecoration _inputDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? Colors.black : Colors.white,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only upload up to 3 images.")),
      );
      return;
    }

    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _images.add(File(picked.path)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gallery permission denied.")),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      return;
    }

    setState(() => _isLoading = true);

    List<String> imageUrls = [];

    try {
      for (final file in _images) {
        if (!file.existsSync()) {
          throw Exception("File does not exist: ${file.path}");
        }

        final fileId = const Uuid().v4();
        final ref = FirebaseStorage.instance.ref().child(
          'concerns/${user.uid}/$fileId.jpg',
        );

        final downloadURL = await ref.getDownloadURL();
        imageUrls.add(downloadURL);
      }

      await FirebaseFirestore.instance.collection('concerns').add({
        'userEmail': user.email,
        'userId': user.uid,
        'message': _concernController.text.trim(),
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
      });

      _concernController.clear();
      setState(() {
        _images.clear();
        _isLoading = false;
      });

      _showSuccessDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to submit: $e")));
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 5), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isDark ? Colors.black : Colors.white,
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/message_sent.json',
                  width: 120,
                  height: 120,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                Text(
                  'Concern Submitted',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your concern has been submitted successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will close in 5 seconds...',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report A Concern"),
        backgroundColor: Colors.teal.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _concernController,
                maxLines: 5,
                maxLength: 600,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputDecoration('Describe your concern'),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter your concern';
                  if (val.length < 10) return 'Enter at least 10 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_images.length} of 3 images selected",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                    ),
                    child: const Text(
                      "Add Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_images.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _images.removeAt(index));
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
