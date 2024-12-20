import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/category.dart';
import 'homepage.dart';

class CategoryEditFormPage extends StatefulWidget {
  final String id;
  const CategoryEditFormPage({required this.id, super.key});

  @override
  State<CategoryEditFormPage> createState() => _CategoryEditFormPageState();
}

class _CategoryEditFormPageState extends State<CategoryEditFormPage> {
  late CookieRequest _request;
  late Future<void> _loadDataFuture;
  List<Category> listCategory = [];
  late String id;
  late String _category_image = "";
  late String _category_name = "";

  @override
  void initState() {
    super.initState();
    id = widget.id;
    _request = CookieRequest();
    _loadDataFuture = _loadObjects();
  }

  Future<List<Category>> fetchCategory(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json_cat/${widget.id}/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object categoryEntry
    List<Category> listCategory = [];
    for (var d in data) {
      if (d != null) {
        listCategory.add(Category.fromJson(d));
      }
    }
    return listCategory;
  }

  Future<void> _loadObjects() async {
    try {
      final categories = await fetchCategory(_request);
      setState(() {
        listCategory = categories;
      });

    } catch (error) {
      debugPrint("Error loading category: $error");
    }

    _category_image = "${listCategory[0].fields.imageUrl}";
    _category_name = "${listCategory[0].fields.categoryName}";
  }

  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Category'),
      ),
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Menampilkan loading spinner saat menunggu
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Menampilkan pesan error jika ada masalah
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Scaffold(
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 8.0, left: 16.0, right: 16.0),
                        child: Text(
                          'Detail Kategori',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21.0,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 8.0, left: 16.0, right: 16.0, bottom: 0.0),
                        child: Text(
                          'Harap isi semua kolom.',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[400]),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listCategory[0].fields.categoryName,
                          decoration: InputDecoration(
                            hintText: "Nama Kategori",
                            labelText: "Nama Kategori",
                            icon: Icon(Icons.abc),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _category_name = value!;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Nama kategori tidak boleh kosong!";
                            }
                            if (value.length > 255) {
                              return "Nama kategori terlalu panjang!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listCategory[0].fields.imageUrl,
                          decoration: InputDecoration(
                            hintText: "Tautan Gambar kategori",
                            labelText: "Tautan Gambar kategori",
                            icon: Icon(Icons.image),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _category_image = value!;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Tautan Gambar kategori tidak boleh kosong!";
                            }
                            if (value.length > 10000) {
                              return "Tautan Gambar kategori terlalu panjang!";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Aksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                              backgroundColor: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final response = await _request.postJson(
                                  "http://127.0.0.1:8000/edit_category_flutter/",
                                  jsonEncode(<String, String>{
                                    'category_id': id,
                                    'category_image': _category_image,
                                    'category_name': _category_name,
                                  }),
                                );
                                if (context.mounted) {
                                  if (response['status'] == 'success') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          "Kategori berhasil diedit!"),
                                    ));
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyHomePage()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                      Text(
                                          "Terdapat kesalahan, silakan coba lagi."),
                                    ));
                                  }
                                }
                              }
                            },
                            child: const Text(
                              "Simpan",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                              backgroundColor: Colors.grey[600],
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Kembali",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
