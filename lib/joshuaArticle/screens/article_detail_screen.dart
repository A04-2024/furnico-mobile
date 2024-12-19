import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
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
  final TextEditingController _commentController= TextEditingController();

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    fetchComments();
    final currentUsername = request.jsonData['username'];
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

  // Submit a new comment for the current forum
  Future<void> submitComment(CookieRequest request) async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    Map<String, dynamic> data = {
      'content': _commentController.text,
    };

    try {
      final response = await request.postJson(
        'http://127.0.0.1:8000/article/create-comment-flutter/${widget.article.id}/',
        jsonEncode(data),
      );

      if (response is Map && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment submitted successfully!')),
        );
        _commentController.clear();

        // Re-fetch comments to include the new comment
        await fetchComments();
      } else if (response is Map && response['status'] == 'error') {
        String errorMessage = response['message'] ?? 'Failed to submit comment.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit comment: $errorMessage')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected response from server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting comment: $e')),
      );
    }
  }


  Future<void> deleteComment(CommentEntry comment) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final deleteUrl = 'http://127.0.0.1:8000/article/delete-comment-flutter/${comment.id}/';

    try {
      final response = await request.post(deleteUrl, {});
      // Directly refresh the comments after deletion, assuming success
      await fetchComments(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted successfully!')),
      );
    } catch (e) {
      // If there's an error, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting comment: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final imageUrl = 'http://127.0.0.1:8000/media/${widget.article.image}';
    final request = context.watch<CookieRequest>();

    // Get current username from the provider
    final currentUsername = request.jsonData['username'];

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
                          const SizedBox(height: 8),
                          // Show delete button if currentUsername matches comment userUsername
                          if (currentUsername == comment.userUsername)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => deleteComment(comment),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                ),
                labelText: 'Write your comments',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                hintText: 'Share your thoughts...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
              maxLines: 3,
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                submitComment(request).then((_) {
                  setState(() {});
                });
              },
              child: Text('Submit Comment'),
            ),
          ],
        ),
      ),
    );
  }
}
