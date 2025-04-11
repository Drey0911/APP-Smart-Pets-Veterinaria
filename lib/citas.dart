import 'package:flutter/material.dart';

class Citas extends StatelessWidget {
  const Citas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Citas')),
      body: Center(
        child: Text('Página de Citas', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
