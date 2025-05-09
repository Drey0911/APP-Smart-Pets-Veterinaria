import 'package:flutter/material.dart'; // Librería base de Flutter
import 'package:firebase_database/firebase_database.dart';
import '../login.dart'; // Pantalla de login
import 'perfil_editar.dart';
import 'perfil_opciones.dart';
import 'perfil_acerca_de_nos.dart';
import 'perfil_contactanos.dart';

class Perfil extends StatefulWidget {
  final String uid; // Recibe solo el UID

  final Function(String, String, String)
  onProfileUpdated; // Función para actualizar datos

  const Perfil({Key? key, required this.uid, required this.onProfileUpdated})
    : super(key: key);

  @override
  _PerfilState createState() => _PerfilState(); // Crea el estado del widget
}

class _PerfilState extends State<Perfil> {
  late String nombreUsuario = 'Cargando...';
  late String emailUsuario = 'Cargando...';
  late String password = '*******';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref(
        'usuarios/${widget.uid}',
      );
      final DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          nombreUsuario = userData['nombre'] ?? 'Usuario';
          emailUsuario = userData['email'] ?? 'Sin correo';
          password = '*******';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error al cargar los datos del usuario: $e");
      setState(() {
        nombreUsuario = 'Error al cargar';
        emailUsuario = 'Error al cargar';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Mi Perfil",
          style: TextStyle(
            color: const Color.fromARGB(255, 17, 46, 88),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: const Color.fromARGB(255, 17, 46, 88),
                      child: Icon(Icons.person, size: 120, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nombreUsuario,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      emailUsuario,
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(
                          255,
                          17,
                          46,
                          88,
                        ).withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Navegar a la pantalla de edición de perfil
                        final updatedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditarPerfil(
                                  userName: nombreUsuario,
                                  email: emailUsuario,
                                  password: password,
                                ),
                          ),
                        );

                        // Si los datos se actualizaron, recarga el perfil
                        if (updatedData != null) {
                          setState(() {
                            nombreUsuario = updatedData['name'];
                            emailUsuario = updatedData['email'];
                            password = updatedData['password'];
                          });

                          // Llama al callback para actualizar los datos en `MyHomePage`
                          widget.onProfileUpdated(
                            nombreUsuario,
                            emailUsuario,
                            password,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 17, 46, 88),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        minimumSize: const Size(150, 50),
                      ),
                      child: const Text(
                        "Editar Perfil",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          'Configuración:',
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(170, 217, 238, 1),
                            Color.fromRGBO(140, 189, 210, 1),
                            Color.fromRGBO(30, 75, 105, 1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(50),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 30,
                        childAspectRatio: 1.3,
                        children: [
                          _buildConfigButton(
                            context,
                            Icons.settings,
                            "Opciones",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PerfilOpciones(
                                        userName: nombreUsuario,
                                      ),
                                ),
                              );
                            },
                          ),
                          _buildConfigButton(
                            context,
                            Icons.info,
                            "Acerca de nosotros",
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcercaDeNosotros(),
                              ),
                            ),
                          ),
                          _buildConfigButton(
                            context,
                            Icons.phone,
                            "Contáctanos",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Contactanos(),
                                ),
                              );
                            },
                          ),
                          _buildConfigButton(
                            context,
                            Icons.logout,
                            "Cerrar Sesión",
                            () => _mostrarDialogoConfirmacion(context),
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
        backgroundColor: const Color.fromARGB(255, 160, 194, 214),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
        shadowColor: Colors.black54,
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 17, 46, 88), size: 60),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.fromARGB(255, 17, 46, 88),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
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
                MaterialPageRoute(builder: (context) => Login()),
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
