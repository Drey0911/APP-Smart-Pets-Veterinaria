import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';
import 'package:proyecto/theme_model.dart';

class Mascotas extends StatefulWidget {
  final String uid;

  const Mascotas({super.key, required this.uid});

  @override
  _MascotasState createState() => _MascotasState();
}

class _MascotasState extends State<Mascotas> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child(
    "mascotas",
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<Map<String, dynamic>> _mascotas = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  void _cargarMascotas() {
    _databaseRef
        .orderByChild('dueño')
        .equalTo(widget.uid)
        .onValue
        .listen(
          (event) {
            final mascotas = <Map<String, dynamic>>[];

            if (event.snapshot.value != null && event.snapshot.value is Map) {
              final data = event.snapshot.value as Map<dynamic, dynamic>;

              data.forEach((key, value) {
                if (value is Map) {
                  mascotas.add({
                    'id': key.toString(),
                    'nombre': value['nombre']?.toString() ?? 'Sin nombre',
                    'especie': value['especie']?.toString() ?? 'Sin especie',
                    'raza': value['raza']?.toString() ?? 'Sin raza',
                    'edad': value['edad']?.toString() ?? '0',
                    'unidadEdad': value['unidadEdad']?.toString() ?? 'Años',
                    'sexo': value['sexo']?.toString() ?? 'Macho',
                    'fotoUrl': value['fotoUrl']?.toString() ?? '',
                    'dueño': value['dueño']?.toString() ?? widget.uid,
                  });
                }
              });

              mascotas.sort((a, b) => a['nombre'].compareTo(b['nombre']));
            }

            if (mounted) {
              setState(() {
                _mascotas.clear();
                _mascotas.addAll(mascotas);
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              _mostrarErrorDialog(
                'Error al cargar mascotas: ${error.toString()}',
              );
              setState(() => _isLoading = false);
            }
          },
        );
  }

  Future<String?> _subirImagen(File imagen, String mascotaId) async {
    try {
      final String fileName = Path.basename(imagen.path);
      final ref = _storage.ref().child(
        "mascotas/${widget.uid}/$mascotaId/$fileName",
      );
      UploadTask uploadTask = ref.putFile(imagen);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }

  Future<void> _agregarMascota() async {
    final nuevaMascota = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioMascota(uid: widget.uid),
      ),
    );

    if (nuevaMascota != null && nuevaMascota['nombre'] != null) {
      if (!mounted) return; // Verificar si el widget está montado

      _mostrarDialogoCarga('Agregando mascota...');
      final dialogContext = context; // Guardar el contexto actual

      try {
        DatabaseReference nuevaRef = _databaseRef.push();
        String mascotaId = nuevaRef.key!;

        String? fotoUrl;
        if (nuevaMascota['foto'] != null) {
          fotoUrl = await _subirImagen(nuevaMascota['foto'], mascotaId);
        }

        Map<String, dynamic> mascotaData = {
          'nombre': nuevaMascota['nombre'],
          'especie': nuevaMascota['especie'],
          'raza': nuevaMascota['raza'],
          'edad': nuevaMascota['edad'],
          'unidadEdad': nuevaMascota['unidadEdad'],
          'sexo': nuevaMascota['sexo'],
          'fotoUrl': fotoUrl ?? '',
          'dueño': widget.uid,
        };

        await nuevaRef.set(mascotaData);

        // Cerrar diálogo de carga y mostrar mensaje
        Navigator.of(dialogContext, rootNavigator: true).pop();
        _mostrarMensajeExito('Mascota agregada exitosamente');

        // No es necesario llamar a _cargarMascotas() porque el listener de onValue se actualizará automáticamente
      } catch (e) {
        Navigator.of(dialogContext, rootNavigator: true).pop();
        _mostrarErrorDialog("Error al agregar mascota: $e");
      }
    }
  }

  Future<void> _editarMascota(Map<String, dynamic> mascota) async {
    final mascotaEditada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FormularioMascota(uid: widget.uid, mascota: mascota),
      ),
    );

    if (mascotaEditada != null && mounted) {
      _mostrarDialogoCarga('Actualizando mascota...');
      final dialogContext = context;

      try {
        final id = mascota['id'];
        String? fotoUrl = mascota['fotoUrl'];

        if (mascotaEditada['foto'] != null) {
          if (fotoUrl != null && fotoUrl.isNotEmpty) {
            try {
              final ref = _storage.refFromURL(fotoUrl);
              await ref.delete();
            } catch (e) {
              print("Error al eliminar imagen anterior: $e");
            }
          }
          fotoUrl = await _subirImagen(mascotaEditada['foto'], id);
        }

        await _databaseRef.child(id).update({
          'nombre': mascotaEditada['nombre'],
          'especie': mascotaEditada['especie'],
          'raza': mascotaEditada['raza'],
          'edad': mascotaEditada['edad'],
          'unidadEdad': mascotaEditada['unidadEdad'],
          'sexo': mascotaEditada['sexo'],
          'fotoUrl': fotoUrl ?? mascota['fotoUrl'],
        });

        Navigator.of(dialogContext, rootNavigator: true).pop();
        _mostrarMensajeExito('Mascota actualizada exitosamente');
      } catch (e) {
        Navigator.of(dialogContext, rootNavigator: true).pop();
        _mostrarErrorDialog("Error al actualizar mascota: $e");
      }
    }
  }

  Future<void> _eliminarMascota(Map<String, dynamic> mascota) async {
    final bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Eliminar Mascota",
            style: TextStyle(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E4B69),
            ),
          ),
          content: Text(
            "¿Estás seguro de que deseas eliminar a ${mascota['nombre']}?",
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancelar",
                style: TextStyle(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color.fromARGB(255, 17, 46, 88),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      _mostrarDialogoCarga('Eliminando mascota...');
      final dialogContext = context;

      try {
        final id = mascota['id'];
        final fotoUrl = mascota['fotoUrl'];

        if (fotoUrl != null && fotoUrl.isNotEmpty) {
          try {
            final ref = _storage.refFromURL(fotoUrl);
            await ref.delete();
          } catch (e) {
            print("Error al eliminar imagen: $e");
          }
        }

        await _databaseRef.child(id).remove();

        Navigator.of(dialogContext, rootNavigator: true).pop();
        _mostrarMensajeExito('Mascota eliminada exitosamente');
      } catch (e) {
        Navigator.of(dialogContext, rootNavigator: true).pop();
        _mostrarErrorDialog("Error al eliminar mascota: $e");
      }
    }
  }

  void _mostrarDialogoCarga(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(30, 75, 105, 1),
                    Color.fromRGBO(150, 193, 212, 1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono personalizado
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(170, 217, 238, 1),
                          Color.fromRGBO(30, 75, 105, 1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(
                        'images/icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Indicador de carga
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),

                  // Texto con icono de mascota
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pets, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        mensaje, // Usamos el parámetro recibido
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
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
    );
  }

  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text("Cerrar"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(75),
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(170, 217, 238, 1),
                  Color.fromRGBO(140, 189, 210, 1),
                  Color.fromRGBO(30, 75, 105, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset('images/icon.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, color: Colors.white, size: 40),
              const SizedBox(width: 10),
              Text(
                'Cargando...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Un momento por favor',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
                    'Mis Mascotas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _agregarMascota,
                    icon: Icon(
                      Icons.add,
                      color: Color.fromRGBO(30, 75, 105, 1),
                    ),
                    label: Text(
                      'Agregar',
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
                    _isLoading
                        ? _buildLoadingScreen()
                        : _mascotas.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pets,
                                size: 80,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.5)
                                        : const Color(
                                          0xFF1E4B69,
                                        ).withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tienes mascotas registradas',
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.7)
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
                          itemCount: _mascotas.length,
                          itemBuilder: (context, index) {
                            final mascota = _mascotas[index];

                            // Siempre usar el color de "perro"
                            final Color startColor = const Color.fromARGB(
                              255,
                              132,
                              190,
                              238,
                            );
                            final Color endColor = const Color.fromARGB(
                              255,
                              31,
                              61,
                              90,
                            );

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
                                    colors: [
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
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Color.fromRGBO(
                                            15,
                                            47,
                                            67,
                                            1,
                                          ).withOpacity(0.85)
                                          : Colors.white.withOpacity(0.95),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Avatar con gradiente de fondo
                                      Container(
                                        width: 60,
                                        height: 60,
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: CircleAvatar(
                                            radius: 28,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage:
                                                mascota['fotoUrl'] != null &&
                                                        mascota['fotoUrl']
                                                            .isNotEmpty
                                                    ? NetworkImage(
                                                      mascota['fotoUrl'],
                                                    )
                                                    : const AssetImage(
                                                          'images/default_pet.png',
                                                        )
                                                        as ImageProvider,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Contenido de la mascota
                                      Expanded(
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Nombre y Sexo
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    mascota['nombre'],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Theme.of(
                                                                    context,
                                                                  ).brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white70
                                                                  .withOpacity(
                                                                    0.85,
                                                                  )
                                                              : const Color.fromARGB(
                                                                255,
                                                                14,
                                                                53,
                                                                79,
                                                              ).withOpacity(
                                                                0.85,
                                                              ),
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _getGenderColor(
                                                        mascota['sexo'],
                                                      ).withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      mascota['sexo'],
                                                      style: TextStyle(
                                                        color: _getGenderColor(
                                                          mascota['sexo'],
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
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
                                              _buildPetDetailRow(
                                                Icons.pets,
                                                'Especie:',
                                                mascota['especie'],
                                              ),
                                              _buildPetDetailRow(
                                                Icons.category,
                                                'Raza:',
                                                mascota['raza'],
                                              ),
                                              _buildPetDetailRow(
                                                Icons.cake,
                                                'Edad:',
                                                '${mascota['edad']} ${mascota['unidadEdad']}',
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
                                                      startColor.withOpacity(
                                                        0.7,
                                                      ),
                                                      endColor,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // Botones de acciones
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.blue[200]
                                                      : Colors.blue.shade600,
                                            ),
                                            onPressed:
                                                () => _editarMascota(mascota),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.red[200]
                                                      : Colors.red.shade600,
                                            ),
                                            onPressed:
                                                () => _eliminarMascota(mascota),
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

  // Método auxiliar para color según Sexo
  Color _getGenderColor(String sexo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (sexo.toLowerCase()) {
      case 'macho':
        return isDark ? Colors.blue[200]! : Colors.blue.shade700;
      case 'hembra':
        return isDark ? Colors.pink[200]! : Colors.pink.shade600;
      default:
        return isDark ? Colors.grey[400]! : Colors.grey.shade600;
    }
  }

  // Método auxiliar para detalles de mascota
  Widget _buildPetDetailRow(IconData icon, String label, String value) {
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
                    : const Color.fromARGB(255, 12, 34, 49).withOpacity(0.70),
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
                            12,
                            34,
                            49,
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

class FormularioMascota extends StatefulWidget {
  final String uid;
  final Map<String, dynamic>? mascota;

  const FormularioMascota({super.key, required this.uid, this.mascota});

  @override
  _FormularioMascotaState createState() => _FormularioMascotaState();
}

class _FormularioMascotaState extends State<FormularioMascota> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  String _sexo = 'Macho';
  String _unidadEdad = 'Años';
  File? _foto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.mascota != null) {
      _nombreController.text = widget.mascota!['nombre'];
      _especieController.text = widget.mascota!['especie'];
      _razaController.text = widget.mascota!['raza'];
      _edadController.text = widget.mascota!['edad'].toString();
      _sexo = widget.mascota!['sexo'];
      _unidadEdad = widget.mascota!['unidadEdad'] ?? 'Años';
    }
  }

  Future<void> _seleccionarImagenDeGaleria() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() {
        _foto = File(imagen.path);
      });
    }
  }

  Future<void> _tomarFoto() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.camera);
    if (imagen != null) {
      setState(() {
        _foto = File(imagen.path);
      });
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagenDeGaleria();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _tomarFoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _guardarMascota() {
    if (_formKey.currentState!.validate()) {
      final nuevaMascota = {
        'nombre': _nombreController.text,
        'especie': _especieController.text,
        'raza': _razaController.text,
        'edad': _edadController.text,
        'sexo': _sexo,
        'unidadEdad': _unidadEdad,
        'foto': _foto,
        'dueño': widget.uid,
      };
      Navigator.pop(context, nuevaMascota);
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

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundColor, backgroundColor],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 20),

                        // Header section
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromRGBO(150, 193, 212, 1),
                                    Color.fromRGBO(30, 75, 105, 1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0),
                                  width: 20,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 30),
                                  Center(
                                    child: Text(
                                      widget.mascota == null
                                          ? '¡Registra a tu nueva mascota!'
                                          : 'Edita la información de tu mascota',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Foto de la mascota
                                  GestureDetector(
                                    onTap: _mostrarOpcionesImagen,
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 80,
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                    30,
                                                    9,
                                                    16,
                                                    84,
                                                  ),
                                              child: CircleAvatar(
                                                radius: 70,
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                backgroundImage:
                                                    _foto != null
                                                        ? FileImage(_foto!)
                                                        : (widget.mascota !=
                                                                null &&
                                                            widget.mascota!['fotoUrl'] !=
                                                                null &&
                                                            widget
                                                                .mascota!['fotoUrl']
                                                                .isNotEmpty)
                                                        ? NetworkImage(
                                                          widget
                                                              .mascota!['fotoUrl'],
                                                        )
                                                        : const AssetImage(
                                                              'images/default_pet.png',
                                                            )
                                                            as ImageProvider,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF1E4B69,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Toca para cambiar la imagen',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Campos de formulario
                        _buildTextFormField(
                          controller: _nombreController,
                          label: 'Nombre de la mascota',
                          icon: Icons.pets,
                          themeModel: themeModel,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el nombre';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _especieController,
                          label: 'Especie',
                          hint: 'Ejemplo: Perro, Gato, Loro, Tortuga ...',
                          icon: Icons.pets,
                          themeModel: themeModel,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa la especie';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _razaController,
                          label: 'Raza',
                          hint: 'Ejemplo: Labrador, Carey, pug, criollo ...',
                          icon: Icons.category,
                          themeModel: themeModel,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa la raza';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Edad con unidad
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextFormField(
                                controller: _edadController,
                                label: 'Edad',
                                icon: Icons.calendar_today,
                                keyboardType: TextInputType.number,
                                themeModel: themeModel,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa la edad';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Ingresa un número válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: _buildDropdown(
                                  value: _unidadEdad,
                                  label: 'Edad',
                                  items: ['Días', 'Meses', 'Años'],
                                  onChanged: (value) {
                                    setState(() {
                                      _unidadEdad = value!;
                                    });
                                  },
                                  themeModel: themeModel,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _buildDropdown(
                            value: _sexo,
                            label: 'Sexo',
                            icon: Icons.pets,
                            items: ['Macho', 'Hembra'],
                            onChanged: (value) {
                              setState(() {
                                _sexo = value!;
                              });
                            },
                            themeModel: themeModel,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Botón guardar
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: buttonColor,
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
                            onPressed: _guardarMascota,
                            child: Text(
                              'Guardar Mascota',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Botón cancelar
                        if (widget.mascota != null)
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
                              onPressed: () => Navigator.pop(context),
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
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeModel themeModel,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color:
            themeModel.isDarkMode
                ? Colors.white
                : Color.fromRGBO(15, 47, 67, 1),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color:
              themeModel.isDarkMode
                  ? Colors.white70
                  : Color.fromRGBO(15, 47, 67, 1),
        ),
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color:
              themeModel.isDarkMode
                  ? Colors.white70
                  : Color.fromRGBO(15, 47, 67, 1),
        ),
        hintStyle: TextStyle(
          color:
              themeModel.isDarkMode
                  ? Colors.white54
                  : Color.fromRGBO(15, 47, 67, 1),
          fontSize: 13,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                themeModel.isDarkMode
                    ? Colors.white70
                    : Color.fromRGBO(15, 47, 67, 1),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: themeModel.isDarkMode ? Colors.white54 : Colors.black54,
          ),
          borderRadius: BorderRadius.circular(30),
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
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    required ThemeModel themeModel,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon:
            icon != null
                ? Icon(
                  icon,
                  color:
                      themeModel.isDarkMode
                          ? Colors.white70
                          : Color.fromRGBO(15, 47, 67, 1),
                )
                : null,
        labelText: label,
        labelStyle: TextStyle(
          color:
              themeModel.isDarkMode
                  ? Colors.white70
                  : Color.fromRGBO(15, 47, 67, 1),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                themeModel.isDarkMode
                    ? Colors.white70
                    : Color.fromRGBO(15, 47, 67, 1),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                themeModel.isDarkMode
                    ? Colors.white54
                    : Color.fromRGBO(15, 47, 67, 1),
          ),
          borderRadius: BorderRadius.circular(30),
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
      style: TextStyle(
        color: themeModel.isDarkMode ? Colors.white : Colors.black,
      ),
      dropdownColor:
          themeModel.isDarkMode ? Color.fromRGBO(15, 74, 110, 1) : Colors.white,
      items:
          items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: themeModel.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
