import 'package:flutter/material.dart';
// import 'package:furnico/rating/screens/list_rating.dart';

void main() {
  runApp(ProductRatingApp());
}

class ProductRatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Rating App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: ListRatingScreen(), // Set ListRatingScreen as the home screen
    );
  }
}
