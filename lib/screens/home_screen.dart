import 'dart:async';

import 'package:camlica_pts/models/notification_model.dart';
import 'package:camlica_pts/models/post_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: "Duyurular",
            ),
            Tab(
              text: "Bildirimler",
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBarView(
              controller: _tabController,
              children: [
                Posts(),
                Notifications(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final notificationsProvider = FutureProvider<dynamic>((ref) async {
  final data = await HttpService.fetcher("/notifications");
  return data;
});

class Notifications extends ConsumerWidget {
  const Notifications({super.key});

  void showPost(NotificationModel notification, WidgetRef ref) async {
    if (!notification.isSeen) {
      await HttpService.dio.patch("/notifications/${notification.id}/seen");
      ref.refresh(notificationsProvider);
    }

    // show dialog
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
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
    final posts = ref.watch(notificationsProvider);

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

        final List<NotificationModel> posts = (data as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // sort posts by seen and createdAt
        posts.sort((a, b) {
          if (a.isSeen && !b.isSeen) {
            return 1;
          } else if (!a.isSeen && b.isSeen) {
            return -1;
          } else {
            return b.createdAt.compareTo(a.createdAt);
          }
        });

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(notificationsProvider);
            return Future.value();
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final notification = posts[index];

              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: notification.isSeen ? Colors.black : Colors.blue,
                  ),
                  title: Text(notification.title),
                  subtitle: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 4,
                        children: [
                          Text(formatDate(notification.createdAt)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => showPost(notification, ref),
                ),
              );
            },
          ),
        );
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
              return Card(
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
              );
            },
          ),
        );
      },
    );
  }
}
