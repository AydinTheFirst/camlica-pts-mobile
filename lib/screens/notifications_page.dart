import 'package:camlica_pts/models/notification_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  void viewNotification(NotificationModel notification, WidgetRef ref) async {
    if (!notification.isSeen) {
      await HttpService.dio.patch("/notifications/${notification.id}/seen");
      ref.invalidate(notificationsProvider);
    }

    // show dialog
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Kapat"),
          ),
        ],
      ),
    );
  }

  void handleMarkAllAsRead(WidgetRef ref) async {
    await HttpService.dio.post("/notifications/mark-all-seen");
    ref.invalidate(notificationsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsRef = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: notificationsRef.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(child: Text("Henüz bildirim yok."));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: notification.isSeen ? Colors.black : Colors.blue,
                  ),
                  title: Text(notification.title),
                  subtitle: Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 4,
                        children: [
                          Text(formatFullDate(notification.createdAt)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => viewNotification(notification, ref),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => handleMarkAllAsRead(ref),
        child: Icon(Icons.mark_chat_read_sharp),
      ),
    );
  }
}
