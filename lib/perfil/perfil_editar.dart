import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../login.dart';
import '../theme_model.dart';

class EditarPerfil extends StatefulWidget {
  final String uid;
  final String userName;
  final String email;
  final String password;
  final Function(String) onProfileUpdated;

  const EditarPerfil({
    Key? key,
    required this.uid,
    required this.userName,
    required this.email,
    required this.password,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditarPerfilState createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _dbRef.child('usuarios').child(widget.uid).update({
        'nombre': _nameController.text,
      });

      widget.onProfileUpdated(_nameController.text);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) {
          final themeModel = Provider.of<ThemeModel>(context);
          return Theme(
            data: Theme.of(context).copyWith(
              dialogTheme: DialogTheme(
                backgroundColor:
                    themeModel.isDarkMode
                        ? Color.fromRGBO(15, 47, 67, 1)
                        : Colors.white,
              ),
            ),
            child: AlertDialog(
              title: Text(
                'Nombre actualizado correctamente',
                style: TextStyle(
                  color:
                      themeModel.isDarkMode
                          ? Colors.white
                          : const Color.fromARGB(255, 17, 46, 88),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'la APP se va a reiniciar para guardar cambios',
                style: TextStyle(
                  color:
                      themeModel.isDarkMode
                          ? Colors.white70
                          : const Color.fromARGB(255, 17, 46, 88),
                ),
              ),
              actions: [
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
              ],
            ),
          );
        },
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        final primaryColor =
            themeModel.isDarkMode
                ? const Color.fromARGB(255, 160, 194, 214)
                : const Color.fromARGB(255, 17, 46, 88);
        final backgroundColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(15, 47, 67, 1)
                : Colors.white;
        final cardColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(15, 47, 67, 1)
                : const Color.fromARGB(124, 255, 255, 255);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Editar Perfil",
              style: TextStyle(
                color: primaryColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            color: backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: primaryColor,
                  child: Icon(
                    Icons.person,
                    size: 120,
                    color:
                        themeModel.isDarkMode
                            ? Color.fromRGBO(15, 47, 67, 1)
                            : Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            'Información del perfil:',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 17, 46, 88),
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildEditableField(
                            label: "Nombre completo",
                            controller: _nameController,
                            icon: Icons.person,
                            primaryColor: primaryColor,
                            cardColor: cardColor,
                            themeModel: themeModel,
                          ),
                          const SizedBox(height: 30),
                          _buildReadOnlyField(
                            label: "Correo electrónico",
                            value: widget.email,
                            icon: Icons.email,
                            primaryColor: primaryColor,
                            cardColor: cardColor,
                            themeModel: themeModel,
                          ),
                          const SizedBox(height: 30),
                          _buildPasswordField(
                            label: "Contraseña",
                            value: widget.password,
                            icon: Icons.lock,
                            primaryColor: primaryColor,
                            cardColor: cardColor,
                            themeModel: themeModel,
                          ),
                          const SizedBox(height: 40),
                          _isLoading
                              ? CircularProgressIndicator(color: primaryColor)
                              : ElevatedButton(
                                onPressed: _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  "Guardar cambios",
                                  style: TextStyle(
                                    color:
                                        themeModel.isDarkMode
                                            ? Color.fromRGBO(15, 47, 67, 1)
                                            : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color primaryColor,
    required Color cardColor,
    required ThemeModel themeModel,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: primaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        floatingLabelStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required Color primaryColor,
    required Color cardColor,
    required ThemeModel themeModel,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: TextStyle(color: primaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        floatingLabelStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 1.0),
        ),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String value,
    required IconData icon,
    required Color primaryColor,
    required Color cardColor,
    required ThemeModel themeModel,
  }) {
    return TextFormField(
      initialValue: "••••••••",
      readOnly: true,
      obscureText: true,
      style: TextStyle(color: primaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        floatingLabelStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 1.0),
        ),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
    );
  }
}
