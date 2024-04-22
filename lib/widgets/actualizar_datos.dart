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
        title: const Text('Actualizar Datos'),
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
                onPressed: actualizarTexto("nombre"),
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Correo Electrónico",
                controller: emailController,
                onPressed: actualizarTexto("nombre"),
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Genero",
                controller: sexoController,
                onPressed: actualizarTexto("nombre"),
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Fecha de nacimiento",
                controller: fechaNacimientoController,
                onPressed: actualizarTexto("nombre"),
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Tipo de documento",
                controller: tipoDocumentoController,
                onPressed: actualizarTexto("nombre"),
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Numero de documento",
                controller: numeroDocumentoController,
                onPressed: actualizarTexto("nombre"),
              ),
              const SizedBox(height: 18.0),
              _buildTextFieldWithButton(
                labelText: "Usuario",
            controller: userNameController,
            onPressed: actualizarTexto("nombre"),
          ),
          const SizedBox(height: 18.0),
          ElevatedButton(
            onPressed: () {
              // Aquí irá la lógica de actualización para todos los campos
              cargarDatos();
            },
            child: const Text('Actualizar'),
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
    required Future<void> onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
            ),
          ),
        ),
        const SizedBox(width: 10), // Añade un espacio entre el TextField y el botón
        ElevatedButton(
          onPressed: onPressed ??(){},
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
              onPressed: () {
                // Aquí puedes agregar la lógica para actualizar el nombre con el valor en _newNameController.text
                // Por ejemplo:
                String nuevoNombre = newDataController.text;
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

  Future<void> actualizarScroll() async {
    final TextEditingController newNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Actualizar Nombre"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newNameController,
                decoration: const InputDecoration(labelText: 'Nuevo Nombre'),
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

    nameController.text = datosPersona[0]["persona"]["nombre_completo"];
    sexoController.text = dicSexo[datosPersona[0]["persona"]["id_sexo"]] ?? "NA";
    fechaNacimientoController.text = datosPersona[0]["persona"]["fecha_nacimiento"];
    numeroDocumentoController.text = datosPersona[0]["persona"]["numero_documento"];
    tipoDocumentoController.text = dicTipoDocumento[datosPersona[0]["persona"]["id_tipo_documento"]] ??"NA";

    final datosEmpleado = await supabase
        .from('empleado')
        .select('user_name, correo_electronico')
        .eq("id_user", idUser as Object);

    userNameController.text = datosEmpleado[0]["user_name"];
    emailController.text = datosEmpleado[0]["correo_electronico"];
  }
}