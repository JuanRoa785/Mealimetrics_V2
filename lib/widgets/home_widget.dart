import 'package:flutter/material.dart';
import 'package:mealimetrics/pages/login_page.dart';
import 'package:mealimetrics/pages/register_page.dart';
import 'package:mealimetrics/Styles/color_scheme.dart';

class Home extends StatefulWidget{
  
  const Home({super.key});
  @override
  State<StatefulWidget> createState(){
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MealiMetrics",
          style: TextStyle(
            color: EsquemaDeColores.primary,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Centra el título
        backgroundColor: EsquemaDeColores.backgroundSecondary,
      ),
      body: Center(
        child: _selectedIndex == 0
            ? const LoginPage()
            : const RegisterPage(),
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
            icon: Icon(Icons.login, size:30),
            label: 'Iniciar Sesión',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add, size:30),
            label: 'Registrarse',
          ),
        ],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedFontSize: 20,
        unselectedFontSize: 20,
      ),
    );
  }
}
