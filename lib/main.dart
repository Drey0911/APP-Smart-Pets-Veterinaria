// Importacion de paquetes y dependencias del archivo
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/admin/inicio_admin.dart';
import 'package:proyecto/inicio.dart';
import 'login.dart';
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
    // retorna el AuthWrapper de autenticator de firebase
    return const AuthWrapper();
  }
}

// Widget de autenticator
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // widget de la pantalla de carga
  Widget _buildAuthLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(30, 75, 105, 1),
              Color.fromRGBO(140, 189, 210, 1),
              Color.fromRGBO(170, 217, 238, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Contenedor con gradiente e icono
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(75),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(170, 217, 238, 1),
                      Color.fromRGBO(140, 189, 210, 1),
                      Color.fromRGBO(30, 75, 105, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('images/icon.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),
              // Indicador de carga
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, color: Colors.white, size: 40),
                  const SizedBox(width: 10),
                  Text(
                    'Entrando a tu cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Mensaje secundario
              Text(
                'Un momento por favor...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Pantalla de carga personalizada mientras se verifica el estado anterior widget
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: _buildAuthLoadingScreen());
        }

        // Usuario autenticado
        if (snapshot.hasData) {
          final userId = snapshot.data!.uid;
          return ChangeNotifierProvider(
            create: (_) => ThemeModel(userId),
            child: const AppWithTheme(),
          );
        }

        // Usuario no autenticado
        return MaterialApp(
          title: 'App',
          theme: ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(255, 17, 46, 88),
          ),
          home: const Login(),
        );
      },
    );
  }
}

// clase para aplicar el tema definido
class AppWithTheme extends StatelessWidget {
  const AppWithTheme({super.key});

  //widget de la pantalla de carga
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 75, 105, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(75),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(170, 217, 238, 1),
                    Color.fromRGBO(140, 189, 210, 1),
                    Color.fromRGBO(30, 75, 105, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 6),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('images/icon.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, color: Colors.white, size: 40),
                const SizedBox(width: 10),
                Text(
                  'Cargando...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Un momento por favor',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return MaterialApp(
      theme: themeModel.currentTheme,
      home: FutureBuilder(
        future: _getHomeScreen(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen(); // Usa pantalla de carga personalizada
          }
          return snapshot.data ?? const Login();
        },
      ),
    );
  }

  // widget asincrono para que verifique luego de iniciar sesion la instancia de firebase y mirar el rol segun a donde retorna
  // guardado de datos cuando se cierra la app
  Future<Widget> _getHomeScreen(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Login();

    final snapshot =
        await FirebaseDatabase.instance.ref('usuarios/${user.uid}').get();
    final rol = snapshot.child('rol').value as String? ?? 'Cliente';

    return rol == 'Administrador'
        ? InicioAdminApp(uid: user.uid)
        : InicioApp(uid: user.uid);
  }
}
