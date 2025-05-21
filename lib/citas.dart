import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

// ===========================================================================
// PANTALLA DE CITAS (MIS CITAS)
// ===========================================================================

class Citas extends StatefulWidget {
  final String uid;
  final GlobalKey<CitasState>? key;

  const Citas({this.key, required this.uid}) : super(key: key);

  @override
  CitasState createState() => CitasState();
}

class CitasState extends State<Citas> {
  final DatabaseReference _citasRef = FirebaseDatabase.instance.ref('citas');
  StreamSubscription<DatabaseEvent>? _citasSubscription;
  List<Map<String, dynamic>> _citas = [];

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  @override
  void dispose() {
    _citasSubscription?.cancel();
    super.dispose();
  }

  void _cargarCitas() {
    _citasSubscription = _citasRef
        .orderByChild('usuarioUid')
        .equalTo(widget.uid)
        .onValue
        .listen(
          (event) {
            try {
              final citasTemp = <Map<String, dynamic>>[];

              if (event.snapshot.exists) {
                final data = event.snapshot.value as Map<dynamic, dynamic>;

                data.forEach((key, value) {
                  final cita = Map<String, dynamic>.from(value as dynamic);

                  if (cita['estado'] != 'COMPLETADA') {
                    citasTemp.add({
                      'id': key.toString(),
                      'tipo': cita['tipo']?.toString() ?? 'Servicio',
                      'fecha': cita['fecha']?.toString() ?? '--/--/----',
                      'fechaTimestamp': cita['fechaTimestamp'] as int? ?? 0,
                      'profesionalUid':
                          cita['profesionalUid']?.toString() ?? '',
                      'profesionalNombre':
                          cita['profesionalNombre']?.toString() ??
                          'No asignado',
                      'hora': cita['hora']?.toString() ?? '--:--',
                      'mascota': {
                        'id': cita['mascotaId']?.toString() ?? '',
                        'nombre':
                            cita['mascotaNombre']?.toString() ?? 'Sin nombre',
                        'raza': cita['mascotaRaza']?.toString() ?? 'Sin raza',
                      },
                      'estado': cita['estado']?.toString() ?? 'PENDIENTE',
                    });
                  }
                });

                citasTemp.sort(
                  (a, b) => (a['fechaTimestamp'] as int).compareTo(
                    b['fechaTimestamp'] as int,
                  ),
                );
              }

              setState(() => _citas = citasTemp);
            } catch (e) {
              print('Error procesando citas: $e');
              setState(() => _citas = []);
            }
          },
          onError: (error) {
            print('Error al cargar citas: $error');
            setState(() => _citas = []);
          },
        );
  }

  // Método para agregar una cita (mantenido para compatibilidad)
  void addCita(Map<String, dynamic> nuevaCita, [String? uid]) {
    setState(() {
      _citas.add(nuevaCita);
    });
  }

