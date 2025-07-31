import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialAbout;
  final String? imagePath;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialAbout,
    this.imagePath,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _aboutController = TextEditingController(text: widget.initialAbout);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.teal.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(_imageFile!)
                          : widget.imagePath != null
                          ? FileImage(File(widget.imagePath!))
                          : null,
                  child:
                      (_imageFile == null && widget.imagePath == null)
                          ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.teal,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text("Name", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "About",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _aboutController,
            maxLines: 2,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.teal.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final updatedName = _nameController.text.trim();
              final updatedAbout = _aboutController.text.trim();

              Navigator.pop(context, {
                'name': updatedName,
                'about': updatedAbout,
                'image': _imageFile?.path,
              });
            },
            child: Text(
              "Save Changes",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
