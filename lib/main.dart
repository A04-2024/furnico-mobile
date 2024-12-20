import 'package:flutter/material.dart';
import 'package:furnico/aut/TempLogin.dart';
import 'package:furnico/theo/screens/homepage.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Furnico',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
          ).copyWith(secondary: Colors.white),
        ),
        home: const LoginPage(),
      ),
    );
  }
}