import 'package:camlica_pts/bottom_navigation.dart';
import 'package:camlica_pts/screens/auth/forgot_password_screen.dart';
import 'package:camlica_pts/screens/auth/login_screen.dart';
import 'package:camlica_pts/screens/not_found.dart';
import 'package:camlica_pts/screens/task_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:fquery/fquery.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

final QueryClient queryClient = QueryClient(
  defaultQueryOptions: DefaultQueryOptions(),
);

void main() {
  runApp(QueryClientProvider(
    queryClient: queryClient,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Çamlıca Camii PTS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: "/",
      unknownRoute: GetPage(name: "/notfound", page: () => NotFoundScreen()),
      getPages: [
        GetPage(name: "/", page: () => BottomNavigation()),
        GetPage(name: "/profile", page: () => BottomNavigation()),
        GetPage(name: "/logs", page: () => BottomNavigation()),
        GetPage(name: "/qr", page: () => BottomNavigation()),
        GetPage(name: "/tasks", page: () => BottomNavigation()),
        GetPage(name: "/tasks/add", page: () => TaskAddScreen()),
        GetPage(name: "/login", page: () => LoginScreen()),
        GetPage(name: "/forgot-password", page: () => ForgotPasswordScreen()),
      ],
    );
  }
}
