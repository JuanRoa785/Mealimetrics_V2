import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mealimetrics/widgets/custom_alert.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';

class ModalRecuperacionWidget extends StatefulWidget {
  const ModalRecuperacionWidget({super.key});

  @override
  State<ModalRecuperacionWidget> createState() =>
      _ModalRecuperacionWidgetState();
}

class _ModalRecuperacionWidgetState extends State<ModalRecuperacionWidget> {
  late TextEditingController _emailAddressController;
  late FocusNode _emailAddressFocusNode;

  @override
  void initState() {
    super.initState();
    _emailAddressController = TextEditingController();
    _emailAddressFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailAddressController.dispose();
    _emailAddressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 570),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E3E7)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Color(0xFF14181B),
                          fontSize: 25,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      iconSize: 24,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'No te preocupes, digita tu usuario a continuación:',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.black,
                    fontSize: 18,
                    letterSpacing: 0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailAddressController,
                  focusNode: _emailAddressFocusNode,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    labelStyle: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.black,
                      fontSize: 16,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Digite su usuario',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    //contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF101213),
                    fontSize: 16,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: 
                  FFButtonWidget(
                    onPressed: () {
                      final userName = _emailAddressController.text;
                      enviarCorreo(userName, context);
                    },
                    text: 'Enviar Correo',
                    options: FFButtonOptions(
                      width: 250,
                      height: 40,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String generarContrasena(){
  const String caracteres = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const int longMin = 6;
  const int longMax = 12;
  Random random = Random();
  int longitud = longMin + random.nextInt(longMax - longMin + 1);
  String contrasena = '';
  for (int i = 0; i < longitud; i++) {
    int indice = random.nextInt(caracteres.length);
    contrasena += caracteres[indice];
  }
  return contrasena;
}

void enviarCorreo(String userName, context) async {
  //Estos datos solo se muestran en desarrollo, a nivel de producción deben ser encriptados
  final supaAdmin = SupabaseClient('https://ddyveuettsjaxmdbijgb.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkeXZldWV0dHNqYXhtZGJpamdiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxMzA1MDgzNCwiZXhwIjoyMDI4NjI2ODM0fQ.FoRjsJj9d7R-XSkNN4hokmfmTG-mEcr2QuWWT9RFnxc');
  final String password = generarContrasena();
  try {
    if (userName == 'Admin') {
      showCustomErrorDialog(context, "¡No se puede recuperar la cuenta maestra!\n\nComuniquese con el administrador del sistema para obtener la contraseña.");
      return;
    }
    final datos = await Supabase.instance.client
        .from('empleado')
        .select('id_user, correo_electronico')
        .eq("user_name", userName);
    if (datos.length == 1) {
      try {
        await supaAdmin.auth.admin.updateUserById(
          datos[0]['id_user'],
          attributes: AdminUserAttributes(
            password: password,
          ),
        );
      } catch (e) {
        showCustomErrorDialog(context, e.toString());
        return;
      }

      //Enviar el Correo
      final correoAEnviar = datos[0]['correo_electronico'].toString();
      final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
      const serviceId = "service_1yeeknn";
      const templateId = "template_hu4ne38";
      const userId = "NNbgVVCzlKNUVd3PA";
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "service_id": serviceId,
            "template_id": templateId,
            "user_id": userId,
            "template_params": {
              "email_to": correoAEnviar,
              "password": password
            }
          }));
      if (response.statusCode == 200) {
        showCustomExitDialog(context, "Se envió el correo de recuperación a: \n\n$correoAEnviar");
      } else {
        showCustomErrorDialog(context, "Sucedio un error al enviar el correo de recuperación a: \n\n$correoAEnviar");
      }
    } else {
      showCustomErrorDialog(context, "El usuario proporcionado NO tiene una cuenta asociada a Mealimetrics");
    }
  } catch (e) {
    showCustomErrorDialog(context, e.toString());
  }
}
