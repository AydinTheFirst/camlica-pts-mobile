import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Emin misin?"),
            content: const Text("Bu işlemi yapmak istediğinden emin misin?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Hayır"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Evet"),
              ),
            ],
          );
        },
      ) ??
      false;
}
