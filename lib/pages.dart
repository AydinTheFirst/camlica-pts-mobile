import 'package:camlica_pts/bottom_navigation.dart';

import 'package:camlica_pts/screens/not_found.dart';

import 'package:camlica_pts/screens/auth/forgot_password_screen.dart';
import 'package:camlica_pts/screens/auth/login_screen.dart';

import 'package:camlica_pts/screens/admin/admin_notification_add_page.dart';
import 'package:camlica_pts/screens/admin/admin_page.dart';
import 'package:camlica_pts/screens/admin/admin_post_add_page.dart';
import 'package:camlica_pts/screens/admin/admin_qr_page.dart';
import 'package:camlica_pts/screens/admin/admin_task_add_page.dart';

final pages = [
  {"href": "/", "page": () => BottomNavigation()},
  {"href": "/profile", "page": () => BottomNavigation()},
  {"href": "/logs", "page": () => BottomNavigation()},
  {"href": "/qr", "page": () => BottomNavigation()},
  {"href": "/tasks", "page": () => BottomNavigation()},
  {"href": "/notifications", "page": () => BottomNavigation()},

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
