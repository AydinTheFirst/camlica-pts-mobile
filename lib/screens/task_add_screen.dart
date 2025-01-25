import 'package:camlica_pts/components/map_click_tracker.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/app_config_model.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/models/unit_model.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/utils/utils.dart';
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
    final config = useQuery(["config"], getAppConfig);

    if (users.isLoading || units.isLoading || config.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (users.isError || units.isError || config.isError) {
      logger.e("users.error: ${users.error}");
      logger.e("units.error: ${units.error}");
      logger.e("config.error: ${config.error}");
      return Center(
        child: Text(
            "Bir hata oluştu:  ${users.error ?? units.error ?? config.error}"),
      );
    }

    if (users.data == null) {
      return Center(child: Text("Kullanıcılar bulunamadı"));
    }

    if (units.data == null) {
      return Center(child: Text("Birimler bulunamadı"));
    }

    if (config.data == null) {
      return Center(child: Text("Ayarlar bulunamadı"));
    }

    return TaskAddFormBody(
      users: users.data!,
      units: units.data!,
      config: config.data!,
    );
  }
}

class TaskAddFormBody extends HookWidget {
  final List<User> users;
  final List<Unit> units;
  final AppConfig config;

  const TaskAddFormBody({
    super.key,
    required this.users,
    required this.units,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final unitId = useState("");
    final title = useState("");
    final description = useState("");
    final status = useState<TaskStatus>(TaskStatus.PENDING);
    final selectedMap = useState<TaskMap>(
      config.maps.isEmpty ? TaskMap(url: "", title: "") : config.maps.first,
    );
    final locationX = useState(0.0);
    final locationY = useState(0.0);

    void handleSubmit() async {
      try {
        await HttpService.dio.post("/tasks", data: {
          "unitId": unitId.value,
          "title": title.value,
          "description": description.value,
          "status": status.value.name,
          "locationX": locationX.value,
          "locationY": locationY.value,
          "selectedMap": selectedMap.value.url,
        });
        logger.i("Task added");
        ToastService.success(message: "Görev eklendi");
        queryClient.invalidateQueries(["tasks"]);
        Get.toNamed("/tasks");
      } on DioException catch (e) {
        HttpService.handleError(e);
      } catch (e) {
        logger.e("Error adding task: $e");
        ToastService.error(message: "Görev eklenirken bir hata oluştu");
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: [
            Text(
              "Görev Ekle",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
                        child: Text(translateTaskStatus(status)),
                      ))
                  .toList(),
              onChanged: (value) => status.value = value!,
              value: TaskStatus.PENDING,
              decoration: InputDecoration(labelText: "Durum"),
            ),
            DropdownButtonFormField(
              items: config.maps
                  .map((map) => DropdownMenuItem(
                        value: map.url,
                        child: Text(map.title),
                      ))
                  .toList(),
              onChanged: (value) => selectedMap.value =
                  config.maps.firstWhere((map) => map.url == value),
              value: selectedMap.value.url,
              decoration: InputDecoration(labelText: "Seçili Harita"),
            ),
            MapClickTracker(
              selectedMap: selectedMap.value,
              onPositionSelected: ({required Map<String, double> position}) {
                locationX.value = position['x']!;
                locationY.value = position['y']!;
              },
            ),
            SizedBox(height: 20),
            StyledButton(
              onPressed: handleSubmit,
              fullWidth: true,
              child: Text("Görevi Ekle"),
            ),
          ],
        ),
      ),
    );
  }
}
