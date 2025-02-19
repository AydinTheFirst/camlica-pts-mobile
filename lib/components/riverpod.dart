// ignore_for_file: unused_local_variable

import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appProvider = AutoDisposeFutureProvider((ref) async {
  final data = await HttpService.fetcher("/");
  return data;
});

final profileProvider = AutoDisposeFutureProvider((ref) async {
  final data = await HttpService.fetcher("/auth/me");
  return data;
});

class Riverpod extends ConsumerWidget {
  const Riverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appProvider);
    final profile = ref.watch(profileProvider);

    final appData = app.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );

    final profileData = profile.maybeWhen(
      data: (data) => User.fromJson(data),
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Riverpod"),
      ),
      body: app.when(
        error: (error, stack) => Text('Error: $error'),
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        data: (data) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("App Version: ${data["version"]}"),
                Text("App Name: ${data["message"]}"),
                StyledButton(
                  isLoading: app.isLoading || app.isRefreshing,
                  onPressed: () => ref.refresh(appProvider),
                  variant: Variants.success,
                  child: Text("Press Me"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
