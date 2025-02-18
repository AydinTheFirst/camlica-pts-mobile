import 'package:camlica_pts/bottom_navigation.dart';
import 'package:camlica_pts/firebase_api.dart';
import 'package:camlica_pts/firebase_options.dart';
import 'package:camlica_pts/screens/auth/forgot_password_screen.dart';
import 'package:camlica_pts/screens/auth/login_screen.dart';
import 'package:camlica_pts/screens/not_found.dart';
import 'package:camlica_pts/screens/notifications_page.dart';
import 'package:camlica_pts/screens/task_add_screen.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:camlica_pts/socket.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fquery/fquery.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

final Logger logger = Logger();
PackageInfo? packageInfo;

final QueryClient queryClient = QueryClient(
  defaultQueryOptions: DefaultQueryOptions(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseApi().init();

  await WebsocketClient().connect();

  final initialRoute = await TokenStorage.getToken() == null ? "/login" : "/";

  packageInfo = await PackageInfo.fromPlatform();
  runApp(QueryClientProvider(
    queryClient: queryClient,
    child: ProviderScope(child: MyApp(initialRoute: initialRoute)),
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Çamlıca Camii PTS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      unknownRoute: GetPage(name: "/notfound", page: () => NotFoundScreen()),
      getPages: [
        GetPage(
          name: "/",
          page: () => BottomNavigation(currentKey: "home"),
        ),
        GetPage(
            name: "/profile",
            page: () => BottomNavigation(currentKey: "profile")),
        GetPage(
          name: "/logs",
          page: () => BottomNavigation(currentKey: "logs"),
        ),
        GetPage(
          name: "/qr",
          page: () => BottomNavigation(currentKey: "qr"),
        ),
        GetPage(
          name: "/tasks",
          page: () => BottomNavigation(currentKey: "tasks"),
        ),
        GetPage(name: "/tasks/add", page: () => TaskAddScreen()),
        GetPage(name: "/notifications", page: () => NotificationsPage()),
        GetPage(name: "/login", page: () => LoginScreen()),
        GetPage(name: "/forgot-password", page: () => ForgotPasswordScreen()),
      ],
    );
  }
}
