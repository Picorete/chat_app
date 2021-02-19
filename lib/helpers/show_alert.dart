import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

showAlert(BuildContext context, String titulo, String subtitle) {
  if (Platform.isAndroid) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(titulo),
              content: Text(subtitle),
              actions: [
                MaterialButton(
                  child: Text('Ok'),
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
            title: Text(titulo),
            content: Text(subtitle),
            actions: [
              CupertinoDialogAction(
                child: Text('Ok'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ));
}
