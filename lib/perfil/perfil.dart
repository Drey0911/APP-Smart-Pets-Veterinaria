import 'package:flutter/material.dart'; // Librería base de Flutter
import 'package:proyecto/perfil/perfil_editar.dart';
import 'package:proyecto/perfil/perfil_opciones.dart';
import '../login.dart'; // Pantalla de login
import 'package:proyecto/perfil/perfil_acerca_de_nos.dart';
import 'package:proyecto/perfil/perfil_contactanos.dart';

class Perfil extends StatefulWidget {
  final String userName; // Nombre del usuario
  final String email; // Correo del usuario
  final String password; // Contraseña del usuario

  final Function(String, String, String)
  onProfileUpdated; // Función para actualizar datos

  const Perfil({
    Key? key,
    required this.userName,
    required this.email,
    required this.password,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState(); // Crea el estado del widget
}

class _PerfilState extends State<Perfil> {
  late String userName; // Variable local para el nombre
  late String email; // Variable local para el correo
  late String password; // Variable local para la contraseña

  @override
  void initState() {
    super.initState();
    userName = widget.userName; // Inicializa nombre desde el widget
    email = widget.email; // Inicializa email desde el widget
    password = widget.password; // Inicializa contraseña desde el widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fondo transparente
        shadowColor: Colors.transparent, // Sin sombra
        elevation: 0, // Sin elevación
        title: Text(
          "Mi Perfil", // Título del AppBar
          style: TextStyle(
            color: const Color.fromARGB(255, 17, 46, 88), // Color azul oscuro
            fontSize: 25,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Color.fromRGBO(140, 189, 210, 1), // Sombra celeste
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        centerTitle: true, // Centrar título
      ),
      body: SingleChildScrollView(
        // Para permitir scroll si hay mucho contenido
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40), // Espacio superior
            CircleAvatar(
              // Avatar circular
              radius: 70,
              backgroundColor: const Color.fromARGB(255, 17, 46, 88),
              child: Icon(Icons.person, size: 120, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              widget.userName, // Muestra el nombre del usuario
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              widget.email, // Muestra el correo
              style: TextStyle(
                fontSize: 18,
                color: const Color.fromARGB(255, 17, 46, 88).withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // CAMBIOS EN EL METODO DE NAVEGACION CON PUSH PARA EL ENVIO DE LOS DATOS DE NAME, EMAIL Y PASSWORD PARA QUE LOS RECIBA
                //LA FUNCION UDAPTE EN inicio.dart
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditarPerfil(
                          userName: widget.userName,
                          email: widget.email,
                          password: widget.password,
                        ),
                  ),
                ).then((updatedData) {
                  if (updatedData != null) {
                    // Llama a la función de actualización que recibiste desde inicio.dart
                    widget.onProfileUpdated(
                      updatedData['name'],
                      updatedData['email'],
                      updatedData['password'],
                    );
                  }
                });

                if (updatedData != null) {
                  setState(() {
                    userName = updatedData['name']; // Actualiza nombre
                    email = updatedData['email']; // Actualiza email
                    password = updatedData['password']; // Actualiza contraseña
                  });
                  widget.onProfileUpdated(
                    userName,
                    email,
                    password,
                  ); // Llama al callback
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 17, 46, 88),
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
                minimumSize: Size(150, 50),
              ),
              child: Text(
                "Editar Perfil", // Texto del botón
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                child: Text(
                  'Configuración:', // Título de sección
                  style: TextStyle(
                    color: const Color.fromARGB(255, 17, 46, 88),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Degradado del fondo
                  colors: [
                    Color.fromRGBO(170, 217, 238, 1),
                    Color.fromRGBO(140, 189, 210, 1),
                    Color.fromRGBO(30, 75, 105, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2, // 2 columnas
                crossAxisSpacing: 20,
                mainAxisSpacing: 30,
                childAspectRatio: 1.3,
                children: [
                  _buildConfigButton(context, Icons.settings, "Opciones", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                PerfilOpciones(userName: widget.userName),
                      ),
                    );
                  }),
                  _buildConfigButton(
                    context,
                    Icons.info,
                    "Acerca de nosotros",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcercaDeNosotros(),
                        ),
                      );
                    },
                  ),
                  _buildConfigButton(context, Icons.phone, "Contáctanos", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Contactanos()),
                    );
                  }),
                  _buildConfigButton(
                    context,
                    Icons.logout,
                    "Cerrar Sesión",
                    () {
                      _mostrarDialogoConfirmacion(
                        context,
                      ); // Confirma cierre de sesión
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir botones del menú
  Widget _buildConfigButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 160, 194, 214),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
        shadowColor: Colors.black54,
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 17, 46, 88),
            size: 60,
          ), // Icono
          SizedBox(height: 8),
          Center(
            child: Text(
              label, // Texto del botón
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color.fromARGB(255, 17, 46, 88),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Diálogo para confirmar cierre de sesión
  void _mostrarDialogoConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmación',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 17, 46, 88),
            ),
          ),
          content: Text(
            '¿Está seguro de que desea cerrar sesión?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => login()),
                  (route) => false,
                );
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: const Color.fromARGB(255, 17, 46, 88),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
