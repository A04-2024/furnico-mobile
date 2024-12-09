import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:furnico/joshuaArticle/models/article_models.dart';
import 'package:furnico/joshuaArticle/models/comment_models.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ArticleDetailPage extends StatefulWidget {
  final ArticleEntry article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  List<CommentEntry> comments = [];
  bool isLoading = true;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final url = 'http://127.0.0.1:8000/article/json-article-comment/${widget.article.id}/'; // Replace with your API endpoint
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          comments = commentEntryFromJson(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitReview(CookieRequest request) async {
    // if (_userRating == 0.0 || _reviewController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please provide both rating and review.')),
    //   );
    //   return;
    // }

    // Map<String, dynamic> data = {
    //   'rating': _userRating.toInt(),
    //   'review': _reviewController.text,
    // };

    // try {
    //   final response = await request.postJson(
    //     'http://127.0.0.1:8000/food/add_food_review_flutter/${widget.food.pk}/',
    //     jsonEncode(data),
    //   );

    //   print('Raw Response: $response');

    //   if (response is Map && response['status'] == 'success') {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Review submitted successfully!')),
    //     );
    //     _reviewController.clear();
    //     _userRating = 0.0; // Reset user rating
    //     setState(() {
    //       // Optionally, re-fetch reviews to include the newly submitted one
    //       fetchFoodReviews(request);
    //     });
    //   } else if (response is Map && response['status'] == 'error') {
    //     String errorMessage = response['message'] ?? 'Failed to submit review.';
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Failed to submit review: $errorMessage')),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Unexpected response from server.')),
    //     );
    //     print('Unexpected Response Format: $response');
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error submitting review: $e')),
    //   );
    //   print('Exception: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'http://127.0.0.1:8000/media/${widget.article.image}';
    final request = context.watch<CookieRequest>();

    // Parse the HTML content to plain text
    String plainTextContent = parse(widget.article.content).documentElement?.text ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.article.image != null && widget.article.image.isNotEmpty) 
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.article.title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "By: ${widget.article.authorUsername}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (widget.article.createdAt != null) 
              Text(
                "Created at: ${widget.article.createdAt}",
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            const SizedBox(height: 16),
            Text(
              plainTextContent,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 32),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isLoading) 
              const Center(child: CircularProgressIndicator())
            else if (comments.isEmpty) 
              const Text('No comments yet', style: TextStyle(color: Colors.grey))
            else 
              ListView.builder(
                shrinkWrap: true, // Important to wrap inside SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.userUsername,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.body,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posted on: ${comment.createdAt}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Write your review',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                submitReview(request).then((_) {
                  setState(() {});
                });
              },
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
