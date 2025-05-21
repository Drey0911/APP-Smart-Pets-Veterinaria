import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_model.dart';

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
    final notificacionesGuardadas =
        _prefs.getStringList('notificaciones') ?? [];
    setState(() {
      notificaciones = notificacionesGuardadas;
    });
    widget.onNotificacionesCambiadas(notificaciones.isNotEmpty);
  }

  Future<void> _guardarNotificaciones() async {
    await _prefs.setStringList('notificaciones', notificaciones);
    widget.onNotificacionesCambiadas(notificaciones.isNotEmpty);
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

  String _formatearFecha(int index) {
    try {
      final id = notificaciones[index].hashCode;
      final date = DateTime.fromMillisecondsSinceEpoch(id * 1000);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha no disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        final primaryColor =
            themeModel.isDarkMode
                ? Colors.white
                : const Color.fromARGB(255, 17, 46, 88);
        final backgroundColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(15, 47, 67, 1)
                : Colors.white;
        final cardColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(37, 78, 103, 1)
                : const Color(0xFFF5F5F5);
        final subtitleColor =
            themeModel.isDarkMode ? Colors.white70 : Colors.grey[600];

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              'Notificaciones',
              style: TextStyle(
                color: primaryColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor:
                themeModel.isDarkMode
                    ? Color.fromRGBO(15, 47, 67, 1)
                    : Colors.white,
            iconTheme: IconThemeData(color: primaryColor),
            actions: [
              if (notificaciones.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete_sweep, color: primaryColor),
                  onPressed: _limpiarNotificaciones,
                  tooltip: 'Limpiar todas',
                ),
            ],
          ),
          body: Column(
            children: [
              if (notificaciones.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ${notificaciones.length}',
                      style: TextStyle(color: primaryColor, fontSize: 14),
                    ),
                  ),
                ),
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
                                color:
                                    themeModel.isDarkMode
                                        ? Colors.white70
                                        : const Color(
                                          0xFF1E4B69,
                                        ).withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay notificaciones',
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      themeModel.isDarkMode
                                          ? Colors.white70
                                          : const Color(
                                            0xFF1E4B69,
                                          ).withOpacity(0.7),
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
                                tileColor: cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                title: Text(
                                  notificaciones[index],
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Recibida el ${_formatearFecha(index)}',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color:
                                        themeModel.isDarkMode
                                            ? Colors.red[300]
                                            : const Color.fromARGB(
                                              255,
                                              213,
                                              10,
                                              10,
                                            ),
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
      },
    );
  }
}
