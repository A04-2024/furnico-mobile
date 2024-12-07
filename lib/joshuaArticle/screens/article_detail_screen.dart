import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:furnico/joshuaArticle/models/article_models.dart';

class ArticleDetailPage extends StatelessWidget {
  final ArticleEntry article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'http://127.0.0.1:8000/media/${article.image}';

    // Parse the HTML content to plain text
    String plainTextContent = parse(article.content).documentElement?.text ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.image != null && article.image.isNotEmpty)
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
              article.title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 16),
            Text(
              plainTextContent,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
