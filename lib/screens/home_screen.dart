import 'dart:async';

import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/post_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          NotificationButton(),
        ],
      ),
      body: Posts(),
    );
  }
}

class NotificationButton extends ConsumerStatefulWidget {
  const NotificationButton({super.key});

  @override
  ConsumerState<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends ConsumerState<NotificationButton> {
  int notificationCount = 5; // Example notification count

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
      return button(context);
    }

    return badges.Badge(
      badgeContent: Text(
        notificationCount.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      position: badges.BadgePosition.topEnd(top: 0, end: 0),
      badgeAnimation: badges.BadgeAnimation.scale(),
      child: button(context),
    );
  }

  Widget button(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        Get.toNamed("/notifications");
      },
    );
  }
}

class Posts extends ConsumerWidget {
  const Posts({super.key});

  void showPost(Post post) {
    // show dialog
    Get.dialog(
      AlertDialog(
        title: Text(post.title),
        content: Text(post.body),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("Kapat"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return posts.when(
      error: (error, stack) => Text('Error: $error'),
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      data: (posts) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(postsProvider);
            return Future.value();
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                leading: Icon(Icons.message),
                title: Text(post.title),
                subtitle: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(posts[index].body),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(formatFullDate(post.createdAt)),
                      ],
                    ),
                  ],
                ),
                onTap: () => showPost(posts[index]),
              );
            },
          ),
        );
      },
    );
  }
}
