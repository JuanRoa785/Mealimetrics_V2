import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        title: const Text('Actualizar Datos'),
        backgroundColor: const Color.fromARGB(255, 111, 209, 254),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                onPressed: actualizarTexto,
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
                parametro: "Fecha de Nacimiento",
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
          onPressed: () => onPressed(parametro),
          child: const Icon(Icons.update), // Puedes cambiar el icono o el texto según prefieras
        ),
      ],
    );
  }

  Future<void> actualizarTexto(String parametro) async {
    final TextEditingController newDataController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Actualizar $parametro"),
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
                // Aquí puedes agregar la lógica para actualizar el nombre con el valor en _newNameController.text
                // Por ejemplo:
                String nuevoNombre = newDataController.text;
                try {
                final response = await supabase
                .from('persona')
                .update({'nombre_completo': nuevoNombre})
                .match({'numero_documento': numeroDocumentoController.text });
                cargarDatos();
                } catch (e) {
                  print(e.toString());

                }
                Navigator.of(context)
                    .pop(); // Cierra el modal después de actualizar
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> actualizarScroll(String parametro) async {
    final TextEditingController newNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Actualizar $parametro"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newNameController,
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
              onPressed: () {
                // Aquí puedes agregar la lógica para actualizar el nombre con el valor en _newNameController.text
                // Por ejemplo:
                String nuevoNombre = newNameController.text;
                Navigator.of(context)
                    .pop(); // Cierra el modal después de actualizar
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> actualizarFechaNac(String parametro) async {
    final TextEditingController newNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Actualizar $parametro"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newNameController,
                decoration: const InputDecoration(labelText: 'Nueva Fecha'),
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
              onPressed: () {
                // Aquí puedes agregar la lógica para actualizar el nombre con el valor en _newNameController.text
                // Por ejemplo:
                String nuevoNombre = newNameController.text;
                Navigator.of(context)
                    .pop(); // Cierra el modal después de actualizar
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
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