import 'package:flutter/material.dart';

class VirutaCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const VirutaCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontSize: 20)),
        subtitle: Text(value, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
