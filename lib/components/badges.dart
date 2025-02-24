import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsBadge extends ConsumerStatefulWidget {
  const NotificationsBadge({super.key});

  @override
  ConsumerState<NotificationsBadge> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends ConsumerState<NotificationsBadge> {
  int notificationCount = 0; // Example notification count

  void setNotificationCount(int count) {
    setState(() {
      notificationCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsRef = ref.watch(notificationsProvider);

    notificationsRef.when(
      data: (notifications) {
        final unseenNotifications =
            notifications.where((e) => !e.isSeen).toList();
        setNotificationCount(unseenNotifications.length);
      },
      loading: () {},
      error: (error, stack) {
        logger.e("Error: $error");
      },
    );

    if (notificationCount == 0) {
      return Icon(Icons.notifications);
    }

    return Badge(
      label: Text(
        notificationCount.toString(),
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      child: Icon(Icons.notifications),
    );
  }
}

class PostsBadge extends ConsumerStatefulWidget {
  const PostsBadge({super.key});

  @override
  ConsumerState<PostsBadge> createState() => _PostsBadgeState();
}

class _PostsBadgeState extends ConsumerState<PostsBadge> {
  int postCount = 0; // Example post count

  void setPostCount(int count) {
    setState(() {
      postCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsRef = ref.watch(postsProvider);

    postsRef.when(
      data: (posts) {
        setPostCount(posts.length);
      },
      loading: () {},
      error: (error, stack) {
        logger.e("Error: $error");
      },
    );

    if (postCount == 0) {
      return Icon(Icons.article);
    }

    return Badge(
      label: Text(
        postCount.toString(),
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      child: Icon(Icons.article),
    );
  }
}

class TasksBadge extends ConsumerStatefulWidget {
  const TasksBadge({super.key});

  @override
  ConsumerState<TasksBadge> createState() => _TasksBadgeState();
}

class _TasksBadgeState extends ConsumerState<TasksBadge> {
  int taskCount = 0; // Example task count

  void setTaskCount(int count) {
    setState(() {
      taskCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksRef = ref.watch(tasksProvider);

    tasksRef.when(
      data: (tasks) {
        final pendingTasks =
            tasks.where((e) => e.status == TaskStatus.PENDING).toList();
        setTaskCount(pendingTasks.length);
      },
      loading: () {},
      error: (error, stack) {
        logger.e("Error: $error");
      },
    );

    if (taskCount == 0) {
      return Icon(Icons.assignment);
    }

    return Badge(
      label: Text(
        taskCount.toString(),
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      child: Icon(Icons.assignment),
    );
  }
}
