import 'package:flutter/material.dart';
import 'package:furnico/rating/models/rating.dart';

class RatingList extends StatelessWidget {
  final List<Rating> ratings;

  const RatingList({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final rating = ratings[index];
        return ListTile(
          title: Text(rating.username),
          subtitle: Text(rating.description),
          trailing: Text('${rating.rating} ⭐'),
          isThreeLine: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          tileColor: rating.isOwner ? Colors.green[100] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        );
      },
    );
  }
}
