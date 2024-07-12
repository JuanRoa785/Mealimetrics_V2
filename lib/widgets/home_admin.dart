import 'package:flutter/material.dart';
import 'package:mealimetrics/pages/home_chef.dart';
import 'package:mealimetrics/pages/home_gerente.dart';
import 'package:mealimetrics/pages/home_mesero.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/home_widget.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  final supabase = Supabase.instance.client;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: EsquemaDeColores.backgroundSecondary,
        title: const Text(
          'Home Admin',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeGerente()));
                },
                icon: const Icon(Icons.business),
                label: const Text(
                  'Gerente',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 60),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeMesero()));
                },
                icon: const Icon(Icons.description),
                label: const Text(
                  'Mesero',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 60),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeChef()));
                },
                icon: const Icon(Icons.restaurant_menu),
                label: const Text(
                  'Chef',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 60),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }
}
