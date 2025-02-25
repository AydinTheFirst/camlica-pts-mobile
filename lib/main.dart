import 'package:camlica_pts/bottom_navigation.dart';
import 'package:camlica_pts/firebase_api.dart';
import 'package:camlica_pts/firebase_options.dart';
import 'package:camlica_pts/screens/admin/admin_notification_add_page.dart';
import 'package:camlica_pts/screens/admin/admin_page.dart';
import 'package:camlica_pts/screens/admin/admin_post_add_page.dart';
import 'package:camlica_pts/screens/admin/admin_qr_page.dart';
import 'package:camlica_pts/screens/auth/forgot_password_screen.dart';
import 'package:camlica_pts/screens/auth/login_screen.dart';
import 'package:camlica_pts/screens/not_found.dart';
import 'package:camlica_pts/screens/admin/admin_task_add_page.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:camlica_pts/socket.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

final Logger logger = Logger();
PackageInfo? packageInfo;
WidgetRef? globalRef;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WebsocketClient.connect();

  final initialRoute = await TokenStorage.getToken() == null ? "/login" : "/";

  packageInfo = await PackageInfo.fromPlatform();
  runApp(ProviderScope(child: MyApp(initialRoute: initialRoute)));
}

final pages = [
  {"href": "/", "page": () => BottomNavigation(currentKey: "home")},
  {"href": "/profile", "page": () => BottomNavigation(currentKey: "profile")},
  {"href": "/logs", "page": () => BottomNavigation(currentKey: "logs")},
  {"href": "/qr", "page": () => BottomNavigation(currentKey: "qr")},
  {"href": "/tasks", "page": () => BottomNavigation(currentKey: "tasks")},
  {
    "href": "/notifications",
    "page": () => BottomNavigation(currentKey: "notifications")
  },

  // Not Found
  {"href": "/notfound", "page": () => NotFoundScreen()},

  // Auth
  {"href": "/login", "page": () => LoginScreen()},
  {"href": "/forgot-password", "page": () => ForgotPasswordScreen()},

  // Admin
  {"href": "/admin", "page": () => AdminPage()},
  {"href": "/admin/qr", "page": () => AdminQrPage()},
  {"href": "/admin/task-add", "page": () => TaskAddScreen()},
  {"href": "/admin/notification-add", "page": () => AdminNotificationAddPage()},
  {"href": "/admin/post-add", "page": () => AdminPostAddPage()},
];

class MyApp extends ConsumerWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    globalRef = ref;

    FirebaseApi().init();

    return GetMaterialApp(
      title: 'Çamlıca Camii PTS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      unknownRoute: GetPage(name: "/notfound", page: () => NotFoundScreen()),
      getPages: pages
          .map((page) => GetPage(
              name: page["href"] as String,
              page: page["page"] as Widget Function()))
          .toList(),
    );
  }
}
