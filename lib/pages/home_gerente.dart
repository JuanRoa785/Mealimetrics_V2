import 'package:flutter/material.dart';
import 'package:mealimetrics/pages/gestion_menu.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:mealimetrics/widgets/home_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/home_widget.dart';
import 'package:mealimetrics/pages/gestion_empleados.dart';
import 'package:mealimetrics/Estadisticas/screens/home_stats.dart';

class HomeGerente extends StatefulWidget {
  const HomeGerente({super.key});

  @override
  State<HomeGerente> createState() => _HomeGerenteState();
}

class _HomeGerenteState extends State<HomeGerente> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: EsquemaDeColores.backgroundSecondary,
        title: const Text('Home Gerente',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            // Aquí se crea el botón de flecha <-
            icon: const Icon(Icons.logout_sharp,
                size: 28), // Icono de flecha hacia atrás
            onPressed: () {
              signOut(); //Cierra la sesion
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.account_circle_sharp, size: 35),
              onPressed: () {
                Navigator.pushNamed(context, '/actualizarDatos');
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          GestionEmpleados(),
          HomeStats(supabaseUrl: 'https://fqsdytkispydwsmcbikh.supabase.co', supabaseKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxc2R5dGtpc3B5ZHdzbWNiaWtoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MTUzNzA4MywiZXhwIjoyMDU3MTEzMDgzfQ.HG8nwPE4ev9pDbSo_rX519Skd3jT-q2tDcWCtIYICVY',),
          GestionMenu(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_person_outlined, size: 30),
            label: 'Empleados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined, size: 30),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.no_food_outlined, size: 30),
            label: 'Menú',
          ),
        ],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedFontSize: 20,
        unselectedFontSize: 20,
      ),
    );
  }

  Future<void> signOut() async {
    final User? user = supabase.auth.currentUser;
    if (user?.id == "8554245a-6ee6-448c-89ee-742bd3bbf431") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
      return;
    }

    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }
}
