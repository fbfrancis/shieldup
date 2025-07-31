import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedChatsScreen extends StatelessWidget {
  const SavedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Chats', style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with actual saved chats
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.chat_bubble),
            title: Text('Chat ${index + 1}', style: GoogleFonts.poppins()),
            subtitle: Text(
              'Last message preview...',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                /* Delete logic */
              },
            ),
            onTap: () {
              /* Open chat logic */
            },
          );
        },
      ),
    );
  }
}
