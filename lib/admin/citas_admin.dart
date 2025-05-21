import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

// ===========================================================================
// PANTALLA DE CITAS (ADMIN - TODAS LAS CITAS)
// ===========================================================================

class CitasAdmin extends StatefulWidget {
  final String uid;
  final GlobalKey<CitasAdminState>? key;

  const CitasAdmin({this.key, required this.uid}) : super(key: key);

  @override
  CitasAdminState createState() => CitasAdminState();
}

class CitasAdminState extends State<CitasAdmin> {
  final DatabaseReference _citasRef = FirebaseDatabase.instance.ref('citas');
  final DatabaseReference _usuariosRef = FirebaseDatabase.instance.ref(
    'usuarios',
  );
  StreamSubscription<DatabaseEvent>? _citasSubscription;
  List<Map<String, dynamic>> _citas = [];
  String _filtroEstado = 'TODAS'; // Filtro para los estados

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
    _citasSubscription = _citasRef.onValue.listen(
      (event) {
        try {
          final citasTemp = <Map<String, dynamic>>[];

          if (event.snapshot.exists) {
            final data = event.snapshot.value as Map<dynamic, dynamic>;

            data.forEach((key, value) {
              final cita = Map<String, dynamic>.from(value as dynamic);

              // Solo agregamos si coincide con el filtro o si es "TODAS"
              if (_filtroEstado == 'TODAS' || cita['estado'] == _filtroEstado) {
                citasTemp.add({
                  'id': key.toString(),
                  'tipo': cita['tipo']?.toString() ?? 'Servicio',
                  'fecha': cita['fecha']?.toString() ?? '--/--/----',
                  'fechaTimestamp': cita['fechaTimestamp'] as int? ?? 0,
                  'profesionalUid': cita['profesionalUid']?.toString() ?? '',
                  'profesionalNombre':
                      cita['profesionalNombre']?.toString() ?? 'No asignado',
                  'hora': cita['hora']?.toString() ?? '--:--',
                  'usuarioNombre':
                      cita['usuarioNombre']?.toString() ?? 'Sin nombre',
                  'mascota': {
                    'id': cita['mascotaId']?.toString() ?? '',
                    'nombre': cita['mascotaNombre']?.toString() ?? 'Sin nombre',
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

  Future<void> _actualizarEstadoCita(String citaId, String nuevoEstado) async {
    try {
      await _citasRef.child(citaId).update({'estado': nuevoEstado});

      // Obtener los datos de la cita para actualizar el horario del profesional
      final citaSnapshot = await _citasRef.child(citaId).get();
      if (citaSnapshot.exists) {
        final citaData = citaSnapshot.value as Map<dynamic, dynamic>;
        final profesionalUid = citaData['profesionalUid']?.toString();
        final horaCita = citaData['hora']?.toString();

        if (profesionalUid != null && horaCita != null) {
          await _actualizarHorarioProfesional(
            profesionalUid,
            horaCita,
            nuevoEstado,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la cita: $e')),
      );
    }
  }

  Future<void> _actualizarHorarioProfesional(
    String profesionalUid,
    String horaCita,
    String nuevoEstado,
  ) async {
    try {
      final profesionalSnapshot =
          await _usuariosRef.child(profesionalUid).get();

      if (profesionalSnapshot.exists) {
        final profesionalData =
            profesionalSnapshot.value as Map<dynamic, dynamic>;

        if (profesionalData['rol']?.toString() == 'Profesional') {
          // Buscar en qué horario coincide la hora de la cita
          for (int i = 1; i <= 4; i++) {
            final horarioKey = 'horario$i';
            final horarioActual = profesionalData[horarioKey]?.toString() ?? '';

            // Verificar si la hora coincide (ignorando "OCUPADO" si ya está)
            final horarioLimpio = horarioActual.replaceAll(' OCUPADO', '');
            if (horarioLimpio == horaCita) {
              // Actualizar el horario según el nuevo estado
              String nuevoHorario = horaCita;

              if (nuevoEstado == 'CONFIRMADA') {
                nuevoHorario = '$horaCita OCUPADO';
              }
              // Si es COMPLETADA, dejamos solo la hora sin "OCUPADO"

              await _usuariosRef.child(profesionalUid).update({
                horarioKey: nuevoHorario,
              });

              break;
            }
          }
        }
      }
    } catch (e) {
      print('Error al actualizar horario del profesional: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar horario del profesional: $e'),
        ),
      );
    }
  }

  Future<void> _mostrarDialogoCambioEstado(
    String citaId,
    String estadoActual,
  ) async {
    String? nuevoEstado;

    if (estadoActual == 'PENDIENTE') {
      nuevoEstado = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Cambiar estado de la cita',
              style: TextStyle(
                color: Color(0xFF1E4B69), // azul oscuro
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Seleccione el nuevo estado de la cita actual:',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'CONFIRMADA'),
                child: const Text(
                  'Confirmar Cita',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'RECHAZADA'),
                child: const Text(
                  'Rechazar Cita',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Color(0xFF1E4B69), // azul oscuro
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else if (estadoActual == 'CONFIRMADA') {
      nuevoEstado = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Cambiar estado de la cita',
              style: TextStyle(
                color: Color(0xFF1E4B69), // azul oscuro
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text('¿Marcar como completada?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'COMPLETADA'),
                child: const Text(
                  'Completar',
                  style: TextStyle(
                    color: Colors.green, // azul oscuro
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Color(0xFF1E4B69), // azul oscuro
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    if (nuevoEstado != null && nuevoEstado != estadoActual) {
      await _actualizarEstadoCita(citaId, nuevoEstado);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Citas Agendadas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _filtroEstado,
                    dropdownColor: const Color.fromRGBO(30, 75, 105, 1),
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    style: const TextStyle(color: Colors.white),
                    underline: Container(height: 0),
                    items:
                        [
                          'TODAS',
                          'PENDIENTE',
                          'CONFIRMADA',
                          'COMPLETADA',
                          'RECHAZADA',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _filtroEstado = newValue!;
                        _cargarCitas();
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
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
                                color: const Color(0xFF1E4B69).withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No hay citas disponibles',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1E4B69),
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
                              'PENDIENTE' => (Colors.orange, 'Pendiente'),
                              'CONFIRMADA' => (Colors.blue, 'Confirmada'),
                              'COMPLETADA' => (Colors.green, 'Completada'),
                              'RECHAZADA' => (Colors.red, 'Rechazada'),
                              _ => (Colors.grey, cita['estado']),
                            };

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.grey.shade50],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Icono con gradiente
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
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        '${cita['tipo']}',
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                            0xFF1E3A5F,
                                                          ),
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
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
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Línea divisoria
                                      Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(
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
                                        Icons.person,
                                        'Cliente:',
                                        cita['usuarioNombre'],
                                      ),
                                      _buildDetailRow(
                                        Icons.pets,
                                        'Mascota:',
                                        '${cita['mascota']['nombre']} (${cita['mascota']['raza']})',
                                      ),
                                      _buildDetailRow(
                                        Icons.person_outline,
                                        'Profesional:',
                                        cita['profesionalNombre'],
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
                                      const SizedBox(height: 8),
                                      // Botones de acción según estado
                                      if (cita['estado'] == 'PENDIENTE' ||
                                          cita['estado'] == 'CONFIRMADA')
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      _mostrarDialogoCambioEstado(
                                                        cita['id'],
                                                        cita['estado'],
                                                      ),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 22,
                                                      vertical: 10,
                                                    ),
                                                backgroundColor: estadoColor
                                                    .withOpacity(0.15),
                                                foregroundColor: estadoColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    cita['estado'] ==
                                                            'PENDIENTE'
                                                        ? Icons.sync_alt
                                                        : Icons.check_circle,
                                                    size: 18,
                                                    color: estadoColor,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    cita['estado'] ==
                                                            'PENDIENTE'
                                                        ? 'Cambiar estado'
                                                        : 'Marcar completada',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: estadoColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
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
// FORMULARIO PARA AGENDAR UNA CITA (INGRESO DE DATOS) - Versión Administrador
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
  Map<String, dynamic>? _usuarioSeleccionado;
  bool _guardando = false;

  List<Map<String, dynamic>> _profesionales = [];
  List<Map<String, dynamic>> _clientes = [];
  Map<String, List<String>> _horariosDisponibles = {};
  List<Map<String, dynamic>> _mascotasUsuario = [];

  // Referencias a la base de datos
  final DatabaseReference _usuariosRef = FirebaseDatabase.instance.ref(
    'usuarios',
  );
  final DatabaseReference _mascotasRef = FirebaseDatabase.instance.ref(
    'mascotas',
  );
  StreamSubscription<DatabaseEvent>? _profesionalesSubscription;
  StreamSubscription<DatabaseEvent>? _clientesSubscription;
  StreamSubscription<DatabaseEvent>? _mascotasSubscription;

  @override
  void initState() {
    super.initState();
    _tipoCita = widget.tipoCita ?? 'Control';
    _cargarProfesionalesEnTiempoReal();
    _cargarClientesEnTiempoReal();
  }

  @override
  void dispose() {
    _profesionalesSubscription?.cancel();
    _clientesSubscription?.cancel();
    _mascotasSubscription?.cancel();
    super.dispose();
  }

  void _cargarProfesionalesEnTiempoReal() {
    _profesionalesSubscription = _usuariosRef
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

  void _cargarClientesEnTiempoReal() {
    _clientesSubscription = _usuariosRef
        .orderByChild('rol')
        .equalTo('Cliente')
        .onValue
        .listen(
          (event) {
            if (event.snapshot.exists) {
              final data = event.snapshot.value as Map<dynamic, dynamic>;
              final clientesTemp = <Map<String, dynamic>>[];

              data.forEach((key, value) {
                final cliente = value as Map<dynamic, dynamic>;
                clientesTemp.add({
                  'uid': key,
                  'nombre': cliente['nombre'] ?? 'Sin nombre',
                  'email': cliente['email'] ?? '',
                });
              });

              setState(() {
                _clientes = clientesTemp;
              });
            }
          },
          onError: (error) {
            print('Error al cargar clientes: $error');
          },
        );
  }

  void _cargarMascotasEnTiempoReal(String usuarioUid) {
    _mascotasSubscription?.cancel(); // Cancelar suscripción anterior

    _mascotasSubscription = _mascotasRef
        .orderByChild('dueño')
        .equalTo(usuarioUid)
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
                  _mascotaSeleccionada = _mascotasUsuario[0];
                } else {
                  _mascotaSeleccionada = null;
                }
              });
            } else {
              setState(() {
                _mascotasUsuario = [];
                _mascotaSeleccionada = null;
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 24, 54, 92),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 24, 54, 92),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _guardarCita() async {
    if (_guardando) return;

    if (!_formKey.currentState!.validate() ||
        _fechaSeleccionada == null ||
        _doctorSeleccionado == null ||
        _horaSeleccionada == null ||
        _usuarioSeleccionado == null ||
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
        'usuarioUid': _usuarioSeleccionado!['uid'],
        'usuarioNombre': _usuarioSeleccionado!['nombre'],
        'estado': 'PENDIENTE',
        'fechaCreacion': ServerValue.timestamp,
        'administradorUid': widget.uid, // Guardamos quién creó la cita
      };

      final ref = FirebaseDatabase.instance.ref('citas').push();
      await ref.set(nuevaCita);
      nuevaCita['id'] = ref.key;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cita agendada con éxito para el $fecha a las $_horaSeleccionada',
            style: const TextStyle(color: Color(0xFF1E4B69)),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Mostrar diálogo informativo
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(
                'Cita Agendada',
                style: TextStyle(
                  color: Color(0xFF1E4B69),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text('La cita ha sido agendada exitosamente.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(
                      color: Color(0xFF1E4B69),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      );

      // Enviar notificación
      await _mostrarNotificacionCita(
        _tipoCita,
        _usuarioSeleccionado!['nombre'],
        fecha,
        _horaSeleccionada!,
      );

      // Regresar a la pantalla anterior
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
    String nombreusuario,
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
        'Cita de $tipo para el $fecha a las $hora para el usuario $nombreusuario',
        notificationDetails,
      );

      // Guardar en SharedPreferences
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

  Icon _getIcon() {
    switch (_tipoCita) {
      case 'Peluqueria':
        return const Icon(
          Icons.content_cut,
          size: 40,
          color: Color.fromRGBO(30, 75, 105, 1),
        );
      case 'Vacunacion':
        return const Icon(
          Icons.healing,
          size: 40,
          color: Color.fromRGBO(30, 75, 105, 1),
        );
      case 'Limpieza':
        return const Icon(
          Icons.cleaning_services,
          size: 40,
          color: Color.fromRGBO(30, 75, 105, 1),
        );
      default:
        return const Icon(
          Icons.medical_services,
          size: 40,
          color: Color.fromRGBO(30, 75, 105, 1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                          gradient: const LinearGradient(
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
                              child: _getIcon(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _tipoCita,
                              style: const TextStyle(
                                color: Colors.white,
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
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _seleccionarFecha,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      _fechaSeleccionada == null
                          ? 'Seleccionar Fecha'
                          : 'Fecha: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown para seleccionar cliente - Versión optimizada
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _usuarioSeleccionado,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      labelText: 'Selecciona el cliente',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    isExpanded: true,
                    itemHeight: 60, // Altura óptima para dos líneas
                    style: const TextStyle(fontSize: 14),
                    items:
                        _clientes.map((cliente) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: cliente,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 280,
                              ), // Limita el ancho máximo
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cliente['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (nuevoCliente) {
                      setState(() {
                        _usuarioSeleccionado = nuevoCliente;
                        _mascotaSeleccionada = null;
                        if (nuevoCliente != null) {
                          _cargarMascotasEnTiempoReal(nuevoCliente['uid']);
                        } else {
                          _mascotasUsuario = [];
                        }
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Selecciona un cliente' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dropdown para profesionales con horarios
                  DropdownButtonFormField<String>(
                    value: _doctorSeleccionado,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      labelText: 'Selecciona el profesional',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    items:
                        _profesionales.map((profesional) {
                          return DropdownMenuItem<String>(
                            value: profesional['uid'],
                            child: Text(profesional['nombre']),
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
                            value == null ? 'Selecciona un profesional' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dropdown para horarios disponibles del profesional
                  DropdownButtonFormField<String>(
                    value: _horaSeleccionada,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.access_time,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      labelText: 'Selecciona la hora',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    items:
                        (_doctorSeleccionado != null &&
                                _horariosDisponibles.containsKey(
                                  _doctorSeleccionado,
                                ))
                            ? _horariosDisponibles[_doctorSeleccionado]!
                                .map(
                                  (hora) => DropdownMenuItem<String>(
                                    value: hora,
                                    child: Text(hora),
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
                        (value) => value == null ? 'Selecciona una hora' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dropdown para mascotas (solo disponible si se seleccionó un usuario)
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _mascotaSeleccionada,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.pets,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      labelText: 'Selecciona la mascota',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    items:
                        _mascotasUsuario.map((mascota) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: mascota,
                            child: Text(
                              '${mascota['nombre']} - ${mascota['raza']}',
                            ),
                          );
                        }).toList(),
                    onChanged:
                        _usuarioSeleccionado != null
                            ? (nuevaMascota) {
                              setState(() {
                                _mascotaSeleccionada = nuevaMascota;
                              });
                            }
                            : null,
                    validator:
                        (value) =>
                            value == null ? 'Selecciona una mascota' : null,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _guardando ? null : _guardarCita,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(30, 75, 105, 1),
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
                      color: const Color.fromARGB(200, 160, 160, 160),
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
  }
}
// ===========================================================================