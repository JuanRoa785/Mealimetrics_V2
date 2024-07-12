import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mealimetrics/Styles/color_scheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

List<String> listaRoles = ['Gerente', 'Mesero', 'Chef'];
List<String> listaTipoDocumento = ['C.C', 'C.E', 'R.C', 'T.I'];
String dropdownValueR = listaRoles.first;
String dropdownValueTD = listaTipoDocumento.first;

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final TextEditingController documentoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: EsquemaDeColores.backgroundSecondary,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Crear una cuenta",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Por favor complete el formulario:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  _textFieldName(),
                  _tipoDocumentoField(),
                  const SizedBox(
                    height: 18.0,
                  ),
                  _documentoField(),
                  const SizedBox(
                    height: 18.0,
                  ),
                  _textFieldEmail(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 22.0, top: 8.0),
                        child: Text(
                          'Defina su rol:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: Container(
                          width: double.infinity,
                          height: 60, // Ajusta el ancho al máximo
                          constraints: const BoxConstraints(
                              maxWidth: 400), // Ajusta el ancho máximo
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: dropdownValueR,
                            onChanged: (String? value) {
                              setState(() {
                                dropdownValueR = value!;
                              });
                            },
                            dropdownColor: Colors.white,
                            items: listaRoles.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0), // Margen izquierdo
                                  child: Text(value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                      )),
                                ),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  _textFieldUserName(),
                  const SizedBox(
                    height: 18.0,
                  ),
                  _textFieldContrasena(),
                  const SizedBox(
                    height: 18.0,
                  ),
                  _textFieldRepitaContrasena(),
                  const SizedBox(
                    height: 18.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22.0),
                    child: FFButtonWidget(
                      onPressed: () => registrarse(context),
                      text: 'Registrarse',
                      options: FFButtonOptions(
                        width: 230,
                        height: 42,
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: const Color(0xFF4B39EF),
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
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
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _textFieldName() {
    return _TextFieldGeneral(
        labelText: "Nombre Completo",
        keyboardType: TextInputType.text,
        icon: Icons.abc,
        hintText: "Digite su nombre",
        onChanged: (value) {},
        controller: nameController,
        type: 'Email');
  }

  Widget _textFieldEmail() {
    return _TextFieldGeneral(
        labelText: "Correo Electronico",
        keyboardType: TextInputType.emailAddress,
        icon: Icons.email_outlined,
        hintText: "Digite su email",
        onChanged: (value) {},
        controller: emailController,
        type: 'Email');
  }

  Widget _documentoField() {
    return _TextFieldGeneral(
      labelText: "Documento",
      keyboardType: TextInputType.text,
      icon: Icons.credit_card,
      hintText: "Digite su número de Documento",
      onChanged: (value) {},
      controller: documentoController,
      type: 'Text',
    );
  }

  Widget _tipoDocumentoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 22.0, top: 8.0),
          child: Text(
            'Tipo de Documento:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Container(
            width: double.infinity,
            height: 60, // Ajusta el ancho al máximo
            constraints:
                const BoxConstraints(maxWidth: 400), // Ajusta el ancho máximo
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonFormField<String>(
              value: dropdownValueTD,
              onChanged: (String? value) {
                setState(() {
                  dropdownValueTD = value!;
                });
              },
              dropdownColor: Colors.white,
              items: listaTipoDocumento.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0), // Margen izquierdo
                    child: Text(value,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        )),
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textFieldUserName() {
    return _TextFieldGeneral(
        labelText: "Usuario",
        keyboardType: TextInputType.text,
        icon: Icons.person_outline,
        hintText: "Digite su usuario",
        onChanged: (value) {},
        controller: userNameController,
        type: 'UserName');
  }

  Widget _textFieldContrasena() {
    return _TextFieldGeneral(
        labelText: "Contraseña",
        keyboardType: TextInputType.visiblePassword,
        icon: Icons.lock_outline_rounded,
        hintText: "Digite su Contraseña",
        obscureText: true,
        onChanged: (value) {},
        controller: passwordController,
        type: 'password');
  }

  Widget _textFieldRepitaContrasena() {
    return _TextFieldGeneral(
        labelText: "Repita la Contraseña",
        keyboardType: TextInputType.visiblePassword,
        icon: Icons.lock_outline_rounded,
        hintText: "Repita su Contraseña",
        obscureText: true,
        onChanged: (value) {},
        controller: repeatPasswordController,
        type: 'password');
  }

  bool validarEmail(String email) {
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<void> registrarse(context) async {
    final supabase = Supabase.instance.client;

    Map<String, int> tipoDocumento = {
      'C.C': 1,
      'C.E': 2,
      'R.C': 3,
      'T.I': 4,
    };

    try {
      if (nameController.text == "" ||
          documentoController.text == "" ||
          emailController.text == "" ||
          userNameController.text == "" ||
          passwordController.text == "" ||
          repeatPasswordController.text == "") {
        showCustomErrorDialog(context, "¡Por favor llenar todos los campos del formulario!");
        return;
      }
      if (validarEmail(emailController.text.trim()) != true) {
        showCustomErrorDialog(context, "¡Digite un email valido!");
        return;
      }
      if (passwordController.text.length < 6 ||
          repeatPasswordController.text.length < 6) {
        showCustomErrorDialog(
            context, "¡Las contraseñas deben tener minimo 6 caracteres!");
        return;
      }
      if (passwordController.text.trim() != repeatPasswordController.text.trim()) {
        showCustomErrorDialog(context, "Las contraseñas no coinciden");
        return;
      }

      if (documentoController.text.trim().contains(RegExp(r'[a-zA-Z]'))){
        showCustomErrorDialog(context, '¡El documento solo debe contener números!');
        return;
      }

      try {
        final verificacion1 = await supabase
            .from('empleado')
            .select('persona(numero_documento)')
            .eq("user_name", userNameController.text.trim());

        final verificacion2 = await supabase
            .from('persona')
            .select('numero_documento')
            .eq("numero_documento", documentoController.text.trim());
        
        //Si el empleado ya existe devuelve error.
        if (verificacion1.isNotEmpty) {
          showCustomErrorDialog(context, '¡Ese nombre de usuario ya esta registrado!');
          return;
        }
        //si un empleado con diferente user_name se quiere escribir manda error
        if (verificacion2.isNotEmpty){
          showCustomErrorDialog(context, '¡Existe un usuario registrado con ese número de documento!');
          return;
        }
      } catch (e) {
        showCustomErrorDialog(context, '¡Error interno de la DB!');
        return;
      }

      try {
        //Se genera el usuario
        await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } catch (e) {
        showCustomErrorDialog(context, "¡Ya existe un usuario registrado con ese correo electronico!");
        return;
      }

      try {
        //si crear el usuario no da error, se inserta la persona
        await supabase.from('persona').insert({
          'nombre_completo': nameController.text.trim(),
          'id_tipo_documento': tipoDocumento[dropdownValueTD],
          'numero_documento': documentoController.text.trim()
        });
      } catch (e) {
        showCustomErrorDialog(context, e.toString());
        return;
      }

      try {
          final idPersona = await supabase
          .from('persona')
          .select('id')
          .eq('numero_documento', documentoController.text.trim());

        //En base al usuario y a la persona se crea el empleado
        final User? user = supabase.auth.currentUser;
        await supabase.from('empleado').insert({
          'correo_electronico': emailController.text.trim(),
          'user_name': userNameController.text.trim(),
          'id_persona': idPersona[0]['id'],
          'rol': dropdownValueR,
          'id_user': user?.id
        });

        //Al registrarse, inicia sesion, por lo que instantaneamente se cierra
        await supabase.auth.signOut();
        showCustomExitDialog(context, "¡Se creo el usuario Exitosamente!");
        _limpiarCampos();
      } catch (e) {
        showCustomErrorDialog(context, e.toString());
      }

    } catch (e) {
      showCustomErrorDialog(context, e.toString());
      return;
    }
  }

  void _limpiarCampos() {
    nameController.clear();
    emailController.clear();
    userNameController.clear();
    passwordController.clear();
    repeatPasswordController.clear();
    documentoController.clear();
  }
}

class _TextFieldGeneral extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final IconData icon;
  final bool obscureText;
  final String type;
  final TextEditingController controller;

  const _TextFieldGeneral(
      {required this.labelText,
      this.hintText,
      required this.onChanged,
      this.keyboardType,
      required this.icon,
      this.obscureText = false,
      required this.type,
      required this.controller});

  @override
  _TextFieldGeneralState createState() => _TextFieldGeneralState();
}

class _TextFieldGeneralState extends State<_TextFieldGeneral> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 22.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _obscureText,
        decoration: _buildInputDecoration(),
        onChanged: widget.onChanged,
      ),
    );
  }

//Permite Mostrar o Esconder la Contraseña
  InputDecoration _buildInputDecoration() {
    if (widget.type == 'password') {
      return InputDecoration(
        prefixIcon: Icon(widget.icon),
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: InputBorder.none,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      return InputDecoration(
        prefixIcon: Icon(widget.icon),
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: InputBorder.none
      );
    }
  }
}
