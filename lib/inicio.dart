import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'citas.dart'; // Import citas.dart
import 'mascotas.dart'; // Import mascotas.dart
import 'notificaciones.dart'; // Import notificaciones.dart
import 'perfil/perfil.dart'; // Import perfil.dart
import 'perfil/perfil_acerca_de_nos.dart';
import 'perfil/perfil_contactanos.dart';

// Variable global para el manejo del mensaje de permisos
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() => runApp(InicioApp());

class InicioApp extends StatelessWidget {
  const InicioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener argumentos desde login.dart (si existen)
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Valores por defecto si args es null
    final String nombreUsuario = args?['nombreusu'] ?? 'Usuario';
    final String email = args?['email'] ?? '';
    final String password = args?['password'] ?? '';

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
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
  final String password; // Contraseña del usuario

  const MyHomePage({
    super.key,
    required this.userName,
    required this.email,
    required this.password,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variables de usuario
  late String userName;
  late String email;
  late String password;
  bool _tieneNotificacionesNoLeidas = false;
  late SharedPreferences _prefs;
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  // GlobalKey para conservar la instancia de la pantalla Citas
  final GlobalKey<CitasState> citasKey = GlobalKey<CitasState>();

  // Historial de navegación para el botón de retroceso
  final List<int> _navigationHistory = [0];

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    email = widget.email;
    password = widget.password;

    _cargarEstadoNotificaciones();
    _initializePages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarPermisosNotificaciones();
    });
  }

  void _initializePages() {
    _pages = [
      // Se pasa un callback asíncrono para agregar citas a la instancia de Citas y actualizar notificaciones
      PaginaInicio(
        userName: userName,
        onNuevaCita: (nuevaCita) async {
          citasKey.currentState?.addCita(nuevaCita);
          await _cargarEstadoNotificaciones();
        },
      ),
      Citas(key: citasKey),
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

  // Actualiza el perfil y reconstruye las páginas
  void _updateProfile(String newUserName, String newEmail, String newPassword) {
    setState(() {
      userName = newUserName;
      email = newEmail;
      password = newPassword;
      _initializePages(); // Reconstruir las páginas con los datos actualizados
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex != index) {
        _navigationHistory.add(index);
      }
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      setState(() {
        _selectedIndex = _navigationHistory.last;
      });
      return false;
    }

    final shouldExit = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Salir de la aplicación?'),
            content: const Text(
              '¿Estás seguro que quieres salir de SmartPets?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salir'),
              ),
            ],
          ),
    );
    return shouldExit ?? false;
  }

  Future<void> _verificarPermisosNotificaciones() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request().then((result) {
        _mostrarResultadoPermiso(result);
      });
    }
  }

  void _mostrarResultadoPermiso(PermissionStatus status) {
    String mensaje = '';
    if (status.isGranted) {
      mensaje = 'Permisos de notificación concedidos';
    } else if (status.isDenied) {
      mensaje = 'Permisos de notificación denegados';
    } else if (status.isPermanentlyDenied) {
      mensaje =
          'Permisos denegados permanentemente. Puede habilitarlos en la configuración';
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(mensaje),
          action: SnackBarAction(
            label: 'Abrir Configuración',
            onPressed: () => openAppSettings(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
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
          title: const Text('SmartPets'),
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
                  icon: const Icon(Icons.notifications),
                ),
                if (_tieneNotificacionesNoLeidas)
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      Icons.brightness_1,
                      size: 12,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Container(
          height: 88,
          decoration: const BoxDecoration(
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
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconForIndex(index),
                          color: const Color(0xFF0A3C5E),
                          size: 30,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLabelForIndex(index),
                          style: TextStyle(
                            color: const Color(0xFF0A3C5E),
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

// ===========================================================================
// PÁGINA DE INICIO (CON CAROUSEL Y SECCIÓN DE SERVICIOS)
// ===========================================================================

class PaginaInicio extends StatefulWidget {
  final String userName; // Para dar la bienvenida
  final Future<void> Function(Map<String, dynamic>)
  onNuevaCita; // Callback para enviar nueva cita

  const PaginaInicio({
    super.key,
    required this.userName,
    required this.onNuevaCita,
  });

  @override
  _PaginaInicioState createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio> {
  final List<String> carouselImages = [
    'images/banner1.png',
    'images/banner2.png',
    'images/banner3.png',
  ];

  // Actualiza las URL según a dónde desees navegar
  final List<String> urls = [
    'https://www.youtube.com/watch?v=z_70XoQB5Yg',
    'https://www.youtube.com/watch?v=FVUQfoCAUGk',
    'https://www.youtube.com/watch?v=z_70XoQB5Yg',
  ];

  int _currentPage = 0;
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % carouselImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo acceder a la URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Bienvenida
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Color.fromARGB(255, 17, 46, 88),
                    fontSize: 23,
                  ),
                  children: [
                    const TextSpan(text: 'Bienvenido '),
                    TextSpan(
                      text: '${widget.userName} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '!'),
                  ],
                ),
              ),
            ),
          ),
          // Carousel
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
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
                        margin: const EdgeInsets.symmetric(horizontal: 20),
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
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index
                                  ? const Color.fromARGB(255, 17, 46, 88)
                                  : Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Título de Servicios
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 50.0,
                bottom: 15.0,
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
          // Sección de Servicios con botones.
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
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 38,
              childAspectRatio: 1.4,
              children: [
                // Botón "Agendar cita" (flujo: abrir FormularioTipoCita y luego FormularioCita)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 194, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black54,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormularioTipoCita(),
                      ),
                    ).then((tipoSeleccionado) {
                      if (tipoSeleccionado != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    FormularioCita(tipoCita: tipoSeleccionado),
                          ),
                        ).then((nuevaCita) {
                          if (nuevaCita != null) {
                            widget.onNuevaCita(nuevaCita);
                          }
                        });
                      }
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.calendar_today,
                        size: 60,
                        color: Color.fromARGB(255, 17, 46, 88),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Agendar citas',
                        style: TextStyle(
                          color: Color.fromARGB(255, 17, 46, 88),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón Vacunación.
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 194, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black54,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FormularioCita(tipoCita: 'Vacunacion'),
                      ),
                    ).then((nuevaCita) {
                      if (nuevaCita != null) {
                        widget.onNuevaCita(nuevaCita);
                      }
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.medical_services,
                        size: 60,
                        color: Color.fromARGB(255, 17, 46, 88),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vacunación',
                        style: TextStyle(
                          color: Color.fromARGB(255, 17, 46, 88),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón Limpieza.
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 194, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black54,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FormularioCita(tipoCita: 'Limpieza'),
                      ),
                    ).then((nuevaCita) {
                      if (nuevaCita != null) {
                        widget.onNuevaCita(nuevaCita);
                      }
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.clean_hands,
                        size: 60,
                        color: Color.fromARGB(255, 17, 46, 88),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Limpieza',
                        style: TextStyle(
                          color: Color.fromARGB(255, 17, 46, 88),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón Peluquería.
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 160, 194, 214),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black54,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FormularioCita(tipoCita: 'Peluqueria'),
                      ),
                    ).then((nuevaCita) {
                      if (nuevaCita != null) {
                        widget.onNuevaCita(nuevaCita);
                      }
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.cut,
                        size: 60,
                        color: Color.fromARGB(255, 17, 46, 88),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Peluquería',
                        style: TextStyle(
                          color: Color.fromARGB(255, 17, 46, 88),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
    );
  }
}
