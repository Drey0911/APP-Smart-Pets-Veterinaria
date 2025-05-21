import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ThemeModel with ChangeNotifier {
  bool _isDarkMode = false;
  final String userId;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Colores para el tema claro
  static const Color _lightPrimaryColor = Colors.blue;
  static const Color _lightAccentColor = Colors.lightBlueAccent;
  static const Color _lightBackgroundColor = Colors.white;
  static const Color _lightTextColor = Colors.black87;
  static const Color _lightAppBarColor = Colors.blue;

  // Colores para el tema oscuro
  static const Color _darkPrimaryColor = Color.fromRGBO(140, 189, 210, 1);
  // static const Color _darkAccentColor = Color.fromRGBO(140, 189, 210, 1);
  static const Color _darkBackgroundColor = Color.fromRGBO(15, 47, 67, 1);
  static const Color _darkTextColor = Colors.white70;
  static const Color _darkAppBarColor = Color(0xFF1E1E1E);

  ThemeModel(this.userId) {
    _loadThemeFromFirebase();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  // Configuración del tema claro
  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    colorScheme: ColorScheme.light(
      primary: const Color.fromARGB(255, 0, 0, 0),
      secondary: _lightAccentColor,
      background: _lightBackgroundColor,
      surface: _lightBackgroundColor,
      onPrimary: const Color.fromARGB(141, 70, 70, 70),
      onSecondary: const Color.fromARGB(255, 255, 255, 255),
      onBackground: const Color.fromARGB(221, 255, 255, 255),
      onSurface: _lightTextColor,
    ),
    scaffoldBackgroundColor: _lightBackgroundColor,
    appBarTheme: AppBarTheme(
      color: _lightAppBarColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: _lightTextColor),
      headlineMedium: TextStyle(color: _lightTextColor),
      bodyLarge: TextStyle(color: _lightTextColor),
      bodyMedium: TextStyle(color: _lightTextColor),
      labelLarge: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: _lightPrimaryColor),
  );

  // Configuración del tema oscuro
  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    colorScheme: ColorScheme.dark(
      primary: const Color.fromARGB(255, 255, 255, 255),
      secondary: const Color.fromARGB(255, 74, 123, 144),
      background: _darkBackgroundColor,
      surface: _darkBackgroundColor,
      onPrimary: Colors.white,
      onSecondary: const Color.fromARGB(255, 74, 123, 144),
      onBackground: _darkBackgroundColor,
      onSurface: _darkTextColor,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: AppBarTheme(
      color: _darkAppBarColor,
      iconTheme: IconThemeData(color: _darkTextColor),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: _darkTextColor),
      headlineMedium: TextStyle(color: _darkTextColor),
      bodyLarge: TextStyle(color: _darkTextColor),
      bodyMedium: TextStyle(color: _darkTextColor),
      labelLarge: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
    dialogTheme: DialogTheme(
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // Cargar tema desde Firebase
  Future<void> _loadThemeFromFirebase() async {
    try {
      _dbRef.child('usuarios').child(userId).child('tema').onValue.listen((
        event,
      ) {
        final themePreference = event.snapshot.value?.toString() ?? 'claro';
        _isDarkMode = themePreference == 'oscuro';
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error al cargar el tema desde Firebase: $e');
      // Usar tema claro por defecto si hay error
      _isDarkMode = false;
      notifyListeners();
    }
  }

  // Cambiar tema y actualizar en Firebase
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      await _dbRef.child('usuarios').child(userId).update({
        'tema': _isDarkMode ? 'oscuro' : 'claro',
      });
    } catch (e) {
      debugPrint('Error al actualizar el tema en Firebase: $e');
      // Revertir cambio si hay error
      _isDarkMode = !_isDarkMode;
      notifyListeners();
    }
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Restablece el estado del tema a los valores predeterminados
  void reset() {
    _isDarkMode = false;
    notifyListeners();
  }
}
