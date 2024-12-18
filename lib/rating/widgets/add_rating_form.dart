import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddRatingForm extends StatefulWidget {
  final String productId;
  AddRatingForm({required this.productId});

  @override
  _AddRatingFormState createState() => _AddRatingFormState();
}

class _AddRatingFormState extends State<AddRatingForm> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  String _description = '';

  Future<void> _submitRating() async {
    if (_formKey.currentState!.validate()) {
      final url = 'http://127.0.0.1:8000/rating/product/${widget.productId}/add-rating-ajax/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'rating': _rating,
          'description': _description,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rating added successfully!')));
        setState(() {
          _description = '';
          _rating = 5;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add rating')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Rating Description'),
            onChanged: (value) {
              setState(() {
                _description = value;
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _rating,
            onChanged: (value) {
              setState(() {
                _rating = value!;
              });
            },
            items: List.generate(5, (index) => index + 1)
                .map((rating) => DropdownMenuItem(
                      value: rating,
                      child: Text('$rating'),
                    ))
                .toList(),
            decoration: InputDecoration(labelText: 'Rating'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitRating,
            child: Text('Submit Rating'),
          ),
        ],
      ),
    );
  }
}