  Future<void> _cancelarCita(String citaId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cancelar Cita',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 17, 46, 88),
            ),
          ),
          content: const Text(
            '¿Estás seguro de que deseas cancelar esta cita?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Color.fromARGB(255, 17, 46, 88),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _citasRef.child(citaId).remove();
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cancelar la cita: $e')),
                  );
                }
              },
              child: const Text(
                'Sí, cancelar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(30, 75, 105, 1),
              Color.fromRGBO(150, 193, 212, 1),
              Color.fromRGBO(150, 193, 212, 1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 80,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Citas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistorialCitas(uid: widget.uid),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.history,
                      color: Color.fromRGBO(30, 75, 105, 1),
                    ),
                    label: const Text(
                      'Historial',
                      style: TextStyle(color: Color.fromRGBO(30, 75, 105, 1)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child:
                    _citas.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 80,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : const Color(
                                          0xFF1E4B69,
                                        ).withOpacity(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tienes citas agendadas',
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : const Color(
                                            0xFF1E4B69,
                                          ).withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _citas.length,
                          itemBuilder: (context, index) {
                            final cita = _citas[index];

                            // Definición de colores e iconos según tipo de cita
                            final (
                              Color startColor,
                              Color endColor,
                              IconData icon,
                            ) = switch (cita['tipo']) {
                              'Vacunacion' => (
                                Colors.red.shade300,
                                Colors.red.shade700,
                                Icons.vaccines,
                              ),
                              'Limpieza' => (
                                Colors.amber.shade300,
                                Colors.amber.shade700,
                                Icons.cleaning_services,
                              ),
                              'Peluqueria' => (
                                Colors.purple.shade300,
                                Colors.purple.shade700,
                                Icons.cut,
                              ),
                              _ => (
                                Colors.blue.shade300,
                                Colors.blue.shade700,
                                Icons.medical_services,
                              ),
                            };

                            // Color según estado
                            final (
                              Color estadoColor,
                              String estadoText,
                            ) = switch (cita['estado']) {
                              'PENDIENTE' => (
                                themeModel.isDarkMode
                                    ? const Color(
                                      0xFFFFD580,
                                    ) // pastel orange (dark)
                                    : const Color.fromARGB(
                                      255,
                                      255,
                                      174,
                                      52,
                                    ), // pastel orange (light)
                                'Pendiente',
                              ),
                              'CONFIRMADA' => (
                                themeModel.isDarkMode
                                    ? const Color(
                                      0xFF90CAF9,
                                    ) // pastel blue (dark)
                                    : const Color.fromARGB(
                                      255,
                                      98,
                                      173,
                                      234,
                                    ), // pastel blue (light)
                                'Confirmada',
                              ),
                              'COMPLETADA' => (
                                themeModel.isDarkMode
                                    ? const Color(
                                      0xFFA5D6A7,
                                    ) // pastel green (dark)
                                    : const Color.fromARGB(
                                      255,
                                      57,
                                      151,
                                      60,
                                    ), // pastel green (light)
                                'Completada',
                              ),
                              'RECHAZADA' => (
                                themeModel.isDarkMode
                                    ? const Color(
                                      0xFFEF9A9A,
                                    ) // pastel red (dark)
                                    : const Color.fromARGB(
                                      255,
                                      142,
                                      48,
                                      58,
                                    ), // pastel red (light)
                                'Rechazada',
                              ),
                              _ => (
                                themeModel.isDarkMode
                                    ? const Color(
                                      0xFFB0BEC5,
                                    ) // pastel grey (dark)
                                    : const Color(
                                      0xFFCFD8DC,
                                    ), // pastel grey (light)
                                cita['estado'],
                              ),
                            };

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Color.fromRGBO(
                                            15,
                                            47,
                                            67,
                                            1,
                                          ).withOpacity(
                                            0.85,
                                          ) // gris oscuro semitransparente
                                          : Colors.white.withOpacity(
                                            0.95,
                                          ), // blanco semitransparente
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Icono con gradiente y borde sutil
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [startColor, endColor],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: startColor.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          icon,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Contenido de la cita
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Título con nombre de cita y hora
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    '${cita['tipo']}',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Theme.of(
                                                                    context,
                                                                  ).brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                    0.85,
                                                                  ) // Blanco en modo oscuro
                                                              : const Color.fromARGB(
                                                                255,
                                                                14,
                                                                53,
                                                                79,
                                                              ).withOpacity(
                                                                0.85,
                                                              ), // Azul en modo claro
                                                      height: 1.4,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                // Badge de estado
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: estadoColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    estadoText,
                                                    style: TextStyle(
                                                      color: estadoColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),

                                            // Línea divisoria decorativa
                                            Container(
                                              height: 1,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade200,
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),

                                            _buildDetailRow(
                                              Icons.calendar_today,
                                              'Fecha:',
                                              cita['fecha'],
                                            ),
                                            _buildDetailRow(
                                              Icons.access_time,
                                              'Hora:',
                                              cita['hora'],
                                            ),
                                            _buildDetailRow(
                                              Icons.pets,
                                              'Mascota:',
                                              '${cita['mascota']['nombre']} (${cita['mascota']['raza']})',
                                            ),
                                            _buildDetailRow(
                                              Icons.person,
                                              'Profesional:',
                                              cita['profesionalNombre'],
                                            ),

                                            const SizedBox(height: 8),

                                            // Barra de progreso decorativa
                                            Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    startColor.withOpacity(0.7),
                                                    endColor,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // Botón de eliminar más elegante
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.red[200]
                                                  : Colors.red.shade600,
                                        ),
                                        onPressed:
                                            () => _cancelarCita(cita['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para construir filas de información con iconos adaptado a modo oscuro
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70.withOpacity(0.70)
                    : const Color.fromARGB(255, 14, 53, 79).withOpacity(0.70),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70.withOpacity(0.70)
                          : const Color.fromARGB(
                            255,
                            8,
                            37,
                            56,
                          ).withOpacity(0.70),
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// FORMULARIO PARA SELECCIONAR EL TIPO DE CITA
// ===========================================================================

class FormularioTipoCita extends StatefulWidget {
  const FormularioTipoCita({Key? key}) : super(key: key);

  @override
  _FormularioTipoCitaState createState() => _FormularioTipoCitaState();
}

class _FormularioTipoCitaState extends State<FormularioTipoCita> {
  final List<String> _tipos = [
    'Control',
    'Consulta',
    'Desparasitacion',
    'Esterilizacion',
  ];
  String? _tipoSeleccionado;

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = _tipos[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tipo de Cita',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 109, 158, 187),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(150, 193, 212, 1),
              Color.fromRGBO(30, 75, 105, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Selecciona la cita que deseas agendar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: _tipos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: RadioListTile<String>(
                          title: Text(
                            _tipos[index],
                            style: const TextStyle(fontSize: 18),
                          ),
                          activeColor: Colors.blue,
                          value: _tipos[index],
                          groupValue: _tipoSeleccionado,
                          onChanged: (value) {
                            setState(() {
                              _tipoSeleccionado = value;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(170, 207, 231, 1),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, _tipoSeleccionado);
                    },
                    child: const Text(
                      'Continuar Agendando',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 45),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// FORMULARIO PARA AGENDAR UNA CITA (INGRESO DE DATOS)
// ===========================================================================

class FormularioCita extends StatefulWidget {
  final String? tipoCita;
  final Map<String, dynamic>? cita;
  final String uid;

  const FormularioCita({Key? key, this.tipoCita, this.cita, required this.uid})
    : super(key: key);

  @override
  _FormularioCitaState createState() => _FormularioCitaState();
}

class _FormularioCitaState extends State<FormularioCita> {
  final _formKey = GlobalKey<FormState>();
  late String _tipoCita;
  DateTime? _fechaSeleccionada;
  String? _doctorSeleccionado;
  String? _horaSeleccionada;
  Map<String, dynamic>? _mascotaSeleccionada;
  bool _guardando = false;

  List<Map<String, dynamic>> _profesionales = [];
  Map<String, List<String>> _horariosDisponibles = {};
  List<Map<String, dynamic>> _mascotasUsuario = [];

  // Referencias a la base de datos
  final DatabaseReference _profesionalesRef = FirebaseDatabase.instance.ref(
    'usuarios',
  );
  final DatabaseReference _mascotasRef = FirebaseDatabase.instance.ref(
    'mascotas',
  );
  StreamSubscription<DatabaseEvent>? _profesionalesSubscription;
  StreamSubscription<DatabaseEvent>? _mascotasSubscription;

  @override
  void initState() {
    super.initState();
    _tipoCita = widget.tipoCita ?? 'Control';
    _cargarProfesionalesEnTiempoReal();
    _cargarMascotasEnTiempoReal();
  }

  @override
  void dispose() {
    _profesionalesSubscription?.cancel();
    _mascotasSubscription?.cancel();
    super.dispose();
  }

  void _cargarProfesionalesEnTiempoReal() {
    _profesionalesSubscription = _profesionalesRef
        .orderByChild('rol')
        .equalTo('Profesional')
        .onValue
        .listen(
          (event) {
            if (event.snapshot.exists) {
              final data = event.snapshot.value as Map<dynamic, dynamic>;
              final profesionalesTemp = <Map<String, dynamic>>[];

              data.forEach((key, value) {
                final profesional = value as Map<dynamic, dynamic>;
                profesionalesTemp.add({
                  'uid': key,
                  'nombre': profesional['nombre'] ?? 'Sin nombre',
                  'horario1': profesional['horario1'] ?? '',
                  'horario2': profesional['horario2'] ?? '',
                  'horario3': profesional['horario3'] ?? '',
                  'horario4': profesional['horario4'] ?? '',
                });
              });

              setState(() {
                _profesionales = profesionalesTemp;
                if (_profesionales.isNotEmpty) {
                  _doctorSeleccionado ??= _profesionales[0]['uid'];
                  _actualizarHorariosDisponibles(
                    _profesionales.firstWhere(
                      (p) => p['uid'] == _doctorSeleccionado,
                      orElse: () => _profesionales[0],
                    ),
                  );
                }
              });
            }
          },
          onError: (error) {
            print('Error al cargar profesionales: $error');
          },
        );
  }

  void _cargarMascotasEnTiempoReal() {
    _mascotasSubscription = _mascotasRef
        .orderByChild('dueño')
        .equalTo(widget.uid)
        .onValue
        .listen(
          (event) {
            if (event.snapshot.exists) {
              final data = event.snapshot.value as Map<dynamic, dynamic>;
              final mascotasTemp = <Map<String, dynamic>>[];

              data.forEach((key, value) {
                final mascota = value as Map<dynamic, dynamic>;
                mascotasTemp.add({
                  'id': key,
                  'nombre': mascota['nombre'] ?? 'Sin nombre',
                  'raza': mascota['raza'] ?? 'Sin raza',
                  'dueño': mascota['dueño'],
                });
              });

              setState(() {
                _mascotasUsuario = mascotasTemp;
                if (_mascotasUsuario.isNotEmpty) {
                  _mascotaSeleccionada ??= _mascotasUsuario[0];
                }
              });
            }
          },
          onError: (error) {
            print('Error al cargar mascotas: $error');
          },
        );
  }

  void _actualizarHorariosDisponibles(Map<String, dynamic> profesional) {
    List<String> horarios = [];

    for (int i = 1; i <= 4; i++) {
      String horarioKey = 'horario$i';
      String horario = profesional[horarioKey]?.toString() ?? '';

      if (horario.isNotEmpty && !horario.contains('OCUPADO')) {
        horarios.add(horario);
      }
    }

    setState(() {
      _horariosDisponibles[profesional['uid']] = horarios;
      if (horarios.isNotEmpty) {
        _horaSeleccionada = horarios[0];
      } else {
        _horaSeleccionada = null;
      }
    });
  }

  Future<void> _seleccionarFecha() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeModel>(
          builder: (context, themeModel, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary:
                      themeModel.isDarkMode
                          ? Color.fromRGBO(121, 167, 199, 1)
                          : const Color.fromRGBO(30, 75, 105, 1),
                  onPrimary: Colors.white,
                  onSurface:
                      themeModel.isDarkMode ? Colors.white : Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        themeModel.isDarkMode
                            ? Color.fromRGBO(121, 167, 199, 1)
                            : const Color.fromRGBO(30, 75, 105, 1),
                  ),
                ),
              ),
              child: AlertDialog(
                content: SizedBox(
                  width: double.maxFinite,
                  child: CalendarDatePicker(
                    initialDate: _fechaSeleccionada ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (DateTime value) {
                      setState(() {
                        _fechaSeleccionada = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _guardarCita() async {
    if (_guardando) return;

    if (!_formKey.currentState!.validate() ||
        _fechaSeleccionada == null ||
        _doctorSeleccionado == null ||
        _horaSeleccionada == null ||
        _mascotaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      String fecha =
          '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}';

      // Obtener nombre del profesional seleccionado
      String nombreProfesional =
          _profesionales.firstWhere(
            (p) => p['uid'] == _doctorSeleccionado,
          )['nombre'];

      // Obtener nombre del usuario actual
      DataSnapshot usuarioSnapshot =
          await _profesionalesRef.child(widget.uid).get();
      String nombreUsuario =
          usuarioSnapshot.child('nombre').value?.toString() ?? 'Usuario';

      Map<String, dynamic> nuevaCita = {
        'tipo': _tipoCita,
        'fecha': fecha,
        'fechaTimestamp': _fechaSeleccionada!.millisecondsSinceEpoch,
        'profesionalUid': _doctorSeleccionado,
        'profesionalNombre': nombreProfesional,
        'hora': _horaSeleccionada,
        'mascotaId': _mascotaSeleccionada!['id'],
        'mascotaNombre': _mascotaSeleccionada!['nombre'],
        'mascotaRaza': _mascotaSeleccionada!['raza'],
        'usuarioUid': widget.uid,
        'usuarioNombre': nombreUsuario,
        'estado': 'PENDIENTE',
        'fechaCreacion': ServerValue.timestamp,
      };

      final ref = FirebaseDatabase.instance.ref('citas').push();
      await ref.set(nuevaCita);
      nuevaCita['id'] = ref.key;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cita agendada con éxito para el $fecha a las $_horaSeleccionada',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await showDialog(
        context: context,
        builder:
            (context) => Consumer<ThemeModel>(
              builder: (context, themeModel, child) {
                return AlertDialog(
                  backgroundColor:
                      themeModel.isDarkMode
                          ? Color.fromRGBO(15, 47, 67, 1)
                          : Colors.white,
                  title: Text(
                    'Cita Agendada',
                    style: TextStyle(
                      color:
                          themeModel.isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E4B69),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Tu cita se encuentra pendiente de confirmación por el profesional, revisa la agenda en la campanita de notificaciones.',
                    style: TextStyle(
                      color:
                          themeModel.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Aceptar',
                        style: TextStyle(
                          color:
                              themeModel.isDarkMode
                                  ? Color.fromRGBO(121, 167, 199, 1)
                                  : const Color(0xFF1E4B69),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      );

      await _mostrarNotificacionCita(_tipoCita, fecha, _horaSeleccionada!);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar la cita: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Future<void> _mostrarNotificacionCita(
    String tipo,
    String fecha,
    String hora,
  ) async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'citas_channel_id',
            'Citas',
            channelDescription: 'Notificaciones de citas agendadas',
            importance: Importance.high,
            priority: Priority.high,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Cita Agendada',
        'Cita de $tipo para el $fecha a las $hora',
        notificationDetails,
      );

      final prefs = await SharedPreferences.getInstance();
      List<String> notificaciones = prefs.getStringList('notificaciones') ?? [];
      notificaciones.insert(
        0,
        'Cita de $tipo agendada para el $fecha a las $hora',
      );
      await prefs.setStringList('notificaciones', notificaciones);
    } catch (e) {
      print('Error al mostrar notificación: $e');
    }
  }

  Icon _getIcon(ThemeModel themeModel) {
    final iconColor =
        themeModel.isDarkMode
            ? Color.fromRGBO(121, 167, 199, 1)
            : const Color.fromRGBO(30, 75, 105, 1);

    switch (_tipoCita) {
      case 'Peluqueria':
        return Icon(Icons.content_cut, size: 40, color: iconColor);
      case 'Vacunacion':
        return Icon(Icons.healing, size: 40, color: iconColor);
      case 'Limpieza':
        return Icon(Icons.cleaning_services, size: 40, color: iconColor);
      default:
        return Icon(Icons.medical_services, size: 40, color: iconColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        final backgroundColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(15, 47, 67, 1)
                : Colors.white;
        final buttonColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(121, 167, 199, 1)
                : const Color.fromRGBO(30, 75, 105, 1);
        final cancelButtonColor =
            themeModel.isDarkMode
                ? Colors.grey[700]
                : const Color.fromARGB(200, 160, 160, 160);
        final textColor = themeModel.isDarkMode ? Colors.white : Colors.black;
        final secondaryTextColor =
            themeModel.isDarkMode ? Colors.grey[300] : Colors.grey[700];
        final borderColor =
            themeModel.isDarkMode ? Colors.grey[700]! : Colors.black;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(150, 193, 212, 1),
                                  Color.fromRGBO(30, 75, 105, 1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Center(
                                  child: Text(
                                    widget.cita == null
                                        ? 'Agendar Cita'
                                        : 'Editar Cita',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey.shade200,
                                  child: _getIcon(themeModel),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _tipoCita,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: _seleccionarFecha,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              themeModel.isDarkMode
                                  ? Color.fromRGBO(15, 47, 67, 1)
                                  : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: borderColor),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _fechaSeleccionada == null
                              ? 'Seleccionar Fecha'
                              : 'Fecha: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dropdown para profesionales con horarios
                      DropdownButtonFormField<String>(
                        value: _doctorSeleccionado,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: secondaryTextColor,
                          ),
                          labelText: 'Selecciona el profesional',
                          labelStyle: TextStyle(color: secondaryTextColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          filled: true,
                          fillColor:
                              themeModel.isDarkMode
                                  ? Color.fromRGBO(15, 47, 67, 1)
                                  : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        dropdownColor:
                            themeModel.isDarkMode
                                ? Color.fromRGBO(15, 74, 110, 1)
                                : Colors.white,
                        style: TextStyle(color: textColor),
                        items:
                            _profesionales.map((profesional) {
                              return DropdownMenuItem<String>(
                                value: profesional['uid'],
                                child: Text(
                                  profesional['nombre'],
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }).toList(),
                        onChanged: (nuevoProfesionalUid) {
                          if (nuevoProfesionalUid != null) {
                            final profesional = _profesionales.firstWhere(
                              (p) => p['uid'] == nuevoProfesionalUid,
                            );
                            setState(() {
                              _doctorSeleccionado = nuevoProfesionalUid;
                              _actualizarHorariosDisponibles(profesional);
                            });
                          }
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Selecciona un profesional'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Dropdown para horarios disponibles del profesional
                      DropdownButtonFormField<String>(
                        value: _horaSeleccionada,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: secondaryTextColor,
                          ),
                          labelText: 'Selecciona la hora',
                          labelStyle: TextStyle(color: secondaryTextColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          filled: true,
                          fillColor:
                              themeModel.isDarkMode
                                  ? Color.fromRGBO(15, 47, 67, 1)
                                  : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        dropdownColor:
                            themeModel.isDarkMode
                                ? Color.fromRGBO(15, 74, 110, 1)
                                : Colors.white,
                        style: TextStyle(color: textColor),
                        items:
                            (_doctorSeleccionado != null &&
                                    _horariosDisponibles.containsKey(
                                      _doctorSeleccionado,
                                    ))
                                ? _horariosDisponibles[_doctorSeleccionado]!
                                    .map(
                                      (hora) => DropdownMenuItem<String>(
                                        value: hora,
                                        child: Text(
                                          hora,
                                          style: TextStyle(color: textColor),
                                        ),
                                      ),
                                    )
                                    .toList()
                                : [],
                        onChanged: (nuevaHora) {
                          setState(() {
                            _horaSeleccionada = nuevaHora;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Selecciona una hora' : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _mascotaSeleccionada,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.pets,
                            color: secondaryTextColor,
                          ),
                          labelText: 'Selecciona la mascota',
                          labelStyle: TextStyle(color: secondaryTextColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          filled: true,
                          fillColor:
                              themeModel.isDarkMode
                                  ? Color.fromRGBO(15, 47, 67, 1)
                                  : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        dropdownColor:
                            themeModel.isDarkMode
                                ? Color.fromRGBO(15, 74, 110, 1)
                                : Colors.white,
                        style: TextStyle(color: textColor),
                        items:
                            _mascotasUsuario.map((mascota) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: mascota,
                                child: Text(
                                  '${mascota['nombre']} - ${mascota['raza']}',
                                  style: TextStyle(color: textColor),
                                ),
                              );
                            }).toList(),
                        onChanged: (nuevaMascota) {
                          setState(() {
                            _mascotaSeleccionada = nuevaMascota;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Selecciona una mascota' : null,
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _guardando ? null : _guardarCita,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _guardando
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Agendar Cita',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: cancelButtonColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed:
                              _guardando ? null : () => Navigator.pop(context),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
// ===========================================================================
// PANTALLA HISTÓRICO DE CITAS (CITAS PASADAS)
// ===========================================================================

class HistorialCitas extends StatefulWidget {
  final String uid;
  const HistorialCitas({Key? key, required this.uid}) : super(key: key);

  @override
  _HistorialCitasState createState() => _HistorialCitasState();
}

class _HistorialCitasState extends State<HistorialCitas> {
  final DatabaseReference _citasRef = FirebaseDatabase.instance.ref('citas');
  StreamSubscription<DatabaseEvent>? _citasSubscription;
  List<Map<String, dynamic>> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  @override
  void dispose() {
    _citasSubscription?.cancel();
    super.dispose();
  }

  void _cargarHistorial() {
    _citasSubscription = _citasRef
        .orderByChild('usuarioUid')
        .equalTo(widget.uid)
        .onValue
        .listen(
          (event) {
            if (event.snapshot.exists) {
              final data = event.snapshot.value as Map<dynamic, dynamic>;
              final historialTemp = <Map<String, dynamic>>[];

              data.forEach((key, value) {
                final cita = value as Map<dynamic, dynamic>;
                if (cita['estado'] == 'COMPLETADA') {
                  historialTemp.add({
                    'id': key,
                    'tipo': cita['tipo'],
                    'fecha': cita['fecha'],
                    'profesionalUid': cita['profesionalUid'],
                    'profesionalNombre': cita['profesionalNombre'],
                    'hora': cita['hora'],
                    'mascota': {
                      'id': cita['mascotaId'],
                      'nombre': cita['mascotaNombre'],
                      'raza': cita['mascotaRaza'],
                    },
                    'estado': cita['estado'],
                  });
                }
              });

              historialTemp.sort(
                (a, b) => (b['fechaTimestamp'] as int).compareTo(
                  a['fechaTimestamp'] as int,
                ),
              );

              setState(() {
                _historial = historialTemp;
              });
            } else {
              setState(() {
                _historial = [];
              });
            }
          },
          onError: (error) {
            print('Error al cargar historial: $error');
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, child) {
        final backgroundColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(15, 47, 67, 1)
                : Colors.white;
        final appBarColor =
            themeModel.isDarkMode
                ? Color.fromRGBO(15, 74, 110, 1)
                : const Color(0xFF1E4B69);
        final textColor = themeModel.isDarkMode ? Colors.white : Colors.black;
        final secondaryTextColor =
            themeModel.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Historial de Citas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            backgroundColor: appBarColor,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundColor, backgroundColor],
              ),
            ),
            child:
                _historial.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 80,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF1E4B69),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No hay citas completadas en tu historial',
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tus citas completadas aparecerán aquí',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _historial.length,
                      itemBuilder: (context, index) {
                        final cita = _historial[index];

                        // Definición de colores e iconos según tipo de cita
                        final (
                          Color startColor,
                          Color endColor,
                          IconData icon,
                        ) = switch (cita['tipo']) {
                          'Vacunacion' => (
                            Colors.red.shade300,
                            Colors.red.shade700,
                            Icons.vaccines,
                          ),
                          'Limpieza' => (
                            Colors.amber.shade300,
                            Colors.amber.shade700,
                            Icons.cleaning_services,
                          ),
                          'Peluqueria' => (
                            Colors.purple.shade300,
                            Colors.purple.shade700,
                            Icons.cut,
                          ),
                          _ => (
                            Colors.blue.shade300,
                            Colors.blue.shade700,
                            Icons.medical_services,
                          ),
                        };

                        return Card(
                          elevation: themeModel.isDarkMode ? 4 : 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Color.fromRGBO(
                                        15,
                                        47,
                                        67,
                                        1,
                                      ).withOpacity(
                                        0.85,
                                      ) // gris oscuro semitransparente
                                      : Colors.white.withOpacity(
                                        0.95,
                                      ), // blanco semitransparente
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icono con gradiente y borde sutil
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [startColor, endColor],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: startColor.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      icon,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Contenido de la cita
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Título con nombre de cita y hora
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${cita['tipo']}',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      themeModel.isDarkMode
                                                          ? Colors.white
                                                          : Color(0xFF1E3A5F),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Badge de estado (siempre completada en historial)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Completada',
                                                style: TextStyle(
                                                  color:
                                                      themeModel.isDarkMode
                                                          ? const Color(
                                                            0xFFA5D6A7,
                                                          ) // pastel green (dark)
                                                          : Colors
                                                              .green
                                                              .shade700,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        // Línea divisoria decorativa
                                        Container(
                                          height: 1,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                themeModel.isDarkMode
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade200,
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),

                                        _buildDetailRow(
                                          Icons.calendar_today,
                                          'Fecha:',
                                          cita['fecha'],
                                          themeModel,
                                        ),
                                        _buildDetailRow(
                                          Icons.access_time,
                                          'Hora:',
                                          cita['hora'],
                                          themeModel,
                                        ),
                                        _buildDetailRow(
                                          Icons.pets,
                                          'Mascota:',
                                          '${cita['mascota']['nombre']} (${cita['mascota']['raza']})',
                                          themeModel,
                                        ),
                                        _buildDetailRow(
                                          Icons.person,
                                          'Profesional:',
                                          cita['profesionalNombre'],
                                          themeModel,
                                        ),

                                        const SizedBox(height: 8),

                                        // Barra de progreso decorativa
                                        Container(
                                          height: 3,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                startColor.withOpacity(0.7),
                                                endColor,
                                              ],
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
                      },
                    ),
          ),
        );
      },
    );
  }

  // Método auxiliar para construir filas de información con iconos
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeModel themeModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color:
                themeModel.isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color:
                      themeModel.isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
