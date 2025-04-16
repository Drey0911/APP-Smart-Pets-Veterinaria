import 'package:flutter/material.dart'; // Importa la librería Flutter
import 'inicio.dart';

class login extends StatelessWidget {
  const login({super.key});
  // Define una clase llamada MyApp que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) {
    // Define el método build para construir la interfaz de la aplicación.
    return MaterialApp(
      title: 'SmartPets', // Título de la aplicación.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1E4B69),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1E4B69),
          primary: Color(0xFF1E4B69),
        ),
      ),
      initialRoute: '/', // Ruta inicial de la aplicación.
      routes: {
        '/':
            (context) =>
                AuthScreen(), // Define una ruta llamada '/' que muestra AuthScreen.
        '/register':
            (context) =>
                RegisterScreen(), // Define una ruta llamada '/register' que muestra RegisterScreen.
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  // Define una clase llamada AuthScreen que extiende StatefulWidget.
  @override
  _AuthScreenState createState() => _AuthScreenState(); // Crea el estado para AuthScreen.
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isRegistered = false;
  bool isLoggedIn = false;
  String? registeredEmail;
  String? registeredPassword;
  String? registeredName; // Nombre del registro

  void register() async {
    final result = await Navigator.pushNamed(context, '/register');
    if (result != null && result is Map<String, String>) {
      setState(() {
        isRegistered = true;
        registeredEmail = result['email'];
        registeredPassword = result['password'];
        registeredName = result['name']; // Capturar el nombre del usuario
      });

      // Agregar la alerta de registro exitoso aquí
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registro Exitoso'),
            content: Text(
              'Tu cuenta ha sido creada correctamente. Ahora puedes iniciar sesión.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  void login() {
    // Lógica de login
    if (isRegistered) {
      final enteredEmail = emailController.text;
      final enteredPassword = passwordController.text;

      if (enteredEmail == registeredEmail &&
          enteredPassword == registeredPassword) {
        setState(() {
          isLoggedIn = true;
        });

        // Navegar a inicio.dart pasando el nombre de usuario como argumento // SOLUCION DEL ERROR DE INICIO POSIBLEMENTE CAMBIO V7
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InicioApp(),
            settings: RouteSettings(
              arguments: {
                'nombreusu': registeredName ?? 'Usuario',
                'email': registeredEmail ?? '',
                'password': registeredPassword ?? '',
              },
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de inicio de sesión'),
              content: Text(
                'Credenciales incorrectas. Verifica tu correo y contraseña.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de inicio de sesión'),
            content: Text('Debes registrarte antes de iniciar sesión.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return Container(); // Return an empty widget while navigating
    } else {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(150, 193, 212, 1),
                Color.fromRGBO(150, 193, 212, 1),
                Color.fromRGBO(30, 75, 105, 1),
                Color.fromRGBO(30, 75, 105, 1),
              ],
            ),
          ),
          child: SingleChildScrollView(
            // APLICACION SCROLL= Se utiliza SingleChildScrollView para permitir el desplazamiento vertical en caso de que el contenido exceda el tamaño de la pantalla.
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo
                  SizedBox(height: 30), //espaciado antes del logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Image.asset(
                      'images/logo.png',
                      width: 350,
                      height: 350,
                    ),
                  ),

                  // Email field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 5,
                    ),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        labelText:
                            'E-mail', // Esto es para que el placeholder se convierta en el label
                        labelStyle: TextStyle(color: Colors.white),
                        floatingLabelBehavior:
                            FloatingLabelBehavior
                                .auto, // Placeholder sube automáticamente
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ), // al hacer la animacion cambia el color
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bordes ovalados
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bordes ovalados
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  // Password field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        labelText:
                            'Contraseña', // Esto es para que el placeholder se convierta en el label
                        labelStyle: TextStyle(color: Colors.white),
                        floatingLabelBehavior:
                            FloatingLabelBehavior
                                .auto, // Placeholder sube automáticamente
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ), // al hacer la animacion cambia el color
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bordes ovalados
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bordes ovalados
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  // Login button
                  // Recuadro blanco que contiene los botones (arreglar
                  Container(
                    margin: EdgeInsets.only(top: 60),
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de iniciar sesión
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 7, 81, 124),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            'ó',
                            style: TextStyle(color: Color(0xFF0B3954)),
                          ),
                        ),

                        // Register button
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TextButton(
                            onPressed: register,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFFA1C6D7),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'Crear una cuenta',
                                  style: TextStyle(
                                    color: Color(0xFF0B3954),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20), //espaciado despues del container
                ],
              ),
            ),
          ), // Cierre del SingleChildScrollView //APLICACION SCROLL= Aquí se cierra el widget que permite el desplazamiento vertical.
        ),
      );
    }
  }
}

