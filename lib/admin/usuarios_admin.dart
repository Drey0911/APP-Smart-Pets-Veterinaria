import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../theme_model.dart'; // Asegúrate de importar tu ThemeModel

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

        if (data != null && data is Map<dynamic, dynamic>) {
          setState(() {
            _usuarios.clear();

            data.forEach((key, value) {
              if (value is Map) {
                // Verificación más robusta del rol
                final rol =
                    value['rol']?.toString() ??
                    'Cliente'; // Valor por defecto si es null
                if (rol == 'Cliente' || rol == 'Profesional') {
                  _usuarios.add({
                    'uid': key.toString(),
                    'nombre': value['nombre']?.toString() ?? 'Sin nombre',
                    'email': value['email']?.toString() ?? 'Sin email',
                    'rol': rol, // Asegurarnos de incluir el rol
                    'fechaRegistro': _formatDate(value['fechaRegistro']),
                  });
                }
              }
            });

            _usuarios.sort(
              (a, b) => b['fechaRegistro'].compareTo(a['fechaRegistro']),
            );
            _isLoading = false;
          });
        } else {
          setState(() {
            _usuarios.clear();
            _isLoading = false;
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
      builder: (context) {
        final themeModel = Provider.of<ThemeModel>(context, listen: false);
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  themeModel.isDarkMode
                      ? Colors.white
                      : const Color.fromARGB(255, 17, 46, 88),
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: themeModel.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          backgroundColor:
              themeModel.isDarkMode
                  ? Color.fromRGBO(30, 75, 105, 1)
                  : Colors.white,
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
        );
      },
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

  Widget _buildLoadingScreen(ThemeModel themeModel) {
    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                themeModel.isDarkMode
                    ? [
                      Color.fromRGBO(30, 75, 105, 1),
                      Color.fromRGBO(15, 47, 67, 1),
                    ]
                    : [
                      Color.fromRGBO(150, 193, 212, 1),
                      Color.fromRGBO(200, 225, 235, 1),
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
                gradient: LinearGradient(
                  colors:
                      themeModel.isDarkMode
                          ? [
                            Color.fromRGBO(30, 75, 105, 1),
                            Color.fromRGBO(15, 47, 67, 1),
                          ]
                          : [
                            Color.fromRGBO(170, 217, 238, 1),
                            Color.fromRGBO(200, 225, 235, 1),
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
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                themeModel.isDarkMode ? Colors.white : Color(0xFF1E4B69),
              ),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  color:
                      themeModel.isDarkMode ? Colors.white : Color(0xFF1E4B69),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cargando...',
                  style: TextStyle(
                    color:
                        themeModel.isDarkMode
                            ? Colors.white
                            : Color(0xFF1E4B69),
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
                color:
                    themeModel.isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : Color(0xFF1E4B69).withOpacity(0.9),
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
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
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
                              color:
                                  themeModel.isDarkMode
                                      ? Colors.white
                                      : Colors.white,
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
                                side: BorderSide(
                                  color:
                                      themeModel.isDarkMode
                                          ? Colors.white70
                                          : Color.fromRGBO(30, 75, 105, 1),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              themeModel.isDarkMode
                                  ? Color.fromRGBO(15, 47, 67, 1)
                                  : Colors.white.withOpacity(0.9),
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
                                        color:
                                            themeModel.isDarkMode
                                                ? Colors.white70
                                                : Color(
                                                  0xFF1E4B69,
                                                ).withOpacity(0.5),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No hay usuarios registrados',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              themeModel.isDarkMode
                                                  ? Colors.white70
                                                  : Color(
                                                    0xFF1E4B69,
                                                  ).withOpacity(0.7),
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
                                        color:
                                            themeModel.isDarkMode
                                                ? Color.fromRGBO(
                                                  18,
                                                  55,
                                                  78,
                                                  1,
                                                ).withOpacity(0.85)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(16),
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              themeModel.isDarkMode
                                                  ? Color.fromRGBO(
                                                    110,
                                                    153,
                                                    171,
                                                    0.788,
                                                  )
                                                  : Color.fromRGBO(
                                                    5,
                                                    39,
                                                    60,
                                                    1,
                                                  ).withOpacity(0.4),
                                          child: Icon(
                                            Icons.person,
                                            size: 30,
                                            color:
                                                themeModel.isDarkMode
                                                    ? Color.fromRGBO(
                                                      15,
                                                      47,
                                                      67,
                                                      1,
                                                    )
                                                    : Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          usuario['nombre'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                themeModel.isDarkMode
                                                    ? Colors.white
                                                    : Color(0xFF1E4B69),
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 8),
                                            Text(
                                              'Email: ${usuario['email']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    themeModel.isDarkMode
                                                        ? Colors.white70
                                                        : Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Rol: ${usuario['rol'] ?? 'Cliente'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    themeModel.isDarkMode
                                                        ? Colors.white70
                                                        : Colors.black87,
                                              ),
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
              if (_isLoading) _buildLoadingScreen(themeModel),
            ],
          ),
        );
      },
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
            backgroundColor: Color.fromARGB(255, 220, 222, 223),
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
    String label,
    ThemeModel themeModel, {
    Color? textColor,
    Color? borderColor,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor ?? Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor ?? Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        filled: true,
        fillColor:
            themeModel.isDarkMode
                ? Color.fromRGBO(15, 47, 67, 1)
                : Colors.white,
      ),
      dropdownColor:
          themeModel.isDarkMode ? Color.fromRGBO(15, 47, 67, 1) : Colors.white,
      style: TextStyle(color: textColor),
      items:
          items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(color: textColor)),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        final backgroundColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(15, 47, 67, 1)
                : Colors.white;
        final buttonColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(121, 167, 199, 1)
                : const Color.fromRGBO(30, 75, 105, 1);
        final cancelButtonColor =
            themeModel.isDarkMode
                ? Colors.grey[700]
                : const Color.fromARGB(200, 160, 160, 160);
        final textColor = themeModel.isDarkMode ? Colors.white : Colors.black;
        final borderColor =
            themeModel.isDarkMode
                ? Colors.white54
                : const Color.fromARGB(145, 11, 48, 73);

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [backgroundColor, backgroundColor],
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
                                child: Center(
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
                                color: borderColor,
                              ),
                              labelText: 'Nombre',
                              labelStyle: TextStyle(color: textColor),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: borderColor),
                              labelText: 'E-mail',
                              labelStyle: TextStyle(color: textColor),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: TextStyle(color: textColor),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: borderColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: borderColor,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _isPasswordVisible =
                                              !_isPasswordVisible,
                                    ),
                              ),
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(color: textColor),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRol,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: borderColor,
                              ),
                              labelText: 'Selecciona un rol',
                              labelStyle: TextStyle(color: textColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              filled: true,
                              fillColor:
                                  themeModel.isDarkMode
                                      ? Color.fromRGBO(15, 47, 67, 1)
                                      : Colors.white,
                            ),
                            dropdownColor:
                                themeModel.isDarkMode
                                    ? Color.fromRGBO(15, 47, 67, 1)
                                    : Colors.white,
                            style: TextStyle(color: textColor),
                            items:
                                _roles.map((rol) {
                                  return DropdownMenuItem<String>(
                                    value: rol,
                                    child: Text(
                                      rol,
                                      style: TextStyle(color: textColor),
                                    ),
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
                            Text(
                              'Horarios del Profesional:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDropdown(
                              _selectedHorario1,
                              _horarios,
                              (newValue) =>
                                  setState(() => _selectedHorario1 = newValue),
                              'Horario 1',
                              themeModel,
                              textColor: textColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              _selectedHorario2,
                              _horarios,
                              (newValue) =>
                                  setState(() => _selectedHorario2 = newValue),
                              'Horario 2',
                              themeModel,
                              textColor: textColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              _selectedHorario3,
                              _horarios,
                              (newValue) =>
                                  setState(() => _selectedHorario3 = newValue),
                              'Horario 3',
                              themeModel,
                              textColor: textColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              _selectedHorario4,
                              _horarios,
                              (newValue) =>
                                  setState(() => _selectedHorario4 = newValue),
                              'Horario 4',
                              themeModel,
                              textColor: textColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 30),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: buttonColor,
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
                              color: cancelButtonColor,
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
                              child: Text(
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
      },
    );
  }
}
