import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furnico/joshuaArticle/models/article_models.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AddArticlePage extends StatefulWidget {
  final ArticleEntry? article; // Optional article to edit
  final bool isEdit;

  const AddArticlePage({Key? key, this.article, this.isEdit = false}) : super(key: key);

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.article != null) {
      // Pre-fill fields with the existing article data if editing
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
    }
  }

  Future<void> _submitArticle(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      final url = widget.isEdit
          ? 'http://127.0.0.1:8000/article/edit-article-flutter/${widget.article!.id}/'
          : 'http://127.0.0.1:8000/article/create-article-flutter/';

      final Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
      };

      try {
        final response = await request.postJson(url, jsonEncode(data));

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Article ${widget.isEdit ? "updated" : "created"} successfully!')),
          );

          // Clear the form fields
          _titleController.clear();
          _contentController.clear();
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to ${widget.isEdit ? "update" : "create"} article: ${response['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${widget.isEdit ? "updating" : "creating"} article: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Article' : 'Add New Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, 
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEdit ? "Edit Article" : "Create a New Article",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter the content' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _submitArticle(request),
                  child: Text(widget.isEdit ? 'Update' : 'Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
