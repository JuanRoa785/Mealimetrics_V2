import 'package:flutter/material.dart';

class EsquemaDeColores {
  static const Color primary = Color(0xFF03045E); // Color primario
  static const Color secondary =  Color(0xFF00b4d8); // Color secundario
  static const Color surface = Color(0xFFcaf0f8); // Superficie
  static const Color background = Color(0xFFcaf0f8);
  static const Color backgroundSecondary = Color.fromARGB(255, 171, 235, 251); // Fondo
  static const Color error = Colors.red; // Color de error (opcional)
  static const Color onPrimary = Colors.white; // Color del texto sobre el color primario
  static const Color onSecondary = Colors.black; // Color del texto sobre el color secundario
  static const Color onSurface = Colors.black; // Color del texto sobre la superficie
  static const Color onBackground = Colors.black; // Color del texto sobre el fondo
  static const Color onError = Colors.white; // Color del texto sobre el color de error (opcional)
  static const Brightness brightness = Brightness.light;
  // Agrega más colores según sea necesario
}

class MyColorScheme extends ColorScheme {
  const MyColorScheme()
      : super(
          primary: EsquemaDeColores.primary,// Si no hay variantes, usa el mismo color primario
          secondary: EsquemaDeColores.secondary, // Si no hay variantes, usa el mismo color secundario
          surface: EsquemaDeColores.surface,
          background: EsquemaDeColores.background,
          error: EsquemaDeColores.error,
          onPrimary: EsquemaDeColores.onPrimary,
          onSecondary: EsquemaDeColores.onSecondary,
          onSurface: EsquemaDeColores.onSurface,
          onBackground: EsquemaDeColores.onBackground,
          onError: EsquemaDeColores.onError,
          brightness: EsquemaDeColores.brightness,
        );
}