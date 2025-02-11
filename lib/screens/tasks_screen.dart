import 'package:camlica_pts/components/task_card.dart';
import 'package:camlica_pts/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:get/get.dart';
import '/models/enums.dart';

class TasksScreen extends HookWidget {
  const TasksScreen({super.key});

  void onPressed() {
    Get.toNamed("/tasks/add");
  }

  @override
  Widget build(BuildContext context) {
    final profile = useQuery(["profile"], getProfile);

    final bool isAdminOrManager = profile.data != null &&
        (profile.data!.roles.contains(UserRole.MANAGER) ||
            profile.data!.roles.contains(UserRole.ADMIN));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevler'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const TasksTab(),
      floatingActionButton: isAdminOrManager
          ? FloatingActionButton(
              onPressed: onPressed,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusTabs = {
      TaskStatus.PENDING: "Bekleyen",
      TaskStatus.IN_PROGRESS: "Devam Eden",
      TaskStatus.DONE: "Tamamlanan",
      TaskStatus.APPROVED: "Onaylanan",
      TaskStatus.REJECTED: "Reddedilen",
    };

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Colors.grey,
          tabs: statusTabs.values.map((label) => Tab(text: label)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: statusTabs.keys.map((status) {
              return TaskList(state: status);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class TaskList extends HookWidget {
  final TaskStatus state;

  const TaskList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tasks = useQuery(["tasks"], getTasks);
    final profile = useQuery(["profile"], getProfile);

    if (tasks.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isError) {
      return Center(child: Text("Bir hata oluştu: ${tasks.error}"));
    }

    final taskData = tasks.data;
    if (taskData == null || taskData.isEmpty) {
      return const Center(child: Text("Görev bulunamadı"));
    }

    final user = profile.data;

    // Filtreleme işlemi
    final filteredTasks = taskData.where((task) {
      switch (state) {
        case TaskStatus.PENDING:
          return task.status == TaskStatus.PENDING &&
              task.unitId == user?.unitId;
        case TaskStatus.IN_PROGRESS:
          return task.status == TaskStatus.IN_PROGRESS &&
              task.assignedToId == user?.id;
        case TaskStatus.DONE:
          return task.status == TaskStatus.DONE &&
              task.assignedToId == user?.id;
        case TaskStatus.APPROVED:
          return task.status == TaskStatus.APPROVED &&
              task.assignedToId == user?.id;
        case TaskStatus.REJECTED:
          return task.status == TaskStatus.REJECTED &&
              task.unitId == user?.unitId;
      }
    }).toList();

    if (filteredTasks.isEmpty) {
      return const Center(child: Text("Filtrelere uygun görev bulunamadı"));
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return TaskCard(task: filteredTasks[index]);
      },
    );
  }
}
