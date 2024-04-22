import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/home_widget.dart';
import 'package:mealimetrics/widgets/actualizar_datos.dart';


const supabaseUrl = 'https://ddyveuettsjaxmdbijgb.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkeXZldWV0dHNqYXhtZGJpamdiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxMzA1MDgzNCwiZXhwIjoyMDI4NjI2ODM0fQ.FoRjsJj9d7R-XSkNN4hokmfmTG-mEcr2QuWWT9RFnxc';

Future<void> main() async {
//Inicializar Supabase
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseKey,
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
  realtimeClientOptions: const RealtimeClientOptions(
    logLevel: RealtimeLogLevel.info,
  ),
  storageOptions: const StorageClientOptions(
    retryAttempts: 10,
  ),
);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

    final ColorScheme myColorScheme = const ColorScheme(
    primary: Color(0xFF03045E), // Color primario
    secondary: Color(0xFF00b4d8), // Color secundario
    surface: Color(0xFFcaf0f8), // Superficie
    background: Color(0xFFcaf0f8), // Fondo
    error: Colors.red, // Color de error (opcional)
    onPrimary: Colors.white, // Color del texto sobre el color primario
    onSecondary: Colors.black, // Color del texto sobre el color secundario
    onSurface: Colors.black, // Color del texto sobre la superficie
    onBackground: Colors.black, // Color del texto sobre el fondo
    onError: Colors.white, // Color del texto sobre el color de error (opcional)
    brightness: Brightness.light, // Brillo (puede ser light o dark)
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mealimetrics',
      debugShowCheckedModeBanner:false,
      theme: ThemeData(
        colorScheme: myColorScheme,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: const Home(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        // Splash page is needed to ensure that authentication and page loading works correctly
        '/': (_) => const Home(),
          // Ruta para la página de actualización de datos
        '/actualizarDatos': (_) => const ActualizarDatos(),
      },
    );
  }
}
