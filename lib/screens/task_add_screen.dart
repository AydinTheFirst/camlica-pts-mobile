import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/unit_model.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';

class TaskAddScreen extends StatelessWidget {
  const TaskAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev Ekle'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: TaskAddForm(),
    );
  }
}

class TaskAddForm extends HookWidget {
  const TaskAddForm({super.key});

  @override
  Widget build(BuildContext context) {
    final units = useQuery(["units"], getUnits);
    final users = useQuery(["users"], getUsers);

    if (users.isLoading || units.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (users.isError || units.isError) {
      logger.e("users.error: ${users.error}");
      logger.e("units.error: ${units.error}");
      return Center(
        child: Text("Bir hata oluştu:  ${users.error ?? units.error}"),
      );
    }

    if (users.data == null) {
      return Center(child: Text("Kullanıcılar bulunamadı"));
    }

    if (units.data == null) {
      return Center(child: Text("Birimler bulunamadı"));
    }

    return TaskAddFormBody(users: users.data!, units: units.data!);
  }
}

class TaskAddFormBody extends StatelessWidget {
  final List<User> users;
  final List<Unit> units;

  const TaskAddFormBody({
    super.key,
    required this.users,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<User>(
          items: users
              .map((user) => DropdownMenuItem(
                    value: user,
                    child: Text("${user.firstName} ${user.lastName}"),
                  ))
              .toList(),
          onChanged: (value) {},
          decoration: InputDecoration(labelText: "Kullanıcı"),
        ),
        DropdownButtonFormField<Unit>(
          items: units
              .map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(unit.name),
                  ))
              .toList(),
          onChanged: (value) {},
          decoration: InputDecoration(labelText: "Birim"),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: "Başlık"),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: "Açıklama"),
          maxLines: 3,
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text("Görevi Ekle"),
        ),
      ],
    );
  }
}
