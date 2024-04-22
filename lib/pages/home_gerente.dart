import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/home_widget.dart';

class HomeGerente extends StatefulWidget {
  const HomeGerente({super.key});

  @override
  State<HomeGerente> createState() => _HomeGerenteState();
}

class _HomeGerenteState extends State<HomeGerente> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Home Gerente',
            style: TextStyle(fontSize: 25,
            fontWeight: FontWeight.bold
            )
          ),
          centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/actualizarDatos'); // Navega a la página de Actualizar Datos
              },
              icon: const Icon(Icons.update), // Ícono para actualizar datos
              label: const Text('Actualizar Datos'), // Texto del botón
            ),
            const SizedBox(height: 20), // Espaciador
            ElevatedButton.icon(
              onPressed: () {
                signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
  }
}