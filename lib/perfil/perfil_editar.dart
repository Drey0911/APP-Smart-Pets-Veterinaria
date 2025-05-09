import 'package:flutter/material.dart'; // Importa los widgets y materiales de diseño de Flutter.

class EditarPerfil extends StatefulWidget {
  // Clase Stateful para permitir cambios dinámicos en la pantalla.
  final String userName;
  final String email;
  final String password;

  const EditarPerfil({
    Key? key,
    required this.userName,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  _EditarPerfilState createState() => _EditarPerfilState(); // Crea el estado asociado.
}

class _EditarPerfilState extends State<EditarPerfil> {
  late TextEditingController _nameController; // Controlador del campo nombre
  late TextEditingController _emailController; // Controlador del campo email
  late TextEditingController
  _passwordController; // Controlador del campo contraseña
  bool _isPasswordVisible = false; // Controla la visibilidad de la contraseña

  // Color azul oscuro que se usará en todo el diseño
  final Color azulOscuro = Color.fromARGB(255, 17, 46, 88);

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los valores que recibe el widget
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    // Libera los recursos al cerrar el widget
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz de usuario
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fondo transparente
        elevation: 0, // Sin sombra
        // Centra el título del AppBar horizontalmente dentro del espacio disponible.
        centerTitle: true,
        title: Text(
          "Editar Perfil",
          style: TextStyle(
            color: azulOscuro, // Azul oscuro
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          // Botón de retroceso
          icon: Icon(Icons.arrow_back, color: azulOscuro),
          onPressed:
              () => Navigator.pop(context), // Vuelve a la pantalla anterior
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          CircleAvatar(
            // Avatar de usuario
            radius: 70,
            backgroundColor: azulOscuro,
            child: Icon(Icons.person, size: 120, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            widget.userName, // Muestra el nombre actual del usuario
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 25),
          Expanded(
            child: Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Fondo degradado
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
                    // Sombra del contenedor
                    color: azulOscuro,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'Informacion a editar:',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 17, 46, 88),
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildFloatingLabelField(
                      label: "Nombre completo",
                      controller: _nameController,
                      icon: Icons.person,
                    ),
                    SizedBox(height: 30),
                    _buildFloatingLabelField(
                      label: "Correo",
                      controller: _emailController,
                      icon: Icons.email,
                    ),
                    SizedBox(height: 30),
                    _buildPasswordFloatingField(), // Campo editable para contraseña con estilo floating
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        // Muestra mensaje de confirmación
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cambios guardados exitosamente'),
                          ),
                        );
                        // Retorna los nuevos valores al cerrar la pantalla
                        Navigator.pop(context, {
                          'name': _nameController.text,
                          'email': _emailController.text,
                          'password': _passwordController.text,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulOscuro,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Guardar",
                        style: TextStyle(
                          color: Colors.white,
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
    );
  }

  // Método para construir campos de texto con etiqueta flotante
  Widget _buildFloatingLabelField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: azulOscuro),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: azulOscuro),
        floatingLabelStyle: TextStyle(
          color: azulOscuro,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: azulOscuro),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: azulOscuro, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: azulOscuro, width: 2.0),
        ),
        filled: true,
        fillColor: const Color.fromARGB(124, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      onChanged: (value) {
        // Actualiza el estado cuando cambia el texto
        setState(() {});
      },
    );
  }

  // Método especializado para el campo de contraseña con etiqueta flotante
  Widget _buildPasswordFloatingField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible, // Oculta o muestra la contraseña
      style: TextStyle(color: azulOscuro),
      decoration: InputDecoration(
        labelText: "Contraseña",
        labelStyle: TextStyle(color: azulOscuro),
        floatingLabelStyle: TextStyle(
          color: azulOscuro,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(Icons.lock, color: azulOscuro),
        suffixIcon: IconButton(
          // Botón para mostrar/ocultar contraseña
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: azulOscuro,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible; // Cambia el estado
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: azulOscuro, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: azulOscuro, width: 2.0),
        ),
        filled: true,
        fillColor: const Color.fromARGB(124, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      onChanged: (value) {
        // Actualiza el estado cuando cambia el texto
        setState(() {});
      },
    );
  }
}
