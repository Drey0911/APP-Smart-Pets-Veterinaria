import 'package:flutter/material.dart'; // Importa la librería Flutter
import 'login.dart'; // theme_model.dart - No changes needed to your model itself
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme_model.dart';

void main() async {
  // Inicializa Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicia la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp in an AuthWrapper that provides ThemeModel when user is authenticated
    return const AuthWrapper();
  }
}

// Widget que maneja la autenticación y proporciona ThemeModel cuando hay un usuario
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Usuario autenticado
        if (snapshot.hasData && snapshot.data != null) {
          final String userId = snapshot.data!.uid;

          // Proporcionar ThemeModel con el userId
          return ChangeNotifierProvider(
            create: (_) => ThemeModel(userId),
            child: const AppWithTheme(),
          );
        }

        // Usuario no autenticado - tema por defecto
        return MaterialApp(
          title: 'Navegación Flutter',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(255, 17, 46, 88),
            appBarTheme: const AppBarTheme(
              color: Color.fromARGB(255, 17, 46, 88),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          home: const Login(),
        );
      },
    );
  }
}

// Widget que consume ThemeModel y construye MaterialApp con el tema adecuado
class AppWithTheme extends StatelessWidget {
  const AppWithTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return MaterialApp(
          title: 'Navegación Flutter',
          debugShowCheckedModeBanner: false,
          theme: themeModel.currentTheme, // Usar el tema definido en ThemeModel
          home: const Login(),
        );
      },
    );
  }
}

/*
class MiPantalla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Para acceder al tema o cambiar entre claro/oscuro:
    final themeModel = Provider.of<ThemeModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Pantalla'),
        actions: [
          // Botón para cambiar el tema
          IconButton(
            icon: Icon(themeModel.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeModel.toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Contenido de mi pantalla',
          style: TextStyle(
            // Usar colores del tema actual
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
*/
