import 'package:camlica_pts/firebase_api.dart';
import 'package:camlica_pts/firebase_options.dart';
import 'package:camlica_pts/pages.dart';
import 'package:camlica_pts/screens/not_found.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:camlica_pts/socket.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger logger = Logger();
PackageInfo? packageInfo;
WidgetRef? globalRef;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WebsocketClient.connect();
  packageInfo = await PackageInfo.fromPlatform();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  String? initialRoute;

  @override
  void initState() {
    super.initState();
    _loadInitialRoute();
  }

  void setInitialRoute(String route) {
    logger.d("Initial route: $route");
    setState(() {
      initialRoute = route;
    });
  }

  Future<void> _loadInitialRoute() async {
    final token = await TokenStorage.getToken();
    String defaultRoute = token == null ? "/login" : "/";

    if (!kReleaseMode) {
      // Debug modda son kullanılan route'u oku
      final prefs = await SharedPreferences.getInstance();
      final lastRoute = prefs.getString("last_route");
      if (lastRoute != null) {
        defaultRoute = lastRoute;
      }
    }

    setInitialRoute(defaultRoute);
  }

  @override
  Widget build(BuildContext context) {
    if (initialRoute == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
          .map(
            (page) => GetPage(
              name: page["href"] as String,
              page: page["page"] as Widget Function(),
              middlewares: [RouteMiddleware()],
            ),
          )
          .toList(),
    );
  }
}

class RouteMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!kReleaseMode) {
      _saveLastRoute(route);
    }
    return null;
  }

  Future<void> _saveLastRoute(String? route) async {
    if (route != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("last_route", route);
    }
  }
}
