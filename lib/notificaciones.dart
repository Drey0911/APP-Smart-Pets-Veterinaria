import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionesPage extends StatefulWidget {
  final Function(bool) onNotificacionesCambiadas;

  const NotificacionesPage({Key? key, required this.onNotificacionesCambiadas})
    : super(key: key);

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  List<String> notificaciones = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _cargarNotificaciones();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _cargarNotificaciones() async {
    _prefs = await SharedPreferences.getInstance();
    final notificacionesGuardadas = _prefs.getStringList('notificaciones');
    if (notificacionesGuardadas != null) {
      setState(() {
        notificaciones = notificacionesGuardadas;
      });
    }
    widget.onNotificacionesCambiadas(notificaciones.isNotEmpty);
  }

  Future<void> _guardarNotificaciones() async {
    await _prefs.setStringList('notificaciones', notificaciones);
    widget.onNotificacionesCambiadas(notificaciones.isNotEmpty);
  }

  //PARA PRUEBAS
  /*   Future<void> _mostrarNotificacion() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      0,
      'Nueva notificación',
      'Has recibido una notificación',
      platformChannelSpecifics,
    );

    final nuevaNotificacion =
        'Notificación ${DateTime.now().toString().substring(11, 19)}';

    setState(() {
      notificaciones.insert(0, nuevaNotificacion);
      _guardarNotificaciones();
    });
  } */

  Future<void> _eliminarNotificacion(int index) async {
    setState(() {
      notificaciones.removeAt(index);
      _guardarNotificaciones();
    });
  }

  Future<void> _limpiarNotificaciones() async {
    setState(() {
      notificaciones.clear();
      _guardarNotificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Color.fromARGB(255, 17, 46, 88), // Azul oscuro
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // Fondo blanco para la AppBar
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 17, 46, 88), // Íconos azules
        ),
        actions: [
          if (notificaciones.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limpiarNotificaciones,
              tooltip: 'Limpiar todas',
              color: const Color.fromARGB(255, 17, 46, 88), // Ícono azul
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                notificaciones.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 80,
                            color: const Color(0xFF1E4B69).withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay notificaciones',
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color(0xFF1E4B69).withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: notificaciones.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            tileColor: const Color(
                              0xFFF5F5F5,
                            ), // Fondo gris claro
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Bordes redondeados
                            ),
                            title: Text(
                              notificaciones[index],
                              style: const TextStyle(
                                color: Color.fromARGB(
                                  255,
                                  17,
                                  46,
                                  88,
                                ), // Texto azul oscuro
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromARGB(255, 213, 10, 10),
                              ),
                              onPressed: () => _eliminarNotificacion(index),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
