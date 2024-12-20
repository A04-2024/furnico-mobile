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

Future<String> fetchCsrfToken() async {
  String csrfUrl = "http://127.0.0.1:8000/rating/csrf-token/";
  final response = await http.get(Uri.parse(csrfUrl));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['csrfToken'];
  } else {
    throw Exception('Failed to fetch CSRF token');
  }
}

Future<bool> addRating(String productId, int rating, String description) async {
  String apiUrl = "http://127.0.0.1:8000/rating/product/$productId/json/";
  try {
    // Fetch CSRF token
    final csrfToken = await fetchCsrfToken();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken, 
      },
      body: jsonEncode({
        "id": productId,
        "user": {"username": "guest"},
        "rating": rating,
        "description": description,
        "is_owner": false,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("Error occurred: $e");
    return false;
  }
}
