import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  //final Color backgroundColor;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    //required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //backgroundColor: backgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Icon(
              icon,
              color: iconColor,
              size: 110,
          ),
        ],
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

void showCustomErrorDialog(BuildContext context, String error) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: 'Error',
        message: error,
        icon: Icons.error,
        iconColor: Colors.red,
        //backgroundColor: Colors.white,
      );
    },
  );
}

void showCustomExitDialog(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: 'Éxito',
        message: mensaje,
        icon: Icons.check_circle, // Icono de marca de verificación para indicar éxito
        iconColor: Colors.green, // Color del icono para indicar éxito
        //backgroundColor: Colors.white, // Color de fondo del diálogo
      );
    },
  );
}