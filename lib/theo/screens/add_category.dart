import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/category.dart';
import 'homepage.dart';

class CategoryEntryFormPage extends StatefulWidget {
  const CategoryEntryFormPage({super.key});

  @override
  State<CategoryEntryFormPage> createState() => _CategoryEntryFormPageState();
}

class _CategoryEntryFormPageState extends State<CategoryEntryFormPage> {
  late final CookieRequest _request = CookieRequest();

  final _formKey = GlobalKey<FormState>();
  String _category_image = "";
  String _category_name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Kategori',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[200], // Latar belakang lembut
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Kategori',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Harap isi semua kolom di bawah ini.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[400]),

                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Nama Kategori",
                      labelText: "Nama Kategori",
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
                        return "Nama Kategori tidak boleh kosong!";
                      }
                      if (value.length > 255) {
                        return "Nama Kategori terlalu panjang!";
                      }
                      return null;
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Tautan Gambar Kategori",
                      labelText: "Tautan Gambar Kategori",
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
                        return "Tautan Gambar Kategori tidak boleh kosong!";
                      }
                      if (value.length > 10000) {
                        return "Tautan Gambar Kategori terlalu panjang!";
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await _request.postJson(
                            "http://127.0.0.1:8000/create_category_flutter/",
                            jsonEncode(<String, String>{
                              'category_image': _category_image,
                              'category_name': _category_name,
                            }),
                          );
                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Kategori baru berhasil disimpan!"),
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
                                Text("Terdapat kesalahan, silakan coba lagi."),
                              ));
                            }
                          }
                        }
                      },
                      child: const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        backgroundColor: Colors.grey[600],
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage()),
                        );
                      },
                      child: const Text(
                        "Kembali",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
