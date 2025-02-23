import 'dart:convert';

import 'package:camlica_pts/components/map_click_tracker.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/app_config_model.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/unit_model.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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

class TaskAddFormBody extends ConsumerStatefulWidget {
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
  ConsumerState<TaskAddFormBody> createState() => _TaskAddFormBodyState();
}

class _TaskAddFormBodyState extends ConsumerState<TaskAddFormBody> {
  final _formKey = GlobalKey<FormBuilderState>();

  final locationX = ValueNotifier<double>(0);
  final locationY = ValueNotifier<double>(0);
  final selectedMap = ValueNotifier<String>("");

  void handleSubmit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    final data = _formKey.currentState!.value;

    logger.d("TaskAddFormBody: $data");

    final selectedMap = widget.config.maps.firstWhere(
      (map) => map.url == data["selectedMap"],
    );

    try {
      await HttpService.dio.post("/tasks", data: {
        ...data,
        "selectedMap": jsonEncode(selectedMap),
        "locationX": locationX.value,
        "locationY": locationY.value,
      });
      logger.i("Task added");
      ToastService.success(message: "Görev eklendi");
      ref.invalidate(tasksProvider);
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
                items: widget.units.map((unit) {
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
                items: widget.config.maps.map((map) {
                  return DropdownMenuItem(
                    value: map.url,
                    child: Text(map.title),
                  );
                }).toList(),
              ),
              ValueListenableBuilder<String>(
                valueListenable: selectedMap,
                builder: (context, value, child) {
                  return value != ""
                      ? MapClickTracker(
                          selectedMap: widget.config.maps.firstWhere(
                            (map) => map.url == value,
                          ),
                          onPositionSelected: (
                              {required Map<String, double> position}) {
                            locationX.value = position['x']!;
                            locationY.value = position['y']!;
                          },
                        )
                      : SizedBox.shrink();
                },
              ),
              ValueListenableBuilder(
                valueListenable: locationX,
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("X: ${locationX.value}"),
                      Text("Y: ${locationY.value}"),
                    ],
                  );
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
      ),
    );
  }
}
