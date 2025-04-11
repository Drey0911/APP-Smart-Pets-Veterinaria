import 'package:flutter/material.dart'; // Importa la librería Flutter
import 'login.dart';
//import 'inicio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // PARA PRUEBAS DE INICIO.DART

  /*   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navegación Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: inicio(),
    );
  } */

  // ORIGINAL INDEX
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navegación Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: login(), // Cambia a la pantalla de inicio de sesión
    );
  }
}
