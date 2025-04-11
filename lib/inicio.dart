import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'citas.dart'; // Import citas.dart
import 'mascotas.dart'; // Import mascotas.dart
import 'notificaciones.dart'; // Import notificaciones
import 'perfil/perfil.dart'; // Import perfil.dart
import 'perfil/perfil_acerca_de_nos.dart';
import 'perfil/perfil_contactanos.dart';

// VARIABLE GLOBAL PARA EL MANEJO DE EL MENSAJE DE PERMISOS
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() => runApp(inicio());

class inicio extends StatelessWidget {
  const inicio({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener los argumentos pasados desde login.dart
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Valores por defecto en caso de que args sea null
    final String nombreUsuario = args?['nombreusu'] ?? 'Usuario';
    final String email = args?['email'] ?? '';
    final String password = args?['password'] ?? '';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartPets Menú',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: MyHomePage(
        userName: nombreUsuario,
        email: email,
        password: password,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String userName;
  final String email;
  final String password; // Campo para almacenar la contraseña del usuario

  const MyHomePage({
    super.key,
    required this.userName,
    required this.email,
    required this.password,
  }); // Acepta el nombre del usuario y demas entradas

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variables para almacenar la información del usuario
  late String userName;
  late String email;
  late String password;
  bool _tieneNotificacionesNoLeidas = false;
  late SharedPreferences _prefs;
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  // Historial de navegación para controlar el botón de retroceso
  final List<int> _navigationHistory = [0];

  @override
  void initState() {
    super.initState();
    // Inicializa las variables con los valores recibidos
    userName = widget.userName;
    email = widget.email;
    password = widget.password;

    _cargarEstadoNotificaciones();
    _initializePages();
    // Verificar permisos de notificaciones cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarPermisosNotificaciones();
    });
  }

  void _initializePages() {
    _pages = [
      PaginaInicio(userName: userName),
      Citas(),
      Mascotas(),
      Perfil(
        userName: userName,
        email: email,
        password: password,
        onProfileUpdated: _updateProfile,
      ),
      AcercaDeNosotros(),
      Contactanos(),
    ];
  }

