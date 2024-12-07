import 'package:flutter/material.dart';
import 'package:furnico/joshuaArticle/models/article_detail.dart';
import 'package:furnico/joshuaArticle/screens/article_detail_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  late Future<List<ArticleEntry>> _articleFuture;

  Future<List<ArticleEntry>> fetchArticle(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/article/json-article/');
    List<ArticleEntry> listItem = [];

    for (var d in response) {
      if (d != null) {
        listItem.add(ArticleEntry.fromJson(d));
      }
    }
    return listItem;
  }

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _articleFuture = fetchArticle(request);
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
      body: RefreshIndicator(
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
                      // Arahkan ke halaman detail ketimbang menampilkan dialog
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
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
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
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                if (article.createdAt != null)
                                  Text(
                                    "Created at: ${article.createdAt}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  _truncateContent(article.content),
                                  style: const TextStyle(fontSize: 14, height: 1.4),
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
      // Jika ingin tombol floatingActionButton untuk admin, aktifkan bila perlu:
      // floatingActionButton: request.isAdmin 
      //   ? FloatingActionButton(
      //       onPressed: () {
      //         // Navigate to add new article page
      //       },
      //       backgroundColor: Colors.yellow[700],
      //       child: const Icon(Icons.add, color: Colors.white),
      //     )
      //   : null,
    );
  }

  String _truncateContent(String content, {int wordLimit = 20}) {
    List<String> words = content.split(' ');
    if (words.length > wordLimit) {
      words = words.sublist(0, wordLimit);
      return words.join(' ') + '...';
    }
    return content;
  }
}
