import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===========================================================================
// PANTALLA DE CITAS (MIS CITAS)
// ===========================================================================

class Citas extends StatefulWidget {
  const Citas({Key? key}) : super(key: key);

  @override
  CitasState createState() => CitasState();
}

// Renombramos _CitasState a CitasState (público)
class CitasState extends State<Citas> {
  // Lista para almacenar las citas agendadas.
  final List<Map<String, dynamic>> _citas = [];

  // Método para agregar una cita a la lista.
  void addCita(Map<String, dynamic> nuevaCita) {
    setState(() {
      _citas.add(nuevaCita);
    });
  }

  // Función para cancelar (eliminar) una cita.
  void _cancelarCita(int index) {
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
              onPressed: () {
                setState(() {
                  _citas.removeAt(index);
                });
                Navigator.of(context).pop();
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
    return Scaffold(
      // Fondo con degradado.
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
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
            // Encabezado.
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
                          builder: (context) => const HistorialCitas(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.history,
                      color: Color.fromRGBO(30, 75, 105, 1),
                    ),
                    label: Text(
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
            // Lista de citas.
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
                              Text(
                                'No tienes citas agendadas',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: const Color(
                                    0xFF1E4B69,
                                  ).withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _citas.length,
                          itemBuilder: (context, index) {
                            final cita = _citas[index];
                            // Asigna colores e ícono según el tipo de cita.
                            Color startColor;
                            Color endColor;
                            IconData citaIcon;
                            switch (cita['tipo']) {
                              case 'Vacunacion':
                                startColor = Colors.red.shade300;
                                endColor = Colors.red.shade700;
                                citaIcon = Icons.healing;
                                break;
                              case 'Limpieza':
                                startColor = Colors.amber.shade300;
                                endColor = Colors.amber.shade700;
                                citaIcon = Icons.cleaning_services;
                                break;
                              case 'Peluqueria':
                                startColor = Colors.purple.shade300;
                                endColor = Colors.purple.shade700;
                                citaIcon = Icons.content_cut;
                                break;
                              default:
                                startColor = Colors.blue.shade300;
                                endColor = Colors.blue.shade700;
                                citaIcon = Icons.medical_services;
                                break;
                            }
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [startColor, endColor],
                                    ),
                                  ),
                                  child: Icon(
                                    citaIcon,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                title: Text(
                                  '${cita['tipo']} - ${cita['doctor']} (${cita['hora']})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E4B69),
                                  ),
                                ),
                                subtitle: Text(
                                  'Fecha: ${cita['fecha']}\nMascota: ${cita['mascota']['nombre']} (${cita['mascota']['raza']})',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _cancelarCita(index),
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
}

// ===========================================================================
// FORMULARIO PARA SELECCIONAR EL TIPO DE CITA (flujo opcional)
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
  final String? tipoCita; // Recibido al navegar directamente.
  final Map<String, dynamic>? cita; // No se usa para edición.

  const FormularioCita({Key? key, this.tipoCita, this.cita}) : super(key: key);

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

  // Datos de ejemplo.
  final List<String> _doctores = [
    'Dr. Juan Pérez',
    'Dra. Ana López',
    'Dr. Carlos García',
  ];
  final Map<String, List<String>> _horarios = {
    'Dr. Juan Pérez': ['10:00 AM', '11:00 AM', '2:00 PM'],
    'Dra. Ana López': ['9:00 AM', '1:00 PM', '3:00 PM'],
    'Dr. Carlos García': ['8:00 AM', '12:00 PM', '4:00 PM'],
  };
  final List<Map<String, dynamic>> _mascotas = [
    {
      'nombre': 'Firulais',
      'raza': 'Labrador',
      'edad': '4',
      'genero': 'Masculino',
    },
    {'nombre': 'Mia', 'raza': 'Persa', 'edad': '3', 'genero': 'Femenino'},
    {'nombre': 'Bobby', 'raza': 'Beagle', 'edad': '5', 'genero': 'Masculino'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cita != null) {
      _tipoCita = widget.cita!['tipo'];
      _fechaSeleccionada = DateTime.tryParse(widget.cita!['fecha']);
      _doctorSeleccionado = widget.cita!['doctor'];
      _horaSeleccionada = widget.cita!['hora'];
      _mascotaSeleccionada = widget.cita!['mascota'];
    } else {
      _tipoCita = widget.tipoCita ?? 'Control';
      _doctorSeleccionado = _doctores[0];
      _horaSeleccionada = _horarios[_doctores[0]]![0];
      _mascotaSeleccionada = _mascotas[0];
    }
  }

  // haciendo uso del datepicker
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
              primary: const Color.fromARGB(
                255,
                24,
                54,
                92,
              ), // Color del encabezado
              onPrimary: Colors.white, // Color del texto en el encabezado
              onSurface:
                  Colors.black, // Color del texto en el resto del diálogo
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(
                  255,
                  24,
                  54,
                  92,
                ), // Color de los botones
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

  // Guarda el mensaje de notificación en SharedPreferences.
  Future<void> _guardarNotificacionMensaje(String mensaje) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificaciones = prefs.getStringList('notificaciones') ?? [];
    notificaciones.insert(0, mensaje);
    await prefs.setStringList('notificaciones', notificaciones);
  }

  Future<void> _mostrarNotificacionCita(
    String tipo,
    String fecha,
    String hora,
  ) async {
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
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    String mensajeNotificacion =
        'Cita de $tipo agendada con éxito para el $fecha a las $hora';

    await flutterLocalNotificationsPlugin.show(
      0,
      'Cita Agendada',
      mensajeNotificacion,
      notificationDetails,
    );

    // Guarda el mensaje para NotificacionesPage.
    await _guardarNotificacionMensaje(mensajeNotificacion);
  }

  void _guardarCita() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una fecha')),
        );
        return;
      }
      String fecha =
          '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}';
      Map<String, dynamic> nuevaCita = {
        'tipo': _tipoCita,
        'fecha': fecha,
        'doctor': _doctorSeleccionado,
        'hora': _horaSeleccionada,
        'mascota': _mascotaSeleccionada,
      };
      // Muestra y guarda la notificación.
      await _mostrarNotificacionCita(_tipoCita, fecha, _horaSeleccionada ?? '');
      // Espera brevemente para asegurar que se actualicen los SharedPreferences
      await Future.delayed(const Duration(milliseconds: 100));
      Navigator.pop(context, nuevaCita);
    }
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  Icon _getIcon() {
    if (_tipoCita == 'Peluqueria') {
      return Icon(
        Icons.content_cut,
        size: 40,
        color: Color.fromRGBO(30, 75, 105, 1),
      );
    } else if (_tipoCita == 'Vacunacion') {
      return Icon(
        Icons.healing,
        size: 40,
        color: Color.fromRGBO(30, 75, 105, 1),
      );
    } else if (_tipoCita == 'Limpieza') {
      return Icon(
        Icons.cleaning_services,
        size: 40,
        color: Color.fromRGBO(30, 75, 105, 1),
      );
    }
    return Icon(
      Icons.medical_services,
      size: 40,
      color: Color.fromRGBO(30, 75, 105, 1),
    );
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
                  // Encabezado de la cita.
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
                              child: _getIcon(),
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
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
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _doctorSeleccionado,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      labelText: 'Selecciona el doctor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    items:
                        _doctores.map((doc) {
                          return DropdownMenuItem<String>(
                            value: doc,
                            child: Text(doc),
                          );
                        }).toList(),
                    onChanged: (nuevoDoc) {
                      setState(() {
                        _doctorSeleccionado = nuevoDoc;
                        _horaSeleccionada = _horarios[nuevoDoc!]![0];
                      });
                    },
                  ),
                  const SizedBox(height: 16),
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
                        (_doctorSeleccionado != null
                                ? _horarios[_doctorSeleccionado]
                                : [])
                            ?.map(
                              (hora) => DropdownMenuItem<String>(
                                value: hora,
                                child: Text(hora),
                              ),
                            )
                            .toList(),
                    onChanged: (nuevaHora) {
                      setState(() {
                        _horaSeleccionada = nuevaHora;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
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
                        _mascotas.map((mascota) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: mascota,
                            child: Text(
                              '${mascota['nombre']} - ${mascota['raza']}',
                            ),
                          );
                        }).toList(),
                    onChanged: (nuevaMascota) {
                      setState(() {
                        _mascotaSeleccionada = nuevaMascota;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(30, 75, 105, 1),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _guardarCita,
                      child: const Text(
                        'Guardar Cita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(200, 160, 160, 160),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _cancelar,
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
// PANTALLA HISTÓRICO DE CITAS (CITAS PASADAS)
// ===========================================================================

class HistorialCitas extends StatelessWidget {
  const HistorialCitas({Key? key}) : super(key: key);

  // Lista "quemada" de citas pasadas de ejemplo.
  final List<Map<String, dynamic>> _historial = const [
    {
      'tipo': 'Control',
      'fecha': '15/03/2025',
      'doctor': 'Dra. Ana López',
      'hora': '1:00 PM',
      'mascota': {
        'nombre': 'Mia',
        'raza': 'Persa',
        'edad': '3',
        'genero': 'Femenino',
      },
    },
    {
      'tipo': 'Vacunacion',
      'fecha': '10/02/2025',
      'doctor': 'Dr. Juan Pérez',
      'hora': '11:00 AM',
      'mascota': {
        'nombre': 'Firulais',
        'raza': 'Labrador',
        'edad': '4',
        'genero': 'Masculino',
      },
    },
    {
      'tipo': 'Peluqueria',
      'fecha': '05/01/2025',
      'doctor': 'Dr. Carlos García',
      'hora': '4:00 PM',
      'mascota': {
        'nombre': 'Bobby',
        'raza': 'Beagle',
        'edad': '5',
        'genero': 'Masculino',
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Citas',
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _historial.length,
          itemBuilder: (context, index) {
            final cita = _historial[index];
            Color startColor;
            Color endColor;
            IconData citaIcon;
            switch (cita['tipo']) {
              case 'Vacunacion':
                startColor = Colors.red.shade300;
                endColor = Colors.red.shade700;
                citaIcon = Icons.healing;
                break;
              case 'Limpieza':
                startColor = Colors.amber.shade300;
                endColor = Colors.amber.shade700;
                citaIcon = Icons.cleaning_services;
                break;
              case 'Peluqueria':
                startColor = Colors.purple.shade300;
                endColor = Colors.purple.shade700;
                citaIcon = Icons.content_cut;
                break;
              default:
                startColor = Colors.blue.shade300;
                endColor = Colors.blue.shade700;
                citaIcon = Icons.medical_services;
                break;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [startColor, endColor]),
                  ),
                  child: Icon(citaIcon, color: Colors.white, size: 30),
                ),
                title: Text(
                  '${cita['tipo']} - ${cita['doctor']} (${cita['hora']})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E4B69),
                  ),
                ),
                subtitle: Text(
                  'Fecha: ${cita['fecha']}\nMascota: ${cita['mascota']['nombre']} (${cita['mascota']['raza']})',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
