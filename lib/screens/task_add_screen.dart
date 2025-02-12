import 'dart:convert';

import 'package:camlica_pts/components/map_click_tracker.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/app_config_model.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/unit_model.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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

final configProvider = AutoDisposeFutureProvider((ref) async {
  final data = await HttpService.fetcher("/config");
  return data;
});

final unitsProvider = AutoDisposeFutureProvider((ref) async {
  final data = await HttpService.fetcher("/units");
  return data;
});

final usersProvider = AutoDisposeFutureProvider((ref) async {
  final data = await HttpService.fetcher("/users");
  return data;
});

class TaskAddForm extends ConsumerWidget {
  const TaskAddForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configRef = ref.watch(configProvider);
    final usersRef = ref.watch(usersProvider);
    final unitsRef = ref.watch(unitsProvider);

    final config = configRef.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );

    final users = usersRef.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );

    final units = unitsRef.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );

    if (config == null || users == null || units == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    logger.d("TaskAddForm: $config");
    logger.d("TaskAddForm: $users");
    logger.d("TaskAddForm: $units");

    return TaskAddFormBody(
      users: (users as List<dynamic>)
          .map<User>((user) => User.fromJson(user as Map<String, dynamic>))
          .toList(),
      units: (units as List<dynamic>)
          .map<Unit>((unit) => Unit.fromJson(unit as Map<String, dynamic>))
          .toList(),
      config: AppConfig.fromJson(config as Map<String, dynamic>),
    );
  }
}

class TaskAddFormBody extends HookWidget {
  final List<User> users;
  final List<Unit> units;
  final AppConfig config;

  final _formKey = GlobalKey<FormBuilderState>();

  TaskAddFormBody({
    super.key,
    required this.users,
    required this.units,
    required this.config,
  });

  void handleSubmit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    final data = _formKey.currentState!.value;

    final selectedMap = jsonEncode(config.maps.firstWhere(
      (map) => map.url == data["selectedMap"],
    ));

    try {
      await HttpService.dio.post("/tasks", data: {
        ...data,
        "locationX": double.parse(data["locationX"]),
        "locationY": double.parse(data["locationY"]),
        "selectedMap": selectedMap,
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

  @override
  Widget build(BuildContext context) {
    final locationX = useState(0.0);
    final locationY = useState(0.0);
    final selectedMap = useState(config.maps.first.url);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            spacing: 10,
            children: [
              Text(
                "Görev Ekle",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              FormBuilderDropdown(
                name: "unitId",
                decoration: InputDecoration(
                  labelText: "Birim",
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()],
                ),
                items: units.map((unit) {
                  return DropdownMenuItem(
                    value: unit.id,
                    child: Text(unit.name),
                  );
                }).toList(),
              ),
              FormBuilderTextField(
                name: "title",
                decoration: InputDecoration(
                  labelText: "Başlık",
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()],
                ),
              ),
              FormBuilderTextField(
                name: "description",
                decoration: InputDecoration(
                  labelText: "Açıklama",
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()],
                ),
                maxLines: 3,
              ),
              FormBuilderDropdown(
                initialValue: TaskStatus.PENDING.name,
                name: "status",
                decoration: InputDecoration(
                  labelText: "Durum",
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()],
                ),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status.name,
                    child: Text(translateTaskStatus(status)),
                  );
                }).toList(),
              ),
              FormBuilderDropdown(
                initialValue: selectedMap.value,
                name: "selectedMap",
                decoration: InputDecoration(
                  labelText: "Harita",
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()],
                ),
                onChanged: (value) => selectedMap.value = value.toString(),
                items: config.maps.map((map) {
                  return DropdownMenuItem(
                    value: map.url,
                    child: Text(map.title),
                  );
                }).toList(),
              ),
              selectedMap.value != ""
                  ? MapClickTracker(
                      selectedMap: config.maps.firstWhere(
                        (map) => map.url == selectedMap.value,
                      ),
                      onPositionSelected: (
                          {required Map<String, double> position}) {
                        locationX.value = position['x']!;
                        locationY.value = position['y']!;
                      },
                    )
                  : SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("X: ${locationX.value}"),
                  Text("Y: ${locationY.value}"),
                ],
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
      ),
    );
  }
}
