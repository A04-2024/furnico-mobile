import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnico/rating/models/rating.dart';

Future<List<Rating>> fetchRatings(String productId) async {
  final url = 'http://127.0.0.1:8000/rating/product/$productId/json/';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => Rating.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load ratings');
  }
}