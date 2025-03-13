// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GestionEmpleados extends StatefulWidget {
  const GestionEmpleados({super.key});
  @override
  State<GestionEmpleados> createState() => _GestionEmpleadosState();
}

class _GestionEmpleadosState extends State<GestionEmpleados> {
  List<Map<String, dynamic>> empleados = []; // Lista de empleados obtenida de la DB
  List<String> estados = ['Activo', 'Inactivo'];
  List<String> roles = ['Gerente', 'Mesero', 'Chef'];
  String? rolValue;
  String? estadoValue;
  final supabase = Supabase.instance.client;
  final TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    rolValue = roles.first;
    estadoValue = estados.first;
    cargarEmpleados();
  }

  Future<void> cargarEmpleados() async {
    String filtro = filterController.text.trim();
    String estado = estadoValue.toString();
    String rol = rolValue.toString();
    final List<Map<String, dynamic>> data;

    if(filtro == ""){
      //Filtros según el dropdown
      data = await supabase
        .from("empleado")
        .select('user_name, correo_electronico, estado_cuenta, rol')
        .neq("user_name", "Admin")
        .or('estado_cuenta.eq.$estado')
        .or('rol.eq.$rol');
    }else {
      //Filtro segun username o correo
      data = await supabase
        .from("empleado")
        .select('user_name, correo_electronico, estado_cuenta, rol')
        .neq("user_name", "Admin")
        .or('user_name.ilike.%$filtro%, correo_electronico.ilike.%$filtro%');
    }    
    setState(() {
      empleados = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFiltersCard(),
          Expanded(
            child: ListView.builder(
              itemCount: empleados.length,
              itemBuilder: (context, index) {
                return _buildEmpleadoCard(empleados[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Card(
      color: EsquemaDeColores.secondary,
      margin: const EdgeInsets.only(left: 15.0, right: 10.0, top: 15.0),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Seleccione los Filtros:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              margin: const EdgeInsets.only(left: 3, right: 10.0),
              child: TextField(
                controller: filterController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.abc_outlined),
                  hintText: "Usuario o Correo",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 3),
                ),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  textAlign: TextAlign.start,
                  'Estado: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: estadoValue,
                    dropdownColor: EsquemaDeColores.secondary,
                    onChanged: (newEstado) {
                      setState(() {
                        estadoValue = newEstado!;
                      });
                    },
                    items: estados.map((estado) {
                      return DropdownMenuItem<String>(
                        value: estado,
                        child: Text(estado,
                            style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 17
                            )
                          ),
                      );
                    }).toList(),
                  ),
                ),
                const Text(
                  'Rol: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 17
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: rolValue,
                    dropdownColor: EsquemaDeColores.secondary,
                    onChanged: (newRol) {
                      setState(() {
                        rolValue = newRol!;
                      });
                    },
                    items: roles.map((rol) {
                      return DropdownMenuItem<String>(
                        value: rol,
                        child: Text(
                          rol,
                          style: 
                            const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 17
                            )
                          ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                cargarEmpleados();
                //print(filterController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 32), // Tamaño del botón
                padding: const EdgeInsets.all(0), // Padding alrededor del contenido
                backgroundColor: const Color.fromARGB(255, 4, 88, 254), // Color de fondo del botón
                elevation: 3, // Elevación del botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40), // Bordes redondeados
                  side: const BorderSide(color: Colors.transparent, width: 1), // Borde del botón
                ),
              ),
              child: const Text(
                '¡Aplicar Filtros!',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.white,
                  fontSize: 17,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpleadoCard(Map<String, dynamic> empleado) {
    return Card(
      color: EsquemaDeColores.secondary,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
      child: Column(
        children: [
          const SizedBox(height: 3),
          ListTile(
            contentPadding: const EdgeInsets.only(left:9, right:9, top:2, bottom: 2),
            title: RichText(
              text: TextSpan(
                text: 'Usuario: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: EsquemaDeColores.onSecondary,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: empleado['user_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      color: EsquemaDeColores
                          .onPrimary, // Puedes personalizar el estilo aquí
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    text: 'Email: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: EsquemaDeColores.onSecondary,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: empleado['correo_electronico'],
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                          color: EsquemaDeColores
                              .onPrimary, // Puedes personalizar el estilo aquí
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estado: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, 
                          fontSize: 17),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: empleado['estado_cuenta'],
                        dropdownColor: EsquemaDeColores.secondary,
                        onChanged: (newValue) {
                          setState(() {
                            empleado['estado_cuenta'] = newValue!;
                          });
                        },
                        items: estados.map((estado) {
                          return DropdownMenuItem<String>(
                            value: estado,
                            child: Text(estado,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17)),
                          );
                        }).toList(),
                      ),
                    ),
                    const Text(
                      'Rol: ',
                      style:
                          TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 17
                          ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: empleado['rol'],
                        dropdownColor: EsquemaDeColores.secondary,
                        onChanged: (newValue) {
                          setState(() {
                            empleado['rol'] = newValue!;
                          });
                        },
                        items: roles.map((rol) {
                          return DropdownMenuItem<String>(
                            value: rol,
                            child: Text(rol,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17
                                    )
                                  ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await supabase.from('empleado').update({
                            'estado_cuenta': empleado['estado_cuenta'],
                            'rol': empleado['rol'],
                          }).match({
                            'correo_electronico': empleado['correo_electronico'],
                          });
                        } catch (e) {
                          showCustomErrorDialog(context, e.toString());
                          return;
                        }
                        showCustomExitDialog(context, 'Actualización exitosa');
                        cargarEmpleados();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(250, 32), // Tamaño del botón
                        padding: const EdgeInsets.all(0), // Padding alrededor del contenido
                        backgroundColor: const Color.fromARGB(255, 4, 88, 254), // Color de fondo
                        elevation: 3, // Elevación del botón
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40), // Bordes redondeados
                          side: const BorderSide(color: Colors.transparent, width: 1), // Borde del botón
                        ),
                      ),
                      child: const Text(
                        'Actualizar Empleado',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Colors.white,
                          fontSize: 17,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
