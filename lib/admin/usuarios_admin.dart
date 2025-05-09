import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UsuariosAdmin extends StatefulWidget {
  const UsuariosAdmin({super.key});

  @override
  _UsuariosAdminState createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  final List<Map<String, dynamic>> _usuarios = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'usuarios',
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    try {
      DatabaseEvent event = await _dbRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> usuarios =
            snapshot.value as Map<dynamic, dynamic>;
        _usuarios.clear();

        usuarios.forEach((key, value) {
          if (value['rol'] == 'Cliente') {
            _usuarios.add({
              'uid': key,
              'nombre': value['nombre'] ?? 'Sin nombre',
              'email': value['email'] ?? 'Sin email',
              'fechaRegistro': value['fechaRegistro'] ?? 'Desconocida',
            });
          }
        });

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarErrorDialog('Error al cargar usuarios: $e');
    }
  }

  void _mostrarErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 17, 46, 88),
              ),
            ),
            content: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // ELIMINAR USUARIO
  /*   void _eliminarUsuario(int index) async {
    final userId = _usuarios[index]['uid'];
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Eliminar Usuario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 17, 46, 88),
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar a ${_usuarios[index]['nombre']}?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: const Color.fromARGB(255, 17, 46, 88)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // Primero reautenticar al usuario
                  final credential = EmailAuthProvider.credential(
                    email: user?.email ?? '',
                    password: await _solicitarContrasena(context),
                  );

                  await user?.reauthenticateWithCredential(credential);

                  // Luego eliminar el usuario
                  await user?.delete();

                  // Eliminar de la base de datos
                  await _dbRef.child(userId).remove();

                  // Actualizar lista local
                  if (mounted) {
                    setState(() {
                      _usuarios.removeAt(index);
                    });
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Usuario eliminado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _mostrarErrorDialog('Error al eliminar usuario: $e');
                  }
                }
              },
              child: Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  } */

  /*   Future<String> _solicitarContrasena(BuildContext context) async {
    final passwordController = TextEditingController();
    String? password;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar contraseña'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Ingresa tu contraseña actual',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  password = passwordController.text;
                  Navigator.pop(context);
                },
                child: Text('Confirmar'),
              ),
            ],
          ),
    );

    return password ?? '';
  } */

  void _agregarUsuario() async {
    final nuevoUsuario = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormularioUsuario()),
    );

    if (nuevoUsuario != null) {
      _cargarUsuarios(); // Recargar la lista después de agregar
    }
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono personalizado con efecto de sombra
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
              child: Image.asset(
                'images/icon.png', // Usa tu imagen personalizada
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Indicador de carga
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4,
          ),
          const SizedBox(height: 20),
          // Texto de carga
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets, // Icono de mascota
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 10), // Espaciado entre el icono y el texto
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
          // Mensaje de bienvenida
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(30, 75, 105, 1),
              Color.fromRGBO(150, 193, 212, 1),
              Color.fromRGBO(150, 193, 212, 1),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: 80,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Usuarios',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _agregarUsuario,
                    icon: Icon(
                      Icons.add,
                      color: Color.fromRGBO(30, 75, 105, 1),
                    ),
                    label: Text(
                      'Agregar',
                      style: TextStyle(color: Color.fromRGBO(30, 75, 105, 1)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de usuarios
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child:
                    _isLoading
                        ? _buildLoadingScreen()
                        : _usuarios.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people,
                                size: 80,
                                color: Color(0xFF1E4B69).withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hay usuarios registrados',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1E4B69).withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _usuarios.length,
                          itemBuilder: (context, index) {
                            final usuario = _usuarios[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(
                                    0xFF1E4B69,
                                  ).withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Color(0xFF1E4B69),
                                  ),
                                ),
                                title: Text(
                                  usuario['nombre'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E4B69),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      'Email: ${usuario['email']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                //ELIMINAR AUN EN PRUEBA
                                /*trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _eliminarUsuario(index),
                                ),*/
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormularioUsuario extends StatefulWidget {
  const FormularioUsuario({super.key});

  @override
  _FormularioUsuarioState createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<FormularioUsuario> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _registrarUsuario() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _mostrarErrorDialog('Por favor, completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
          .timeout(const Duration(seconds: 30));

      await userCredential.user?.updateDisplayName(_nameController.text);

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        final databaseRef = FirebaseDatabase.instance.ref();

        final userData = {
          'nombre': _nameController.text,
          'email': _emailController.text.trim(),
          'uid': userId,
          'fechaRegistro': ServerValue.timestamp,
          'rol': 'Cliente',
        };

        await databaseRef.child('usuarios/$userId').set(userData);
      }

      if (mounted) {
        Navigator.pop(context, true); // Retornar true para indicar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario creado correctamente'),
            backgroundColor: Color(0xFF1E4B69),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al registrar el usuario';
      if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Ya existe una cuenta con este correo electrónico';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El formato del correo electrónico no es válido';
      }
      _mostrarErrorDialog(errorMessage);
    } catch (e) {
      _mostrarErrorDialog('Error inesperado. Por favor, inténtalo de nuevo');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 17, 46, 88),
              ),
            ),
            content: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono personalizado con efecto de sombra
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
              child: Image.asset(
                'images/icon.png', // Usa tu imagen personalizada
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Indicador de carga
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4,
          ),
          const SizedBox(height: 20),
          // Texto de carga
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets, // Icono de mascota
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 10), // Espaciado entre el icono y el texto
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
          // Mensaje de bienvenida
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(150, 193, 212, 1),
                      Color.fromRGBO(30, 75, 105, 1),
                    ],
                  ),
                ),
                child: _buildLoadingScreen(),
              )
              : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromRGBO(255, 255, 255, 1),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 20),

                          // Header section
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
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
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Creacion de usuarios en modo administrador',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: 16,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 60),

                          // Campo de nombre
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              labelText: 'Nombre',
                              labelStyle: const TextStyle(color: Colors.black),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),

                          const SizedBox(height: 16),

                          // Campo de email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              labelText: 'E-mail',
                              labelStyle: const TextStyle(color: Colors.black),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          // Campo de contraseña con toggle de visibilidad
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _isPasswordVisible =
                                              !_isPasswordVisible,
                                    ),
                              ),
                              labelText: 'Contraseña',
                              labelStyle: const TextStyle(color: Colors.black),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),

                          const SizedBox(height: 50),

                          // Botón de guardar
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B3954),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: _registrarUsuario,
                              child: const Text(
                                'Guardar Usuario',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Botón cancelar
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(200, 160, 160, 160),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
