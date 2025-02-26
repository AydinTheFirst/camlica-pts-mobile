import 'package:camlica_pts/components/task_card.dart';
import 'package:camlica_pts/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '/models/enums.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  void onPressed() {
    Get.toNamed("/admin/task-add");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    final profile = profileAsync.maybeWhen(
      orElse: () => null,
      data: (data) => data,
    );

    final bool isAdmin = profile?.roles.contains(UserRole.ADMIN) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevler'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const TasksTab(),
      floatingActionButton: isAdmin
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

class TaskList extends ConsumerWidget {
  final TaskStatus state;

  const TaskList({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    final tasks = tasksAsync.maybeWhen(
      orElse: () => [],
      data: (data) => data,
    );

    // Filtreleme işlemi
    final filteredTasks = tasks.where((task) => task.status == state).toList();

    if (filteredTasks.isEmpty) {
      return const Center(child: Text("Filtrelere uygun görev bulunamadı"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(tasksProvider);
      },
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          return TaskCard(task: filteredTasks[index]);
        },
      ),
    );
  }
}
