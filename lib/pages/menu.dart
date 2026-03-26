import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'El menu lateral de HomePage es ahora la navegacion principal.',
        ),
      ),
    );
  }
}
