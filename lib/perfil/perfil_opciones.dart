import 'package:flutter/material.dart';
import 'package:proyecto/login.dart';
import 'package:permission_handler/permission_handler.dart';

class PerfilOpciones extends StatefulWidget {
  final String userName;

  const PerfilOpciones({Key? key, required this.userName}) : super(key: key);

  @override
  _PerfilOpcionesState createState() => _PerfilOpcionesState();
}

class _PerfilOpcionesState extends State<PerfilOpciones> {
  bool _notificaciones = false;
  bool _solicitandoPermiso = false;

  @override
  void initState() {
    super.initState();
    _verificarEstadoPermisos();
  }

  Future<void> _verificarEstadoPermisos() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificaciones = status.isGranted;
    });
  }

  Future<void> _manejarCambioNotificaciones(bool value) async {
    if (_solicitandoPermiso) return;

    setState(() {
      _solicitandoPermiso = true;
    });

    try {
      if (value) {
        // Solicitar permiso para activar notificaciones
        final status = await Permission.notification.request();

        if (status.isGranted) {
          setState(() {
            _notificaciones = true;
          });
          _mostrarMensaje(context, 'Notificaciones activadas');
        } else if (status.isPermanentlyDenied) {
          _mostrarDialogoConfiguracion(context);
          setState(() {
            _notificaciones = false;
          });
        } else {
          setState(() {
            _notificaciones = false;
          });
          _mostrarMensaje(context, 'Permiso denegado');
        }
      } else {
        // Revocar permiso al desactivar notificaciones
        final result = await Permission.notification.request();

        // Solo podemos revocar el permiso si actualmente está concedido
        if (result.isGranted) {
          // En Android no hay forma directa de revocar, pero podemos abrir configuración
          _mostrarDialogoRevocacion(context);
        }

        // Independientemente del resultado, desactivamos en la app
        setState(() {
          _notificaciones = false;
        });
        _mostrarMensaje(context, 'Notificaciones desactivadas');
      }
    } finally {
      setState(() {
        _solicitandoPermiso = false;
      });
    }
  }

  void _mostrarDialogoConfiguracion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permiso requerido'),
          content: Text(
            'Para activar notificaciones, por favor habilita los permisos en la configuración de la aplicación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Abrir Configuración'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoRevocacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Revocar permisos'),
          content: Text(
            'Para desactivar completamente las notificaciones, por favor deshabilita los permisos en la configuración de la aplicación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Abrir Configuración'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Opciones",
          style: TextStyle(
            color: const Color.fromARGB(255, 17, 46, 88),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 17, 46, 88)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 40),
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: const Color.fromARGB(255, 17, 46, 88),
                    child: Icon(Icons.person, size: 120, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.userName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.zero,
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
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 17, 46, 88),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              SizedBox(height: 40),

                              // Contenedor para el switch de notificaciones
                              Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Activar notificaciones",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 17, 46, 88),
                                      ),
                                    ),
                                    Switch(
                                      value: _notificaciones,
                                      onChanged:
                                          _solicitandoPermiso
                                              ? null
                                              : _manejarCambioNotificaciones,
                                      activeColor: Color.fromARGB(
                                        255,
                                        17,
                                        46,
                                        88,
                                      ),
                                      activeTrackColor: const Color.fromARGB(
                                        230,
                                        149,
                                        200,
                                        212,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 40),

                              // Botón para eliminar cuenta
                              ElevatedButton(
                                onPressed: () {
                                  _mostrarDialogoEliminarCuenta(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    17,
                                    46,
                                    88,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  "Eliminar Cuenta",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminarCuenta(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmación',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 17, 46, 88),
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: const Color.fromARGB(255, 17, 46, 88),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
