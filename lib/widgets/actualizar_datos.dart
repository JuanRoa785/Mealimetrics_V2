// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mealimetrics/styles/color_scheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
//import 'package:intl/intl.dart';

class ActualizarDatos extends StatefulWidget {
  const ActualizarDatos({super.key});

  @override
  State<ActualizarDatos> createState() => _ActualizarDatosState();
}

class _ActualizarDatosState extends State<ActualizarDatos> {
  final supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sexoController = TextEditingController();
  final TextEditingController fechaNacimientoController =TextEditingController();
  final TextEditingController numeroDocumentoController =TextEditingController();
  final TextEditingController tipoDocumentoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const 
        Text('Actualizar Datos',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
            )
          ),
        backgroundColor: EsquemaDeColores.backgroundSecondary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Container(
              alignment: Alignment.center,
              child: const Icon(
                Icons.account_circle_sharp,
                size: 120,
                color: Color.fromARGB(255, 4, 88, 254),
              ),
            ),
              _buildTextFieldWithButton(
                labelText: "Nombre Completo",
                controller: nameController,
                parametro: "Nombre",
                onPressed: actualizarTexto,
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Correo Electrónico",
                controller: emailController,
                parametro: "Email",
                onPressed: actualizarEmail,
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Genero",
                controller: sexoController,
                parametro: "Genero",
                onPressed: actualizarScroll,
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Fecha de nacimiento",
                controller: fechaNacimientoController,
                parametro: "fecha de nacimiento",
                onPressed: actualizarFechaNac,
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Tipo de documento",
                controller: tipoDocumentoController,
                parametro: "Tipo de Documento",
                onPressed: actualizarScroll,
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Numero de documento",
                controller: numeroDocumentoController,
                parametro: "Numero de documento",
                onPressed: actualizarTexto,
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Usuario",
                parametro: "Usuario (Login)",
                controller: userNameController,
                onPressed: actualizarTexto,
              ),
              const SizedBox(height: 35.0),
              FFButtonWidget(
                onPressed: () => actualizarPassword(),
                text: 'Actualizar Contraseña',
                options: FFButtonOptions(
                  width: 230,
                  height: 42,
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: const Color.fromARGB(255, 4, 88, 254),
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontSize: 16,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithButton({
    required String labelText,
    required TextEditingController controller,
    required void Function(String) onPressed,
    required String parametro,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 10), // Añade un espacio entre el TextField y el botón
        ElevatedButton(
          onPressed: () => {
            if(userNameController.text == 'Admin'){
              showCustomErrorDialog(context, "¡La cuenta Admin NO puede ser actualizada!")
            }
            else{
              onPressed(parametro)
            }
          },
          child: const Icon(Icons.update), // Puedes cambiar el icono o el texto según prefieras
        ),
      ],
    );
  }

  Future<void> actualizarTexto(String parametro) async {
    final User? user = supabase.auth.currentUser;
    final idUser = user?.id;
    final TextEditingController newDataController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: EsquemaDeColores.background,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              "Actualizar $parametro",
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newDataController,
                decoration: const InputDecoration(labelText: 'Nuevo Valor'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String nuevoParametro = newDataController.text.trim();
                try {
                  if (nuevoParametro == '') {
                    showCustomErrorDialog(context, '¡Digite un nuevo valor valido!');
                    return;
                  }
                  if (parametro == "Nombre") {
                    await supabase
                      .from('persona')
                      .update({'nombre_completo': nuevoParametro})
                      .match({'numero_documento': numeroDocumentoController.text});
                    cargarDatos();
                    Navigator.of(context).pop();
                  }

                  else if (parametro == "Usuario (Login)") {
                    await supabase
                    .from('empleado')
                    .update({'user_name': nuevoParametro})
                    .match({'id_user': idUser as Object});
                    cargarDatos();
                    Navigator.of(context).pop();
                  } 

                  else if (parametro == "Numero de documento"){
                    if (nuevoParametro.contains(RegExp(r'[a-zA-Z]'))){
                      showCustomErrorDialog(context, '¡El documento solo debe contener números!');
                      return;
                    }
                    else {
                      await supabase
                        .from('persona')
                        .update({'numero_documento': nuevoParametro})
                        .match({'numero_documento': numeroDocumentoController.text });
                      cargarDatos();
                      Navigator.of(context).pop();
                    }
                  }
                } catch (e) {
                  showCustomErrorDialog(context,e.toString());
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> actualizarEmail(String parametro) async {
    final TextEditingController newDataController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: EsquemaDeColores.background,
          title: Center(
            child: Text("Actualizar $parametro"),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                const Text(
                "Nota: Te va a llegar un correo de verificación. Tendrás 1 hora para abrirlo, de lo contrario se bloqueará tu cuenta.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: newDataController,
                decoration: const InputDecoration(labelText: 'Nuevo Correo'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String nuevoParametro = newDataController.text.trim();
                try {
                  if (parametro == "Email") {
                    if (validarEmail(nuevoParametro) != true) {
                      showCustomErrorDialog(context, "¡Digite un email valido!");
                      return;
                    }
                    try {
                      await supabase.auth.updateUser(
                        UserAttributes(
                        email: nuevoParametro,
                        ),
                      );
                    } catch (e) {
                      showCustomErrorDialog(context, 'Error al actualizar el correo');
                      return;
                    }
                    await supabase
                      .from('empleado')
                      .update({'correo_electronico': nuevoParametro})
                      .match({'user_name': userNameController.text });
                    cargarDatos();
                    Navigator.of(context).pop();
                  }
                  else {
                    return;
                  }
                } catch (e) {
                  showCustomErrorDialog(context,e.toString());
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  bool validarEmail(String email) {
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<void> actualizarScroll(String parametro) async {
    final Map<String, int> tipoDocumentoDic = {'C.C': 1, 'C.E': 2, 'R.C': 3, 'T.I': 4,};
    final Map<String, int> generoDic = {'Masculino': 1, 'Femenino': 2, 'Hemafrodita': 3, 'N.A': 4,};
    final List<String> listaGenero = ['Masculino', 'Femenino', 'Hemafrodita', 'N.A'];
    final List<String> listaTd = ['C.C', 'C.E', 'R.C', 'T.I'];
    List<String> lista;
    String dropdownValue;
    if(parametro == 'Genero'){
      lista = listaGenero;
    }
    else{
      lista = listaTd;
    }
    dropdownValue = lista.first;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: EsquemaDeColores.background,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              "Actualizar $parametro",
              textAlign: TextAlign.center,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [            
                DropdownButtonFormField<String>(
                  decoration:InputDecoration(
                    labelText: parametro,
                  ),
                  value: dropdownValue,
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  dropdownColor: EsquemaDeColores.background,
                  items: lista.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                          )),
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (parametro == 'Genero') {
                    await supabase
                      .from('persona')
                      .update({'id_sexo': generoDic[dropdownValue]})
                      .match({'numero_documento': numeroDocumentoController.text});
                    cargarDatos();
                    Navigator.of(context).pop();
                  }
                  else if (parametro == 'Tipo de Documento'){
                    await supabase
                      .from('persona')
                      .update({'id_tipo_documento': tipoDocumentoDic[dropdownValue]})
                      .match({'numero_documento': numeroDocumentoController.text});
                    cargarDatos();
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  showCustomErrorDialog(context, e.toString());
                }// Cierra el modal después de actualizar
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> actualizarFechaNac(String parametro) async {
    final TextEditingController newDate = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: EsquemaDeColores.background,
          title: Align(
          alignment: Alignment.center,
          child: Text(
            "Actualizar $parametro",
            textAlign: TextAlign.center,
          ),
        ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              TextField(
                  readOnly: true,
                  controller: newDate,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today_rounded),
                      labelText: "Select Date"), // InputDecoration
                  onTap: () async {
                    DateTime? pickeddate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1980),
                        lastDate: DateTime(2050));
                    if (pickeddate != null) {
                      setState(() {
                        newDate.text =
                            DateFormat("yyyy-MM-dd").format(pickeddate);
                      });
                    }
                  })
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try{
                 await supabase
                    .from('persona')
                    .update({'fecha_nacimiento': newDate.text})
                    .match({'numero_documento': numeroDocumentoController.text});
                    cargarDatos();
                    Navigator.of(context).pop();
                } catch (e) {
                  showCustomErrorDialog(context,e.toString());
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> actualizarPassword() async {
    if (userNameController.text == 'Admin') {
      showCustomErrorDialog(
          context, "¡La cuenta Admin NO puede ser actualizada!");
      return;
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PasswordDialog();
      },
    );
  }

  Future<void> cargarDatos() async {
    final User? user = supabase.auth.currentUser;
    final idUser = user?.id;

    final datosPersona = await supabase
        .from('empleado')
        .select('persona(*)')
        .eq("id_user", idUser as Object);

    final dicSexo = {
      1: "Masculino",
      2: "Femenino",
      3: "Hermafrodita",
      4: "N.A"
    };

    final dicTipoDocumento = {
      1: "C.C", 
      2: "C.E", 
      3: "R.C", 
      4: "T.I"};

    nameController.text = datosPersona[0]["persona"]["nombre_completo"] ?? "Null";
    sexoController.text = dicSexo[datosPersona[0]["persona"]["id_sexo"]] ?? "N.A";
    fechaNacimientoController.text = datosPersona[0]["persona"]["fecha_nacimiento"]?? "Null";
    numeroDocumentoController.text = datosPersona[0]["persona"]["numero_documento"];
    tipoDocumentoController.text = dicTipoDocumento[datosPersona[0]["persona"]["id_tipo_documento"]] ?? "NA";

    final datosEmpleado = await supabase
        .from('empleado')
        .select('user_name, correo_electronico')
        .eq("id_user", idUser as Object);

    userNameController.text = datosEmpleado[0]["user_name"] ?? "Null";
    emailController.text = datosEmpleado[0]["correo_electronico"] ;
  }
}

//Clase auxiliar para poder mostrar y esconder la nueva contraseña
class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key});

  @override
  PasswordDialogState createState() => PasswordDialogState();
}

class PasswordDialogState extends State<PasswordDialog> {
  bool obscureText = true;
  TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  
  @override
  Widget build(BuildContext context) {
      return AlertDialog(
        backgroundColor: EsquemaDeColores.background,
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            "Actualizar Contraseña",
            textAlign: TextAlign.center,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  child: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el modal
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.trim().length < 6) {
                showCustomErrorDialog(context, "¡La contraseña debe tener minimo 6 caracteres!");
                return;
              }
              try {
                  await supabase.auth.updateUser(
                    UserAttributes(
                    password: passwordController.text,
                    ),
                  );
                  showCustomExitDialog(context, "Actualización exitosa");
              } catch (e) {
                showCustomErrorDialog(context, e.toString());
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      );
    }
  }