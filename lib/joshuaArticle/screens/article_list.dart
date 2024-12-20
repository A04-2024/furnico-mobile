import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furnico/joshuaArticle/models/article_models.dart';
import 'package:furnico/joshuaArticle/screens/article_detail_screen.dart';
import 'package:furnico/joshuaArticle/screens/article_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart' as html_parser; // For parsing HTML to plain text
import 'package:http/http.dart' as http;

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  late Future<List<ArticleEntry>> _articleFuture;
  bool _isAdmin = false;

  Future<List<ArticleEntry>> fetchArticle(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/article/json-article/');
    List<ArticleEntry> listItem = [];

    for (var d in response) {
      if (d != null) {
        listItem.add(ArticleEntry.fromJson(d));
      }
    }
    return listItem;
  }

  Future<void> _deleteArticle(ArticleEntry article) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final deleteUrl = 'http://127.0.0.1:8000/article/delete-article-flutter/${article.id}/';

    try {
      final response = await request.post(deleteUrl, {});
      // Directly refresh the articles after deletion, assuming success
      _refreshArticles();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article deleted successfully!')),
      );
    } catch (e) {
      // If there's an error, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting article: $e')),
      );
    }
  }


  Future<void> checkAdminStatus(String username) async {
    final String apiUrl = "http://127.0.0.1:8000/article/check-admin-status/$username/"; // Update with your actual endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('is_admin')) {
          setState(() {
              _isAdmin = responseData['is_admin']; // Update class state variable
          });
          // You can now update the UI or perform further logic
        } else {
          print('Unexpected response format: ${response.body}');
        }
      } else if (response.statusCode == 404) {
        print('User not found');
      } else {
        print('Failed to fetch admin status. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _articleFuture = fetchArticle(request);
    final currentUsername = request.jsonData['username'];
    checkAdminStatus(currentUsername);
  }

  Future<void> _refreshArticles() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    setState(() {
      _articleFuture = fetchArticle(request);
    });
  }

 @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Articles',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshArticles,
              child: FutureBuilder<List<ArticleEntry>>(
                future: _articleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada artikel di Furnico :)',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  } else {
                    final articles = snapshot.data!;
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: articles.length,
                      itemBuilder: (_, index) {
                        final article = articles[index];
                        final imageUrl = 'http://127.0.0.1:8000/media/${article.image}';

                        return GestureDetector(
                          onTap: () {
                            // Navigate to the detail page with full HTML rendering
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticleDetailPage(article: article),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (article.image.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15.0)),
                                    child: Image.network(
                                      imageUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "By: ${article.authorUsername}",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 8),
                                      if (article.createdAt != null)
                                        Text(
                                          "Created at: ${article.createdAt}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500]),
                                        ),
                                      const SizedBox(height: 10),
                                      // Show truncated plain text preview
                                      Text(
                                        _truncateHtmlContent(article.content),
                                        style: const TextStyle(
                                            fontSize: 14, height: 1.4),
                                      ),
                                      const SizedBox(height: 10),
                                      if (_isAdmin) // Show admin actions only for admins
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => AddArticlePage(article: article, isEdit: true),
                                                  ),
                                                ).then((shouldRefresh) {
                                                  if (shouldRefresh == true) {
                                                    _refreshArticles();
                                                  }
                                                });
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteArticle(article),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                  }
                },
              ),
            ),
          ),
          if (_isAdmin == true) // Show button only if the user is an admin
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddArticlePage(),
                    ),
                  ).then((shouldRefresh) {
                    if (shouldRefresh == true) {
                      _refreshArticles();
                    }
                  });
                },
                child: const Text("Add New Article"),
              ),
            ),
        ],
      ),
    );
  }


  // Convert HTML to plain text and then truncate
  String _truncateHtmlContent(String html, {int wordLimit = 20}) {
    // Parse the HTML
    final document = html_parser.parse(html);
    final String parsedText = document.body?.text ?? '';

    // Truncate words
    List<String> words = parsedText.split(' ');
    if (words.length > wordLimit) {
      words = words.sublist(0, wordLimit);
      return words.join(' ') + '...';
    }
    return parsedText;
  }
}
