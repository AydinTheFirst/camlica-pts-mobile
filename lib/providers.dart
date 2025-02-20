import 'package:camlica_pts/models/app_config_model.dart';
import 'package:camlica_pts/models/notification_model.dart';
import 'package:camlica_pts/models/post_model.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/models/timelog_model.dart';
import 'package:camlica_pts/models/unit_model.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = AutoDisposeFutureProvider<User>((ref) async {
  final data = await HttpService.fetcher("/auth/@me");
  return User.fromJson(data);
});

final postsProvider = AutoDisposeFutureProvider<List<Post>>((ref) async {
  final data = await HttpService.fetcher("/posts");
  return List<Post>.from(data.map((x) => Post.fromJson(x)));
});

final tasksProvider = AutoDisposeFutureProvider<List<Task>>((ref) async {
  final data = await HttpService.fetcher("/tasks");
  return List<Task>.from(data.map((x) => Task.fromJson(x)));
});

final timelogsProvider = AutoDisposeFutureProvider<List<TimeLog>>((ref) async {
  final data = await HttpService.fetcher("/timelogs");
  return List<TimeLog>.from(data.map((x) => TimeLog.fromJson(x)));
});

final unitsProvider = AutoDisposeFutureProvider<List<Unit>>((ref) async {
  final data = await HttpService.fetcher("/units");
  return List<Unit>.from(data.map((x) => Unit.fromJson(x)));
});

final usersProvider = AutoDisposeFutureProvider<List<User>>((ref) async {
  final data = await HttpService.fetcher("/users");
  return List<User>.from(data.map((x) => User.fromJson(x)));
});

final notificationsProvider =
    AutoDisposeFutureProvider<List<NotificationModel>>((ref) async {
  final data = await HttpService.fetcher("/notifications");
  return List<NotificationModel>.from(
      data.map((x) => NotificationModel.fromJson(x)));
});

final configProvider = AutoDisposeFutureProvider<AppConfig>((ref) async {
  final data = await HttpService.fetcher("/config");
  return AppConfig.fromJson(data);
});
