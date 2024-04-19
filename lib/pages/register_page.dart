import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

List<String> listaRoles = ['Gerente', 'Mesero', 'Encargado De Cocina'];
String dropdownValue = listaRoles.first;

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 126, 227, 252),
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
                          width: double.infinity, // Ajusta el ancho al máximo
                          constraints: const BoxConstraints(maxWidth: 400), // Ajusta el ancho máximo
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: dropdownValue,
                            onChanged: (String? value) {
                              setState(() {
                                dropdownValue = value!;
                              });
                            },
                            items: listaRoles.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0), // Margen izquierdo
                                  child: Text(value, 
                                  style: const TextStyle(fontWeight: FontWeight.normal)
                                  ),
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
                      onPressed: () {},
                      text: 'Registrarse',
                      options: FFButtonOptions(
                        width: 230,
                        height: 42,
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
        type: 'Email'
        );
  }

    Widget _textFieldEmail() {
    return _TextFieldGeneral(
        labelText: "Correo Electronico",
        keyboardType: TextInputType.emailAddress,
        icon: Icons.email_outlined,
        hintText: "Digite su email",
        onChanged: (value) {},
        type: 'Email'
        );
  }

  Widget _textFieldUserName() {
    return _TextFieldGeneral(
        labelText: "Usuario",
        keyboardType: TextInputType.text,
        icon: Icons.person_outline,
        hintText: "Digite su usuario",
        onChanged: (value) {},
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
        type: 'password');
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

  const _TextFieldGeneral({
    required this.labelText,
    this.hintText,
    required this.onChanged,
    this.keyboardType,
    required this.icon,
    this.obscureText = false,
    required this.type,
  });

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
      );
    }
  }
}
