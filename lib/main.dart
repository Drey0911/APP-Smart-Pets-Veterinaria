import 'package:flutter/material.dart'; // Importa la librería Flutter
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Inicializa Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicia la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ORIGINAL INDEX
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navegación Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Login(), // Cambia a la pantalla de inicio de sesión
    );
  }
}
