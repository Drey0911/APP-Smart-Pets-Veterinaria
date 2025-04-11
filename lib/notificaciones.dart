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

  Future<void> _mostrarNotificacion() async {
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
  }

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
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (notificaciones.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limpiarNotificaciones,
              tooltip: 'Limpiar todas',
            ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _mostrarNotificacion,
            child: const Text('Crear Notificación'),
          ),
          Expanded(
            child:
                notificaciones.isEmpty
                    ? const Center(child: Text('No hay notificaciones'))
                    : ListView.builder(
                      itemCount: notificaciones.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(notificaciones[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
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
