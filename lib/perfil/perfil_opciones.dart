import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proyecto/theme_model.dart';

class PerfilOpciones extends StatefulWidget {
  final String uid;
  final String userName;

  const PerfilOpciones({Key? key, required this.userName, required this.uid})
    : super(key: key);

  @override
  _PerfilOpcionesState createState() => _PerfilOpcionesState();
}

class _PerfilOpcionesState extends State<PerfilOpciones> {
  bool _notificaciones = false;
  bool _solicitandoPermiso = false;
  bool _cargandoTema = true;
  late DatabaseReference _temaRef;

  @override
  void initState() {
    super.initState();
    _verificarEstadoPermisos();
    _configurarFirebase();
  }

  void _configurarFirebase() {
    _temaRef = FirebaseDatabase.instance.ref('usuarios/${widget.uid}/tema');

    // Escuchar cambios en tiempo real
    _temaRef.onValue.listen(
      (event) {
        if (mounted) {
          final tema = event.snapshot.value as String? ?? 'claro';
          final themeModel = Provider.of<ThemeModel>(context, listen: false);
          themeModel.setDarkMode(tema == 'oscuro');

          setState(() {
            _cargandoTema = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _cargandoTema = false;
          });
        }
        print("Error al leer tema: $error");
      },
    );
  }

  Future<void> _actualizarTemaFirebase(bool activarOscuro) async {
    try {
      await _temaRef.set(activarOscuro ? 'oscuro' : 'claro');
    } catch (e) {
      print("Error al actualizar tema: $e");
      _mostrarMensaje(context, 'Error al actualizar el tema');
    }
  }

  Future<void> _verificarEstadoPermisos() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _notificaciones = status.isGranted;
      });
    }
  }

  Future<void> _manejarCambioNotificaciones(bool value) async {
    if (_solicitandoPermiso) return;

    setState(() {
      _solicitandoPermiso = true;
    });

    try {
      if (value) {
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
        final result = await Permission.notification.request();

        if (result.isGranted) {
          _mostrarDialogoRevocacion(context);
        }

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
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor:
                themeModel.isDarkMode
                    ? Color.fromRGBO(30, 75, 105, 1)
                    : Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Opciones",
              style: TextStyle(
                color:
                    themeModel.isDarkMode
                        ? Colors.white
                        : const Color.fromARGB(255, 17, 46, 88),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color:
                    themeModel.isDarkMode
                        ? Colors.white
                        : const Color.fromARGB(255, 17, 46, 88),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  color:
                      themeModel.isDarkMode
                          ? Color.fromRGBO(15, 47, 67, 1)
                          : Colors.white,
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      CircleAvatar(
                        radius: 70,
                        backgroundColor:
                            themeModel.isDarkMode
                                ? Color.fromRGBO(140, 189, 210, 1)
                                : const Color.fromARGB(255, 17, 46, 88),
                        child: Icon(
                          Icons.person,
                          size: 120,
                          color:
                              themeModel.isDarkMode
                                  ? Color.fromRGBO(15, 47, 67, 1)
                                  : Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              themeModel.isDarkMode
                                  ? Colors.white70
                                  : Color.fromRGBO(15, 47, 67, 1),
                        ),
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
                                color:
                                    themeModel.isDarkMode
                                        ? Colors.black
                                        : Color.fromARGB(255, 17, 46, 88),
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
                                  _buildSwitchContainer(
                                    context,
                                    themeModel,
                                    "Modo oscuro",
                                    _cargandoTema
                                        ? null
                                        : themeModel.isDarkMode,
                                    (value) {
                                      _actualizarTemaFirebase(value);
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  _buildSwitchContainer(
                                    context,
                                    themeModel,
                                    "Activar notificaciones",
                                    _notificaciones,
                                    _solicitandoPermiso
                                        ? null
                                        : _manejarCambioNotificaciones,
                                  ),
                                  SizedBox(height: 40),
                                  _buildDeleteButton(context, themeModel),
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
      },
    );
  }

  Widget _buildSwitchContainer(
    BuildContext context,
    ThemeModel themeModel,
    String title,
    bool? value,
    Function(bool)? onChanged,
  ) {
    final isDisabled = value == null || onChanged == null;
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color:
              themeModel.isDarkMode
                  ? Color.fromRGBO(15, 47, 67, 1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border:
              isDisabled
                  ? Border.all(
                    color:
                        themeModel.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                    width: 2,
                  )
                  : null,
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDisabled
                        ? Colors.grey
                        : (themeModel.isDarkMode
                            ? Colors.white
                            : Color.fromARGB(255, 30, 75, 105)),
              ),
            ),
            if (value == null)
              CircularProgressIndicator()
            else
              Switch(
                value: value,
                onChanged:
                    isDisabled ? null : onChanged as void Function(bool)?,
                activeColor: Color.fromARGB(255, 17, 46, 88),
                activeTrackColor: const Color.fromARGB(230, 149, 200, 212),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade300,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, ThemeModel themeModel) {
    return ElevatedButton(
      onPressed: () => _mostrarDialogoEliminarCuenta(context, themeModel),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 198, 35, 24),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        "Eliminar Cuenta",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _mostrarDialogoEliminarCuenta(
    BuildContext context,
    ThemeModel themeModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              backgroundColor:
                  themeModel.isDarkMode
                      ? Color.fromRGBO(30, 75, 105, 1)
                      : Colors.white,
            ),
          ),
          child: AlertDialog(
            title: Text(
              'Confirmación',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    themeModel.isDarkMode
                        ? Colors.white
                        : const Color.fromARGB(255, 17, 46, 88),
              ),
            ),
            content: Text(
              '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
              style: TextStyle(
                color: themeModel.isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 16,
              ),
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
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color:
                        themeModel.isDarkMode
                            ? const Color.fromRGBO(140, 189, 210, 1)
                            : const Color.fromARGB(255, 17, 46, 88),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
