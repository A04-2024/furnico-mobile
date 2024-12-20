import 'package:flutter/material.dart';
import 'package:furnico/rating/models/rating.dart';
import 'package:furnico/rating/services/rating_service.dart';

class RatingListPage extends StatelessWidget {
  final String productId;

  const RatingListPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ratings')),
      body: FutureBuilder<List<Rating>>(
        future: fetchRatings(productId), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final ratings = snapshot.data!;
            return ListView.builder(
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return ListTile(
                  title: Text(rating.username), 
                  subtitle: Text(rating.description),  
                  trailing: Text(rating.rating.toString()),  
                );
              },
            );
          } else {
            return Center(child: Text('No ratings available.'));
          }
        },
      ),
    );
  }
}
