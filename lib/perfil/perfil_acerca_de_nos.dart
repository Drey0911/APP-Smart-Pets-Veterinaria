import 'package:flutter/material.dart';

class AcercaDeNosotros extends StatelessWidget {
  const AcercaDeNosotros({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color.fromARGB(255, 17, 46, 88),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Acerca de nosotros",
          style: TextStyle(
            color: const Color.fromARGB(255, 17, 46, 88),
            fontSize: 25,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Color.fromRGBO(140, 189, 210, 1),
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromRGBO(170, 217, 238, 0.3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(150, 195, 214, 1),
                      Color.fromRGBO(150, 195, 214, 1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Image.asset('images/logo.png', width: 270, height: 270),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        'En Smart Pets, nuestra misión es hacer que el cuidado de tu mascota sea más fácil, accesible y eficiente. Sabemos que tu compañero peludo es parte importante de tu familia, y por eso hemos creado una app diseñada especialmente para conectar a los dueños de mascotas con servicios veterinarios de alta calidad, todo desde la comodidad de su teléfono móvil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 17, 46, 88),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Nuestra Visión'),
                    _buildContentCard(
                      'Convertirnos en la plataforma líder en cuidado de mascotas, ofreciendo soluciones innovadoras que mejoren la calidad de vida de las mascotas y faciliten la labor de sus dueños.',
                    ),
                    SizedBox(height: 20),
                    _buildSectionTitle('Nuestros Valores'),
                    _buildValueItem(
                      Icons.favorite,
                      'Amor por los animales',
                      'Nos impulsa un profundo respeto y amor por todas las mascotas.',
                    ),
                    _buildValueItem(
                      Icons.verified_user,
                      'Profesionalismo',
                      'Trabajamos con veterinarios certificados y profesionales del cuidado animal.',
                    ),
                    _buildValueItem(
                      Icons.accessibility_new,
                      'Accesibilidad',
                      'Creemos que el cuidado de calidad debe estar al alcance de todos.',
                    ),
                    _buildValueItem(
                      Icons.eco,
                      'Responsabilidad',
                      'Promovemos la tenencia responsable y el bienestar animal.',
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.2,
                          ), // Fondo semitransparente.
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Bordes redondeados.
                        ),
                        child: Center(
                          child: Text(
                            '© 2025 Smart Pets. Todos los derechos reservados.', // Mensaje de copyright.
                            style: TextStyle(
                              color: const Color.fromARGB(
                                255,
                                17,
                                46,
                                88,
                              ), // Color del texto.
                              fontSize: 12, // Tamaño de la fuente.
                              fontWeight: FontWeight.bold, // Texto en negrita.
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          color: const Color.fromARGB(255, 17, 46, 88),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Color.fromRGBO(140, 189, 210, 0.7),
              offset: Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        content,
        style: TextStyle(color: Colors.black87, fontSize: 15),
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String title, String description) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 17, 46, 88).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 17, 46, 88),
              size: 30,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 17, 46, 88),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
