import 'package:flutter/material.dart';
import 'package:furnico/rating/models/rating.dart';
import 'package:furnico/rating/widgets/add_rating_form.dart';
import 'package:furnico/rating/widgets/rating_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rating App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProductDetailsPage(productId: 'fada9853-8b38-4618-97f8-fce491854ea6'),
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  ProductDetailsPage({required this.productId});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<List<Rating>> _ratings;

  @override
  void initState() {
    super.initState();
    _ratings = fetchRatings(widget.productId); 
  }

  Future<List<Rating>> fetchRatings(String productId) async {
    final url = 'http://127.0.0.1:8000/rating/product/$productId/json/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Rating.fromJson(item)).toList();  
    } else {
      throw Exception('Failed to load ratings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddRatingForm(productId: widget.productId),
            SizedBox(height: 20),
            Text(
              'Ratings:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Rating>>(
                future: _ratings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No ratings available.'));
                  } else {
                    return RatingList(ratings: snapshot.data!); 
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
