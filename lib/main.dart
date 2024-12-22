import 'package:flutter/material.dart';
import 'package:sobat_mobile/colors.dart';
import 'package:sobat_mobile/daftar_favorite/screens/daftar_favorite.dart';
import 'package:sobat_mobile/drug/screens/list_drugentry.dart';
import 'package:sobat_mobile/homepage.dart';
import 'package:sobat_mobile/authentication/login.dart';
import 'package:sobat_mobile/review/screens/review_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sobat_mobile/welcome_Page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sobat',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
