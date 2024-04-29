// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GestionEmpleados extends StatefulWidget {
  const GestionEmpleados({super.key});
  @override
  State<GestionEmpleados> createState() => _GestionEmpleadosState();
}

class _GestionEmpleadosState extends State<GestionEmpleados> {
  List<Map<String, dynamic>> empleados =
      []; // Lista de empleados obtenida de la DB
  List<String> estados = ['Activo', 'Inactivo'];
  List<String> roles = ['Mesero', 'Gerente', 'Chef'];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    cargarEmpleados();
  }

  Future<void> cargarEmpleados() async {
    final data = await supabase
        .from("empleado")
        .select('user_name, correo_electronico, estado_cuenta, rol')
        .not("user_name", "eq", "Admin");

    setState(() {
      empleados = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: empleados.length,
        itemBuilder: (context, index) {
          return _buildEmpleadoCard(empleados[index]);
        },
      ),
    );
  }

  Widget _buildEmpleadoCard(Map<String, dynamic> empleado) {
    return Card(
      color: EsquemaDeColores.secondary,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
      child: Column(
        children: [
          ListTile(
            title: RichText(
              text: TextSpan(
                text: 'Usuario: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: EsquemaDeColores.onSecondary,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: empleado['user_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 19,
                      color: EsquemaDeColores.onPrimary, // Puedes personalizar el estilo aquí
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
                      fontSize: 20,
                      color: EsquemaDeColores.onSecondary,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: empleado['correo_electronico'],
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 19,
                          color: EsquemaDeColores.onPrimary, // Puedes personalizar el estilo aquí
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estado:',
                      style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17
                          ),
                    ),
                    DropdownButton<String>(
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
                          child: Text(estado, style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.normal
                            )
                          ),
                        );
                      }).toList(),
                    ),
                    const Text(
                      'Rol:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    DropdownButton<String>(
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
                          child: Text(rol, style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.normal
                            )
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FFButtonWidget(
            onPressed: () async {
              try {
                await supabase.from('empleado').update({
                  'estado_cuenta': empleado['estado_cuenta'],
                  'rol': empleado['rol']
                }).match(
                    {'correo_electronico': empleado['correo_electronico']});
              } catch (e) {
                showCustomErrorDialog(context, e.toString());
                return;
              }
              showCustomExitDialog(context, 'Actualización exitosa');
              cargarEmpleados();
            },
            text: 'Actualizar Empleado',
            options: FFButtonOptions(
              width: 250,
              height: 32,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              color: const Color.fromARGB(255, 4, 88, 254),
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontSize: 17,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                  ),
              elevation: 3,
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
