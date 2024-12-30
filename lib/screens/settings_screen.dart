import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final TextEditingController serverAddress = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text("Ayarlar"),
              Row(
                children: [
                  Text("Sunucu Adresi"),
                  TextField(
                    controller: serverAddress,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
