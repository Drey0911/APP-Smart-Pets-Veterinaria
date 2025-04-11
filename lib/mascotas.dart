import 'package:flutter/material.dart';
import 'dart:io'; // Para manejo de archivos
import 'package:image_picker/image_picker.dart'; // paquete para seleccion de imagenes

class Mascotas extends StatefulWidget {
  const Mascotas({super.key});

  @override
  _MascotasState createState() => _MascotasState();
}

class _MascotasState extends State<Mascotas> {
  final List<Map<String, dynamic>> _mascotas =
      []; // Lista para almacenar detalles de mascotas

  void _agregarMascota() async {
    final nuevaMascota = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormularioMascota()),
    );

    if (nuevaMascota != null) {
      setState(() {
        _mascotas.add(nuevaMascota);
      });
    }
  }

  void _editarMascota(int index) async {
    final mascotaEditada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioMascota(mascota: _mascotas[index]),
      ),
    );

    if (mascotaEditada != null) {
      setState(() {
        _mascotas[index] = mascotaEditada;
      });
    }
  }

  void _eliminarMascota(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Eliminar Mascota',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 17, 46, 88),
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar a ${_mascotas[index]['nombre']}?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: const Color.fromARGB(255, 17, 46, 88),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _mascotas.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Eliminar',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 0, 0),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(150, 193, 212, 1),
              Color.fromRGBO(30, 75, 105, 1),
              Color.fromRGBO(30, 75, 105, 1),
              Color.fromRGBO(30, 75, 105, 1),
              Color.fromRGBO(30, 75, 105, 1),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
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

            // Lista de mascotas
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.only(
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
                    _mascotas.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pets,
                                size: 80,
                                color: Color(0xFF1E4B69).withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No tienes mascotas registradas',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1E4B69).withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _mascotas.length,
                          itemBuilder: (context, index) {
                            final mascota = _mascotas[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      mascota['foto'] != null
                                          ? FileImage(mascota['foto'])
                                          : AssetImage('images/default_pet.png')
                                              as ImageProvider,
                                ),
                                title: Text(
                                  mascota['nombre'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E4B69),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      'EDAD: ${mascota['edad']} ${mascota['unidadEdad']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'RAZA: ${mascota['raza']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'GÉNERO: ${mascota['genero']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Color(0xFF1E4B69),
                                      ),
                                      onPressed: () => _editarMascota(index),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _eliminarMascota(index),
                                    ),
                                  ],
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

class FormularioMascota extends StatefulWidget {
  final Map<String, dynamic>? mascota;

  const FormularioMascota({super.key, this.mascota});

  @override
  _FormularioMascotaState createState() => _FormularioMascotaState();
}

class _FormularioMascotaState extends State<FormularioMascota> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  String _genero = 'Macho';
  String _unidadEdad = 'Años';
  File? _foto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.mascota != null) {
      _nombreController.text = widget.mascota!['nombre'];
      _razaController.text = widget.mascota!['raza'];
      _edadController.text = widget.mascota!['edad'];
      _genero = widget.mascota!['genero'];
      _unidadEdad = widget.mascota!['unidadEdad'] ?? 'Años';
      _foto = widget.mascota!['foto'];
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
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagenDeGaleria();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tomar foto'),
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
        'raza': _razaController.text,
        'edad': _edadController.text,
        'genero': _genero,
        'unidadEdad': _unidadEdad,
        'foto': _foto,
      };
      Navigator.pop(context, nuevaMascota);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromRGBO(255, 255, 255, 1),
            ],
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
                    SizedBox(height: 20),

                    // Header section
                    Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 30),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
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
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0),
                                        width: 20,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 30),
                                        Center(
                                          child: Text(
                                            widget.mascota == null
                                                ? '¡Registra a tu nueva mascota!'
                                                : 'Edita la información de tu mascota',
                                            style: TextStyle(
                                              fontSize: 28, // Letra más grande
                                              fontWeight:
                                                  FontWeight.w900, // Más gruesa
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 20),
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
                                                              ? FileImage(
                                                                _foto!,
                                                              )
                                                              : AssetImage(
                                                                    'images/default_pet.png',
                                                                  )
                                                                  as ImageProvider,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Color(
                                                          0xFF1E4B69,
                                                        ),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text(
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
                                  SizedBox(height: 20),
                                ],
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
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(
                                width: 8,
                              ), // Espaciado entre la flecha y el título
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 25),

                    // Campos de formulario
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.pets,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        labelText:
                            'Nombre de la mascota', // Esto es para que el placeholder se convierta en el label
                        labelStyle: TextStyle(color: Colors.black),
                        floatingLabelBehavior:
                            FloatingLabelBehavior
                                .auto, // Placeholder sube automáticamente
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ), // al hacer la animacion cambia el color
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bordes ovalados
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bordes ovalados
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el nombre';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    TextFormField(
                      controller: _razaController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.category,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        labelText:
                            'Raza', // Esto es para que el placeholder se convierta en el label
                        labelStyle: TextStyle(color: Colors.black),
                        floatingLabelBehavior:
                            FloatingLabelBehavior
                                .auto, // Placeholder sube automáticamente
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ), // al hacer la animacion cambia el color
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bordes ovalados
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bordes ovalados
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la raza';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Edad con unidad
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _edadController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              labelText:
                                  'Edad', // Esto es para que el placeholder se convierta en el label
                              labelStyle: TextStyle(color: Colors.black),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior
                                      .auto, // Placeholder sube automáticamente
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ), // al hacer la animacion cambia el color
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // Bordes ovalados
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // Bordes ovalados
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa la edad';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: DropdownButtonFormField<String>(
                              value: _unidadEdad,
                              decoration: InputDecoration(
                                labelText:
                                    'Edad', // Esto es para que el placeholder se convierta en el label
                                labelStyle: TextStyle(color: Colors.black),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior
                                        .auto, // Placeholder sube automáticamente
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ), // al hacer la animacion cambia el color
                                  borderRadius: BorderRadius.circular(
                                    30,
                                  ), // Bordes ovalados
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                    30,
                                  ), // Bordes ovalados
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
                              items:
                                  ['Días', 'Meses', 'Años']
                                      .map(
                                        (unidad) => DropdownMenuItem(
                                          value: unidad,
                                          child: Text(unidad),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _unidadEdad = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: DropdownButtonFormField<String>(
                        value: _genero,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.pets,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          labelText:
                              'Genero', // Esto es para que el placeholder se convierta en el label
                          labelStyle: TextStyle(color: Colors.black),
                          floatingLabelBehavior:
                              FloatingLabelBehavior
                                  .auto, // Placeholder sube automáticamente
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ), // al hacer la animacion cambia el color
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Bordes ovalados
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Bordes ovalados
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                        items:
                            ['Macho', 'Hembra']
                                .map(
                                  (genero) => DropdownMenuItem(
                                    value: genero,
                                    child: Text(genero),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _genero = value!;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 40),

                    // Botón guardar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(30, 75, 105, 1),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: Offset(0, 4),
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

                    SizedBox(height: 16),

                    // Botón cancelar
                    if (widget.mascota != null)
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
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
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
  }
}
