//import 'package:animated_text_kit/animated_text_kit.dart';
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:mealimetrics/pages/home_chef.dart';
import 'package:mealimetrics/pages/home_mesero.dart';
import 'package:mealimetrics/pages/modal_recuperacion.dart';
import 'package:mealimetrics/pages/home_gerente.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mealimetrics/widgets/home_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:mealimetrics/Styles/color_scheme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState(){
    super.initState();
    cerrarSesiones();
    _redirect();
  }

  final supabase = Supabase.instance.client;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

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
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "¡Bienvenido de vuelta!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Digite sus credenciales:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,       
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  _textFieldUserName(),
                  SizedBox(
                    height: 30.0,
                  ),
                  _textFieldContrasena(),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  FFButtonWidget(
                    onPressed: () => signIn(context),
                    text: 'Iniciar Sesion',
                    options: FFButtonOptions(
                      width: 230,
                      height: 52,
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
                  SizedBox(
                    height: 3.0,
                  ),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: MediaQuery.of(context).size.height *0.5, // Ajusta el ancho según tu preferencia
                                child: Card(
                                  child: ModalRecuperacionWidget(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: Text('Olvidaste Tu contraseña?',
                          style: TextStyle(
                              color: Color.fromARGB(255, 25, 0, 255),
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold))),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _textFieldUserName() {
    return _TextFieldGeneral(
        labelText: "Usuario",
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
        controller: passwordController,
        onChanged: (value) {},
        type: 'password');
  }

 Future<void> _redirect() async{
  await Future.delayed(Duration.zero);
  final session = supabase.auth.currentSession;
  final user = supabase.auth.currentUser;
  if (session != null && user != null){
    try {
      //obtenemos el rol del usuario que inició sesion
      final rol = await supabase
        .from('empleado')
        .select('rol')
        .eq('id_user', user.id);

      if(rol.length != 1){
        showCustomErrorDialog(context, 'Error interno de la base de datos (Mas de un Match)');
        return;
      }
      //Enrutamiento a partir del rol
      switch (rol[0]['rol']) {
        case 'Gerente':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeGerente()));
          break;
        case 'Mesero':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeMesero()));
          break;
        case 'Chef':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeChef()));
          break;
        case 'Admin':
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          break;
        default:
          showCustomErrorDialog(context, '¡Rol Desconocido!, por favor comuniquese con la logitstica de Mealimetrics');
      }
    } catch (e) {
      showCustomErrorDialog(context, 'Ha ocurrido un error al redireccionarte, ¡intentalo nuevamente!');
    }
  }
 }

  void cerrarSesiones(){
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    if (session!=null) {
      supabase.auth.signOut();
    } 
  }

 Future<void> signIn(BuildContext context) async {
    try {
      if(userNameController.text == '' || passwordController.text == ''){
        showCustomErrorDialog(context, "¡Por favor llenar todos los campos del formulario!");
        return;
      }
      if(passwordController.text.length < 6){
        showCustomErrorDialog(context, "¡La contraseña debe tener minimo 6 caracteres!");
        return;
      }

      //Consulta para ver si el usuario esta registrado:
      final usuario = userNameController.text.trim();
      final datos = await supabase
      .from('empleado')
      .select('correo_electronico, estado_cuenta')
      .eq('user_name', usuario);

      if(datos.length == 1){ 
        try {
          //Verificar que el usuario este activo
          if (datos[0]['estado_cuenta'] != 'Activo') {
            showCustomErrorDialog(context, '¡Su usuario fue desactivado! \n\nComuniquese con el gerente de la sucursal para activarlo nuevamente');
            return;
          }
          //Sign In por medio de auth - Supabase
          await supabase.auth.signInWithPassword(
            password: passwordController.text,
            email: datos[0]['correo_electronico']
          );
          _redirect();
        } catch (e) {
          showCustomErrorDialog(context, "¡Contraseña Incorrecta, Intentelo Nuevamente!");
        }
      }
      else {
        showCustomErrorDialog(context, "El usuario '$usuario' NO esta registrado en el sistema de Mealimetrics. \n\n¡Porfavor registrese!");
        return;
      }
    } on Exception catch (e) {
      final error = e.toString();
      showCustomErrorDialog(context, "Ha ocurrido un error Inesperado: \n\n$error");
    }
  }
}

// ignore: camel_case_types
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
      margin: EdgeInsets.symmetric(
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