  // Función para actualizar el perfil y todas las páginas que dependen de esos datos PAGINAS DEPENDIENTES
  void _updateProfile(String newUserName, String newEmail, String newPassword) {
    setState(() {
      userName = newUserName;
      email = newEmail;
      password = newPassword;

      // También actualiza las páginas en el IndexedStack
      _pages = [
        PaginaInicio(userName: userName),
        Citas(),
        Mascotas(),
        Perfil(
          userName: userName,
          email: email,
          password: password,
          onProfileUpdated: _updateProfile,
        ),
        AcercaDeNosotros(),
        Contactanos(),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      // Si seleccionamos un índice diferente, lo agregamos al historial
      if (_selectedIndex != index) {
        _navigationHistory.add(index);
      }
      _selectedIndex = index;
    });
  }

  // Método para manejar el botón de retroceso
  Future<bool> _onWillPop() async {
    if (_navigationHistory.length > 1) {
      // Eliminar el índice actual
      _navigationHistory.removeLast();
      // Establecer como índice activo el anterior en el historial
      setState(() {
        _selectedIndex = _navigationHistory.last;
      });
      return false; // No salir de la app
    }

    // Si no hay historial (ya estamos en la pantalla inicial), mostrar diálogo de confirmación
    final shouldExit = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('¿Salir de la aplicación?'),
            content: Text('¿Estás seguro que quieres salir de SmartPets?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Salir'),
              ),
            ],
          ),
    );

    return shouldExit ?? false;
  }

  // Método para verificar y solicitar permisos de notificaciones
  Future<void> _verificarPermisosNotificaciones() async {
    // Verificar el estado actual del permiso
    final status = await Permission.notification.status;

    // Si el permiso no se ha solicitado aún, mostrar el diálogo de solicitud
    if (status.isDenied) {
      // Solicitar permiso
      await Permission.notification.request().then((result) {
        _mostrarResultadoPermiso(result);
      });
    }
  }

  // Mostrar el resultado del permiso con un mensaje
  void _mostrarResultadoPermiso(PermissionStatus status) {
    String mensaje = '';

    if (status.isGranted) {
      mensaje = 'Permisos de notificación concedidos';
    } else if (status.isDenied) {
      mensaje = 'Permisos de notificación denegados';
    } else if (status.isPermanentlyDenied) {
      mensaje =
          'Permisos denegados permanentemente. Puede habilitarlos en la configuración';

      // Mostrar un SnackBar con opción para abrir la configuración
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(mensaje),
          action: SnackBarAction(
            label: 'Abrir Configuración',
            onPressed: () => openAppSettings(),
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return; // Salir para evitar mostrar el SnackBar normal
    }

    // Mostrar un SnackBar normal para los otros casos
    if (mensaje.isNotEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  Future<void> _cargarEstadoNotificaciones() async {
    _prefs = await SharedPreferences.getInstance();
    final notificaciones = _prefs.getStringList('notificaciones') ?? [];
    setState(() {
      _tieneNotificacionesNoLeidas = notificaciones.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('SmartPets'),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => NotificacionesPage(
                              onNotificacionesCambiadas: (tieneNotificaciones) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(() {
                                      _tieneNotificacionesNoLeidas =
                                          tieneNotificaciones;
                                    });
                                  }
                                });
                              },
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.notifications),
                ),
                if (_tieneNotificacionesNoLeidas)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Container(
          height: 88,
          decoration: BoxDecoration(
            color: Color(0xFFECECEC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              bool isSelected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconForIndex(index),
                          color: Color(0xFF0A3C5E),
                          size: 30,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _getLabelForIndex(index),
                          style: TextStyle(
                            color: Color(0xFF0A3C5E),
                            fontSize: 16,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.calendar_month_outlined;
      case 2:
        return Icons.pets;
      case 3:
        return Icons.person;
      default:
        return Icons.home;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Mis Citas';
      case 2:
        return 'Mascotas';
      case 3:
        return 'Perfil';
      default:
        return 'Inicio';
    }
  }
}

// 🎯 Página de Inicio con Carousel Manual
class PaginaInicio extends StatefulWidget {
  final String userName; // Field to hold the user's name

  const PaginaInicio({
    super.key,
    required this.userName,
  }); // Accept the user's name

  @override
  _PaginaInicioState createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio> {
  final List<String> carouselImages = [
    'images/banner1.png',
    'images/banner2.png',
    'images/banner3.png',
  ];

  final List<String> urls = [
    'https://www.youtube.com/watch?v=z_70XoQB5Yg/banner1',
    'https://www.youtube.com/watch?v=FVUQfoCAUGk/banner2',
    'https://example.com/banner3',
  ];

  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // CARROUSEL AUTOMATICO
    Future.delayed(Duration.zero, () {
      Timer.periodic(Duration(seconds: 6), (Timer timer) {
        if (_pageController.hasClients) {
          int nextPage = (_currentPage + 1) % carouselImages.length;
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // APLICACION SCROLL: Se agregó SingleChildScrollView para permitir el desplazamiento vertical de toda la página.
      child: Column(
        children: [
          // Welcome Text
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: const Color.fromARGB(255, 17, 46, 88),
                    fontSize: 23,
                  ),
                  children: [
                    TextSpan(text: 'Bienvenido '),
                    TextSpan(
                      text: '${widget.userName} ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '!'),
                  ],
                ),
              ),
            ),
          ),

          // Manual Carousel
          SizedBox(height: 20),
          SizedBox(
            height: 200, // Increased height for the banner
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: carouselImages.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _launchURL(urls[index]),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(carouselImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(carouselImages.length, (index) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index
                                  ? const Color.fromARGB(255, 17, 46, 88)
                                  : const Color.fromARGB(255, 255, 255, 255),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Title for Services Section
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 50.0, // Reduced top margin
                bottom: 15.0, // Added bottom margin for spacing
              ),
              child: Text(
                'Servicios:',
                style: TextStyle(
                  color: const Color.fromARGB(255, 17, 46, 88),
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Services Section
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(20), // Adjusted padding
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
              shrinkWrap: true, // Prevents GridView from scrolling
              physics:
                  NeverScrollableScrollPhysics(), // Disable GridView scroll
              crossAxisCount: 2,
              crossAxisSpacing: 20, // Increased spacing between buttons
              mainAxisSpacing: 38, // Increased spacing between buttons
              childAspectRatio: 1.4, // Adjusted to make buttons smaller
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 194, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10, // Added elevation for shadow effect
                    shadowColor: Colors.black54, // Shadow color
                  ),
                  onPressed: () {
                    // Add navigation or action
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 60, // Increased icon size
                        color: const Color.fromARGB(255, 17, 46, 88),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Agendar cita',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 17, 46, 88),
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increased font size
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 194, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10, // Added elevation for shadow effect
                    shadowColor: Colors.black54, // Shadow color
                  ),
                  onPressed: () {
                    // Add navigation or action
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 60, // Increased icon size
                        color: const Color.fromARGB(255, 17, 46, 88),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vacunación',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 17, 46, 88),
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increased font size
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 194, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10, // Added elevation for shadow effect
                    shadowColor: Colors.black54, // Shadow color
                  ),
                  onPressed: () {
                    // Add navigation or action
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.clean_hands,
                        size: 60, // Increased icon size
                        color: const Color.fromARGB(255, 17, 46, 88),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Limpieza',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 17, 46, 88),
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increased font size
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 194, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10, // Added elevation for shadow effect
                    shadowColor: Colors.black54, // Shadow color
                  ),
                  onPressed: () {
                    // Add navigation or action
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cut,
                        size: 60, // Increased icon size
                        color: const Color.fromARGB(255, 17, 46, 88),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Peluquería',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 17, 46, 88),
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increased font size
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ); // APLICACION SCROLL: Aquí se cierra el SingleChildScrollView que permite el desplazamiento vertical de toda la página.
  }
}
