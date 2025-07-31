import 'package:flutter/material.dart';
import '../models/module_model.dart';

class ModuleCard extends StatelessWidget {
  final Module module;

  const ModuleCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          module.isCompleted
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: module.isCompleted ? Colors.green : Colors.grey,
          size: 30,
        ),
        title: Text(
          module.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(module.description),
        trailing:
            module.isCompleted
                ? const Icon(Icons.done_all, color: Colors.green)
                : null,
      ),
    );
  }
}
