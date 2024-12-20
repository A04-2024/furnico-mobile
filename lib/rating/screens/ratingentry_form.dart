import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // To store/get token

class RatingEntryFormPage extends StatefulWidget {
  final String productId;

  const RatingEntryFormPage({super.key, required this.productId});

  @override
  State<RatingEntryFormPage> createState() => _RatingEntryFormPageState();
}

class _RatingEntryFormPageState extends State<RatingEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 1;
  String _description = "";

  // CSRF token and user authentication should be handled here
  String csrfToken = "your_csrf_token_here"; // Replace with actual token

  Future<void> submitRating() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the token from SharedPreferences or local storage
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');  // Get the saved token

      if (token == null) {
        // Handle the case where the token is not available (user is not logged in)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/rating/product/${widget.productId}/create-flutter/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // Include the token in the Authorization header
          'X-CSRFToken': csrfToken, // Include the CSRF token
        },
        body: jsonEncode(<String, dynamic>{
          "rating": _rating,
          "description": _description,
          "is_owner": false,  // You can calculate this if needed
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Rating submitted successfully'),
              content: Text('Your rating has been submitted.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                    _formKey.currentState!.reset();
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to submit rating: ${response.body}'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Rating')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: submitRating,
                child: const Text('Submit Rating'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
