import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/app_config_model.dart';
import 'package:camlica_pts/models/post_model.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/models/timelog_model.dart';
import 'package:camlica_pts/models/unit_model.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/services/http_service.dart';

Future<User> getProfile() async {
  final res = await HttpService.fetcher('/auth/@me');
  logger.d("getProfile: $res");
  User user = User.fromJson(res as Map<String, dynamic>);
  return user;
}

Future<List<Post>> getPosts() async {
  final res = await HttpService.fetcher('/posts');
  List<Post> posts = (res as List).map((e) => Post.fromJson(e)).toList();
  return posts;
}

Future<Post> getPost(String id) async {
  final res = await HttpService.fetcher('/posts/$id');
  Post post = Post.fromJson(res as Map<String, dynamic>);
  return post;
}

Future<List<TimeLog>> getTimeLogs() async {
  final res = await HttpService.fetcher('/timelogs');
  List<TimeLog> timeLogs =
      (res as List).map((e) => TimeLog.fromJson(e)).toList();
  return timeLogs;
}

Future<TimeLog> getTimeLog(String id) async {
  final res = await HttpService.fetcher('/timelogs/$id');
  TimeLog timeLog = TimeLog.fromJson(res as Map<String, dynamic>);
  return timeLog;
}

Future<List<Task>> getTasks() async {
  final res = await HttpService.fetcher("/tasks");
  List<Task> tasks = (res as List).map((e) => Task.fromJson(e)).toList();
  return tasks;
}

Future<Task> getTask(String id) async {
  final res = await HttpService.fetcher("/tasks/$id");
  Task task = Task.fromJson(res as Map<String, dynamic>);
  return task;
}

Future<List<User>> getUsers() async {
  final res = await HttpService.fetcher("/users");
  List<User> users = (res as List).map((e) => User.fromJson(e)).toList();
  return users;
}

Future<User> getUser(String id) async {
  final res = await HttpService.fetcher("/users/$id");
  User user = User.fromJson(res as Map<String, dynamic>);
  return user;
}

Future<List<Unit>> getUnits() async {
  final res = await HttpService.fetcher("/units");
  logger.d("getUnits: $res");
  List<Unit> units = (res as List).map((e) => Unit.fromJson(e)).toList();
  return units;
}

Future<Unit> getUnit(String id) async {
  final res = await HttpService.fetcher("/units/$id");
  Unit unit = Unit.fromJson(res as Map<String, dynamic>);
  return unit;
}

Future<AppConfig> getAppConfig() async {
  final res = await HttpService.fetcher("/config");
  AppConfig appConfig = AppConfig.fromJson(res as Map<String, dynamic>);
  return appConfig;
}
