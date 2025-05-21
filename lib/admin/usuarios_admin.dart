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

  void _cargarUsuarios() {
    _dbRef.onValue.listen(
      (DatabaseEvent event) {
        final data = event.snapshot.value;

        // Verifica si el snapshot no es nulo y es un mapa
        if (data != null && data is Map<dynamic, dynamic>) {
          setState(() {
            _usuarios.clear();

            data.forEach((key, value) {
              if (value is Map && value['rol']?.toString() == 'Cliente') {
                _usuarios.add({
                  'uid': key.toString(),
                  'nombre': value['nombre']?.toString() ?? 'Sin nombre',
                  'email': value['email']?.toString() ?? 'Sin email',
                  'fechaRegistro': _formatDate(value['fechaRegistro']),
                });
              }
            });

            // Ordena los usuarios por fecha de registro (más reciente primero)
            _usuarios.sort(
              (a, b) => b['fechaRegistro'].compareTo(a['fechaRegistro']),
            );
            _isLoading = false; // Detener el estado de carga
          });
        } else {
          setState(() {
            _usuarios.clear(); // Si no hay usuarios, limpiar la lista
            _isLoading = false; // Detener el estado de carga
          });
        }
      },
      onError: (error) {
        if (mounted) {
          _mostrarErrorDialog('Error al cargar usuarios: ${error.toString()}');
        }
        setState(() => _isLoading = false);
      },
    );
  }

  // Función auxiliar para formatear la fecha
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Desconocida';

    try {
      if (timestamp is int || timestamp is double) {
        return DateTime.fromMillisecondsSinceEpoch(
          timestamp.toInt(),
        ).toString().substring(0, 16);
      }
      return timestamp.toString();
    } catch (e) {
      return timestamp.toString();
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
                onPressed: () => Navigator.of(context).pop(),
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

  void _agregarUsuario() async {
    final nuevoUsuario = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormularioUsuario()),
    );

    if (nuevoUsuario != null) {
      _cargarUsuarios();
    }
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(30, 75, 105, 1),
              Color.fromRGBO(150, 193, 212, 1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(170, 217, 238, 1),
                    Color.fromRGBO(30, 75, 105, 1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset('images/icon.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cargando...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Un momento por favor',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontStyle: FontStyle.italic,
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                          style: TextStyle(
                            color: Color.fromRGBO(30, 75, 105, 1),
                          ),
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
                        _usuarios.isEmpty
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        Text(
                                          'Email: ${usuario['email']}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Rol: ${usuario['rol']}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingScreen(),
        ],
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
  String? _selectedRol = 'Cliente';
  String? _selectedHorario1;
  String? _selectedHorario2;
  String? _selectedHorario3;
  String? _selectedHorario4;
  bool _showHorarios = false;
  final List<String> _roles = ['Cliente', 'Profesional'];
  final List<String> _horarios = [
    '12:00 AM',
    '1:00 AM',
    '2:00 AM',
    '3:00 AM',
    '4:00 AM',
    '5:00 AM',
    '6:00 AM',
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
    '10:00 PM',
    '11:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRol = 'Cliente';
  }

  Future<void> _registrarUsuario() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _selectedRol == null) {
      _mostrarErrorDialog('Por favor, completa todos los campos obligatorios');
      return;
    }

    if (_selectedRol == 'Profesional' &&
        (_selectedHorario1 == null ||
            _selectedHorario2 == null ||
            _selectedHorario3 == null ||
            _selectedHorario4 == null)) {
      _mostrarErrorDialog(
        'Por favor, selecciona los 4 horarios para el profesional',
      );
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
          'rol': _selectedRol,
          'tema': 'claro', // tema por defecto
        };

        if (_selectedRol == 'Profesional') {
          userData['horario1'] = _selectedHorario1;
          userData['horario2'] = _selectedHorario2;
          userData['horario3'] = _selectedHorario3;
          userData['horario4'] = _selectedHorario4;
        }

        await databaseRef.child('usuarios/$userId').set(userData);
      }

      if (mounted) {
        Navigator.pop(context, true);
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
                onPressed: () => Navigator.of(context).pop(),
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
    return Material(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(30, 75, 105, 1),
                Color.fromRGBO(150, 193, 212, 1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(170, 217, 238, 1),
                      Color.fromRGBO(30, 75, 105, 1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset('images/icon.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Un momento por favor',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    Function(String?) onChanged,
    String hint,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          items.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: onChanged,
      hint: Text(hint),
      isExpanded: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 30),
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
                      const SizedBox(height: 40),
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
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
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
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
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
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                          ),
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(color: Colors.black),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
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
                      DropdownButtonFormField<String>(
                        value: _selectedRol,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          labelText: 'Selecciona un rol',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items:
                            _roles.map((rol) {
                              return DropdownMenuItem<String>(
                                value: rol,
                                child: Text(rol),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedRol = newValue;
                            _showHorarios = newValue == 'Profesional';
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Selecciona un rol' : null,
                      ),
                      if (_showHorarios) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Horarios del Profesional:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDropdown(
                          _selectedHorario1,
                          _horarios,
                          (newValue) =>
                              setState(() => _selectedHorario1 = newValue),
                          'Horario 1',
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          _selectedHorario2,
                          _horarios,
                          (newValue) =>
                              setState(() => _selectedHorario2 = newValue),
                          'Horario 2',
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          _selectedHorario3,
                          _horarios,
                          (newValue) =>
                              setState(() => _selectedHorario3 = newValue),
                          'Horario 3',
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          _selectedHorario4,
                          _horarios,
                          (newValue) =>
                              setState(() => _selectedHorario4 = newValue),
                          'Horario 4',
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 30),
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
          if (_isLoading) _buildLoadingScreen(),
        ],
      ),
    );
  }
}
