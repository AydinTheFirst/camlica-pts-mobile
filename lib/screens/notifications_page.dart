import 'package:camlica_pts/models/notification_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsRef = ref.watch(notificationsProvider);

    void viewNotification(NotificationModel notification, WidgetRef ref) async {
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
              onPressed: () => Get.back(),
              child: Text("Kapat"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: notificationsRef.when(
        data: (data) {
          final notifications = (data as List<dynamic>)
              .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(notificationsProvider);
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
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
                      onTap: () => viewNotification(notification, ref),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
    );
  }
}
