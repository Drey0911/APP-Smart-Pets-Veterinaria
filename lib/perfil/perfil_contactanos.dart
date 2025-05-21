// Importamos el paquete principal de Flutter para usar sus widgets.
import 'package:flutter/material.dart';

// Definimos un widget sin estado llamado Contactanos.
class Contactanos extends StatelessWidget {
  // Constructor constante de la clase con una clave opcional.
  const Contactanos({Key? key}) : super(key: key);

  // Método que construye la interfaz de usuario.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar de la parte superior de la pantalla.
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Sin color de fondo.
        shadowColor: Colors.transparent, // Sin sombra.
        elevation: 0, // Sin elevación (plano).
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, // Ícono de retroceso.
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color.fromARGB(
                      255,
                      17,
                      46,
                      88,
                    ), // Color azul oscuro.
          ),
          onPressed:
              () => Navigator.pop(context), // Volver a la pantalla anterior.
        ),
        title: Text(
          "Contáctanos", // Título del AppBar.
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color.fromARGB(255, 17, 46, 88),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Centrar el título.
      ),

      // Cuerpo principal de la pantalla.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Degradado de fondo.
            colors: [
              Color.fromRGBO(150, 195, 214, 1),
              Color.fromRGBO(150, 195, 214, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          // Permite desplazamiento si hay mucho contenido.
          child: Column(
            children: [
              SizedBox(height: 20), // Espacio vertical.
              Image.asset('images/logo.png', width: 270, height: 270), // Logo.
              SizedBox(height: 40),
              Container(
                width: double.infinity, // Ocupa todo el ancho.
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50),
                  ), // Bordes redondeados superiores.
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -4), // Sombra desde arriba.
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          _buildSectionTitle(
                            'Información de Contacto',
                          ), // Título de la sección.
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    // Información de contacto.
                    _buildContactInfo(
                      Icons.email,
                      'Email',
                      'correo@smartpets.com',
                    ),
                    _buildContactInfo(
                      Icons.phone,
                      'Teléfono',
                      '+57 300 123 4567',
                    ),
                    _buildContactInfo(
                      Icons.location_on,
                      'Dirección',
                      'Calle 123 #45-67, Bogotá, Colombia',
                    ),
                    _buildContactInfo(
                      Icons.language,
                      'Web',
                      'www.smartpets.com',
                    ),
                    SizedBox(height: 30),
                    _buildSectionTitle('Síguenos en Redes'),
                    SizedBox(height: 20),
                    _buildSocialMediaRow(), // Redes sociales.
                    SizedBox(height: 30),
                    _buildSectionTitle('Horario de Atención'),
                    SizedBox(height: 10),
                    // Horarios por día.
                    _buildScheduleInfo('Lunes a Viernes', '8:00 AM - 6:00 PM'),
                    _buildScheduleInfo('Sábados', '9:00 AM - 1:00 PM'),
                    _buildScheduleInfo('Domingos y Festivos', 'Cerrado'),
                    SizedBox(height: 30),
                    // Pie de página.
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            '© 2025 Smart Pets. Todos los derechos reservados.',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 17, 46, 88),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir los títulos de las secciones.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color.fromARGB(255, 17, 46, 88),
        fontSize: 22,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: const Color.fromARGB(255, 17, 46, 88),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  // Método para mostrar información de contacto (ícono, título, y contenido).
  Widget _buildContactInfo(IconData icon, String label, String info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 17, 46, 88), size: 30),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 17, 46, 88),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  info,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 17, 46, 88),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fila con botones de redes sociales.
  Widget _buildSocialMediaRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSocialMediaButton(Icons.facebook, "Facebook"),
        _buildSocialMediaButton(Icons.telegram, "Instagram"),
        _buildSocialMediaButton(Icons.camera_alt_rounded, "Instagram"),
        _buildSocialMediaButton(Icons.chat_rounded, "Whatsapp"),
      ],
    );
  }

  // Botón individual para cada red social.
  Widget _buildSocialMediaButton(IconData icon, String platform) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 2))],
          ),
          child: Icon(
            icon,
            color: const Color.fromARGB(255, 17, 46, 88),
            size: 30,
          ),
        ),
        SizedBox(height: 8),
        Text(
          platform,
          style: TextStyle(
            color: const Color.fromARGB(255, 17, 46, 88),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Muestra información de horario por día.
  Widget _buildScheduleInfo(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 17, 46, 88),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Text(
            day,
            style: TextStyle(
              color: const Color.fromARGB(255, 17, 46, 88),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            hours,
            style: TextStyle(
              color: const Color.fromARGB(255, 17, 46, 88),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
