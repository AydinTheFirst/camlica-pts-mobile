import 'package:camlica_pts/components/map_click_tracker.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/unit_model.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:get/get.dart';

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

class TaskAddFormBody extends HookWidget {
  final List<User> users;
  final List<Unit> units;

  const TaskAddFormBody({
    super.key,
    required this.users,
    required this.units,
  });

  void onAddTask({
    required String unitId,
    required String title,
    required String description,
    required TaskStatus status,
    required double locationX,
    required double locationY,
  }) async {
    if (unitId.isEmpty ||
        title.isEmpty ||
        description.isEmpty ||
        locationX == 0.0 ||
        locationY == 0.0) {
      ToastService.error(message: "Lütfen tüm alanları doldurun");
      return;
    }

    try {
      await HttpService.dio.post("/tasks", data: {
        "unitId": unitId,
        "title": title,
        "description": description,
        "status": status.index,
        "locationX": locationX,
        "locationY": locationY,
      });
      logger.i("Task added");
      ToastService.success(message: "Görev eklendi");
      queryClient.invalidateQueries(["tasks"]);
      Get.toNamed("/tasks");
    } on DioException catch (e) {
      HttpService.handleError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitId = useState("");
    final title = useState("");
    final description = useState("");
    final status = useState<TaskStatus>(TaskStatus.PENDING);
    final locationX = useState(0.0);
    final locationY = useState(0.0);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: [
            Text("Görev Ekle",
                style: Theme.of(context).textTheme.headlineMedium),
            /*         DropdownButtonFormField<User>(
              items: users
                  .map((user) => DropdownMenuItem(
                        value: user,
                        child: Text("${user.firstName} ${user.lastName}"),
                      ))
                  .toList(),
              onChanged: (value) => assignedById.value = value!.id,
              decoration: InputDecoration(labelText: "Atayan Kullanıcı"),
            ),
            DropdownButtonFormField<User>(
              items: users
                  .map((user) => DropdownMenuItem(
                        value: user,
                        child: Text("${user.firstName} ${user.lastName}"),
                      ))
                  .toList(),
              onChanged: (value) => assignedToId.value = value!.id,
              decoration: InputDecoration(labelText: "Kullanıcı"),
            ), */

            DropdownButtonFormField<Unit>(
              items: units
                  .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit.name),
                      ))
                  .toList(),
              validator: (value) {
                if (value == null) {
                  return "Birim seçiniz";
                }

                return null;
              },
              onChanged: (value) => unitId.value = value!.id,
              decoration: InputDecoration(labelText: "Birim"),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Başlık"),
              validator: (value) => value == null ? "Başlık giriniz" : null,
              onChanged: (value) => title.value = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Açıklama"),
              validator: (value) => value == null ? "Açıklama giriniz" : null,
              onChanged: (value) => description.value = value,
              maxLines: 3,
            ),
            DropdownButtonFormField<TaskStatus>(
              items: TaskStatus.values
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      ))
                  .toList(),
              onChanged: (value) => status.value = value!,
              value: TaskStatus.PENDING,
              decoration: InputDecoration(labelText: "Durum"),
            ),
            MapClickTracker(
              onPositionSelected: ({required Map<String, double> position}) {
                locationX.value = position['x']!;
                locationY.value = position['y']!;
              },
            ),
            SizedBox(height: 20),
            StyledButton(
              onPressed: () {
                onAddTask(
                  unitId: unitId.value,
                  title: title.value,
                  description: description.value,
                  status: status.value,
                  locationX: locationX.value,
                  locationY: locationY.value,
                );
              },
              child: Text("Görevi Ekle"),
            ),
          ],
        ),
      ),
    );
  }
}
