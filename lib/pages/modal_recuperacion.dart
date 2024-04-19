import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

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
                          fontSize: 24,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
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
                const SizedBox(height: 4),
                const Text(
                  'No te preocupes, digita tu usuario a continuación:',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Color(0xFF57636C),
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
                      color: Color(0xFF57636C),
                      fontSize: 16,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Digite su usuario',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
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
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      final userName = _emailAddressController.text;
                      enviarCorreo(userName, context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Enviar Correo',
                      style: TextStyle(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                      ),
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

void enviarCorreo(String userName, context) async {
  try {
    final datos = await Supabase.instance.client
        .from('empleado')
        .select('id_user, correo_electronico')
        .eq("user_name", userName);

    if (datos.length == 1) {
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
              "password": datos[0]['contrasena'].toString()
            }
          }));
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Correo Enviado!"),
              content: Text(
                "Se envió el correo de recuperación a: \n\n$correoAEnviar",
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text("Aceptar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Cerrar la alerta
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error Envio Correo"),
              content: Text(
                "Sucedio un error al enviar el correo de recuperación a: \n\n$correoAEnviar",
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text("Aceptar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Cerrar la alerta
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
              "El usuario proporcionado NO tiene una cuenta asociada a Mealimetrics",
              style: TextStyle(
                fontSize: 18,
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("Aceptar"),
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar la alerta
                },
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(
            e.toString(),
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 0,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar la alerta
              },
            ),
          ],
        );
      },
    );
  }
}
