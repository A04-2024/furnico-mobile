import 'package:flutter/material.dart';
import 'package:furnico/rating/models/rating.dart';
import 'package:furnico/rating/services/rating_service.dart';
import 'package:furnico/rating/screens/ratingentry_form.dart';

class RatingListPage extends StatefulWidget {
  final String productId;

  const RatingListPage({super.key, required this.productId});

  @override
  _RatingListPageState createState() => _RatingListPageState();
}

class _RatingListPageState extends State<RatingListPage> {
  late Future<List<Rating>> _ratingsFuture;

  @override
  void initState() {
    super.initState();
    _ratingsFuture = fetchRatings(widget.productId); 
  }

  void _refreshRatings() {
    setState(() {
      _ratingsFuture = fetchRatings(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ratings'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingEntryFormPage(productId: widget.productId),
                ),
              );

              if (result == true) {
                _refreshRatings();
              }
            },
            child: Text('Add Rating'),
          ),
          Expanded(
            child: FutureBuilder<List<Rating>>(
              future: _ratingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final ratings = snapshot.data!;
                  if (ratings.isEmpty) {
                    return Center(child: Text('Be the first to rate!'));
                  }
                  return ListView.builder(
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      final rating = ratings[index];
                      return ListTile(
                        title: Text(rating.username),
                        subtitle: Text(rating.description),
                        trailing: Text('${rating.rating} ⭐'),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No ratings available.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
