import 'dart:async';

import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/notification_model.dart';
import 'package:camlica_pts/models/post_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
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
      data: (data) {
        final notifications = (data as List<dynamic>)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();

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

final postsProvider = FutureProvider<dynamic>((ref) async {
  final data = await HttpService.fetcher("/posts");
  return data;
});

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
      data: (data) {
        if (data == null) {
          return Center(
            child: Text("Veri bulunamadı"),
          );
        }

        final posts = data.map((e) => Post.fromJson(e)).toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(postsProvider);
            return Future.value();
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index] as Post;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.message),
                    title: Text(post.title),
                    subtitle: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(posts[index].body),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(formatDate(post.createdAt)),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => showPost(posts[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
