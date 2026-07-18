import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/binding/initial_binding.dart';
import 'package:gym/scr/core/constants/app_theme.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GYM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