// PANTALLA PARA REGISTRO

// ************************************************************************************** ///
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController registerEmailController = TextEditingController();
    TextEditingController registerPasswordController = TextEditingController();
    TextEditingController registerNameController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(
                255,
                255,
                255,
                255,
              ), // Light blue color from the image
              Color.fromRGBO(
                255,
                255,
                255,
                1,
              ), // Dark blue color for the bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // APLICACION SCROLL REGISTRO= Se utiliza SingleChildScrollView para permitir el desplazamiento vertical en caso de que el contenido exceda el tamaño de la pantalla.
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20),

                  // Header section
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromRGBO(150, 193, 212, 1),
                                    Color.fromRGBO(30, 75, 105, 1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0),
                                  width: 20,
                                ),
                              ),
                              child: Text(
                                '¿Eres Nuevo? Vamos a crear una cuenta para ti',
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1),
                      ],
                    ),
                  ),

                  SizedBox(height: 50), //SEPARACION ENTRE HEADER Y LOS INPUT
                  //name field
                  TextFormField(
                    controller: registerNameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      labelText:
                          'Nombre', // Esto es para que el placeholder se convierta en el label
                      labelStyle: TextStyle(color: Colors.black),
                      floatingLabelBehavior:
                          FloatingLabelBehavior
                              .auto, // Placeholder sube automáticamente
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ), // al hacer la animacion cambia el color
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Bordes ovalados
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Bordes ovalados
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),

                  SizedBox(height: 16),

                  // E-mail field
                  TextFormField(
                    controller: registerEmailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      labelText:
                          'E-mail', // Esto es para que el placeholder se convierta en el label
                      labelStyle: TextStyle(color: Colors.black),
                      floatingLabelBehavior:
                          FloatingLabelBehavior
                              .auto, // Placeholder sube automáticamente
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ), // al hacer la animacion cambia el color
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Bordes ovalados
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Bordes ovalados
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),

                  SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: registerPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      labelText:
                          'Contraseña', // Esto es para que el placeholder se convierta en el label
                      labelStyle: TextStyle(color: Colors.black),
                      floatingLabelBehavior:
                          FloatingLabelBehavior
                              .auto, // Placeholder sube automáticamente
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ), // al hacer la animacion cambia el color
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Bordes ovalados
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Bordes ovalados
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),

                  SizedBox(height: 40),

                  // Register button
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF0B3954),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        final registerEmail = registerEmailController.text;
                        final registerPassword =
                            registerPasswordController.text;
                        final registerName =
                            registerNameController.text; // Capturar el nombre

                        final result = {
                          'email': registerEmail,
                          'password': registerPassword,
                          'name':
                              registerName, // Agregar el nombre al resultado
                        };

                        Navigator.pop(context, result);
                      },
                      child: Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ), //SEPARACION BOTON CREAR Y EL LINK DE INICIO DE SESION
                  // Login link
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta?',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Inicia Sesión aquí',
                            style: TextStyle(
                              color: const Color.fromARGB(
                                255,
                                3,
                                4,
                                47,
                              ).withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ), // Cierre del SingleChildScrollView //APLICACION SCROLL REGISTRO= Aquí se cierra el widget que permite el desplazamiento vertical.
        ),
      ),
    );
  } //WIDGET BUILD CONTEXT
}
