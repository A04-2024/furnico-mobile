import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furnico/theo/models/product_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/category.dart';
import 'homepage.dart';

class ProductEditFormPage extends StatefulWidget {
  final String id;
  const ProductEditFormPage({required this.id, super.key});

  @override
  State<ProductEditFormPage> createState() => _ProductEditFormPageState();
}

class _ProductEditFormPageState extends State<ProductEditFormPage> {
  late CookieRequest _request;
  late Future<void> _loadDataFuture;
  List<Category> listCategory = [];
  List<ProductEntry> listProduct = [];
  late String id;
  late String _product_image = "";
  late String _product_name = "";
  late String _product_subtitle = "";
  late int _product_price = 0;
  late int _sold_this_week = 0;
  late int _people_bought = 0;
  late String _product_description = "";
  late String _product_advantages = "";
  late String _product_material = "";
  late int _product_size_length = 0;
  late int _product_size_height = 0;
  late int _product_size_long = 0;
  late String _product_category = "";
  late int _product_rating = 0;
  late String _store_name = "";
  late String _store_address = "";

  @override
  void initState() {
    super.initState();
    id = widget.id;
    _request = CookieRequest();
    _loadDataFuture = _loadObjects();
  }

  Future<List<Category>> fetchCategory(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json_cat/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object ProductEntry
    List<Category> listCategory = [];
    for (var d in data) {
      if (d != null) {
        listCategory.add(Category.fromJson(d));
      }
    }
    return listCategory;
  }

  Future<List<ProductEntry>> fetchProduct(CookieRequest request) async {
    final response = await request.get(
        'http://127.0.0.1:8000/json/${widget.id}/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object ProductEntry
    List<ProductEntry> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(ProductEntry.fromJson(d));
      }
    }
    return listProduct;
  }

  Future<void> _loadObjects() async {
    try {
      final categories = await fetchCategory(_request);
      setState(() {
        listCategory = categories;
      });
      final products = await fetchProduct(_request);
      setState(() {
        listProduct = products;
      });
    } catch (error) {
      debugPrint("Error loading products: $error");
    }

    _product_image = "${listProduct[0].fields.productImage}";
    _product_name = "${listProduct[0].fields.productName}";
    _product_subtitle = "${listProduct[0].fields.productSubtitle}";
    _product_price = int.parse("${listProduct[0].fields.productPrice}");
    _sold_this_week = int.parse("${listProduct[0].fields.soldThisWeek}");
    _people_bought = int.parse("${listProduct[0].fields.peopleBought}");
    _product_description = "${listProduct[0].fields.productDescription}";
    _product_advantages = "${listProduct[0].fields.productAdvantages}";
    _product_material = "${listProduct[0].fields.productMaterial}";
    _product_size_length = int.parse("${listProduct[0].fields.productSizeLength}");
    _product_size_height = int.parse("${listProduct[0].fields.productSizeHeight}");
    _product_size_long = int.parse("${listProduct[0].fields.productSizeLong}");
    _product_category = "${listProduct[0].fields.productCategory}";
    _store_name = "${listProduct[0].fields.storeName}";
    _store_address = "${listProduct[0].fields.storeAddress}";
  }

  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
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
                          'Detail Produk',
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
                          initialValue: listProduct[0].fields.productName,
                          decoration: InputDecoration(
                            hintText: "Nama Produk",
                            labelText: "Nama Produk",
                            icon: Icon(Icons.abc),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _product_name = value!;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Nama produk tidak boleh kosong!";
                            }
                            if (value.length > 255) {
                              return "Nama produk terlalu panjang!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.productSubtitle,
                          decoration: InputDecoration(
                            hintText: "Penjelasan singkat produk",
                            labelText: "Subtitel produk",
                            icon: Icon(Icons.subtitles),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _product_subtitle = value!;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Subtitel produk tidak boleh kosong!";
                            }
                            if (value.length > 255) {
                              return "Subtitel produk terlalu panjang!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.productImage,
                          decoration: InputDecoration(
                            hintText: "Tautan Gambar Produk",
                            labelText: "Tautan Gambar Produk",
                            icon: Icon(Icons.image),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _product_image = value!;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Tautan Gambar Produk tidak boleh kosong!";
                            }
                            if (value.length > 10000) {
                              return "Tautan Gambar Produk terlalu panjang!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: "Pilih Kategori Produk",
                            labelText: "Kategori Produk",
                            icon: Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          value: _product_category.isEmpty
                              ? null
                              : _product_category,
                          // Ensure valid default value
                          onChanged: (String? newValue) {
                            setState(() {
                              _product_category = newValue!;
                            });
                          },
                          items: listCategory.map((Category category) {
                            return DropdownMenuItem<String>(
                              value: category.pk,
                              // ID kategori yang digunakan untuk penyimpanan
                              child: Text(category.fields
                                  .categoryName), // Nama kategori yang ditampilkan
                            );
                          }).toList(),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Kategori produk harus dipilih!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.productPrice
                              .toString(),
                          decoration: InputDecoration(
                            hintText: "Harga Produk",
                            labelText: "Harga Produk",
                            icon: Icon(Icons.money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _product_price = int.tryParse(value!) ?? 0;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Harga Produk tidak boleh kosong!";
                            }
                            if (int.tryParse(value) == null) {
                              return "Harga Produk harus berupa angka!";
                            }
                            if (int.parse(value) <= 0) {
                              return "Harga Produk tidak boleh negatif!";
                            }
                            return null;
                          },
                        ),
                      ), Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.soldThisWeek
                              .toString(),
                          decoration: InputDecoration(
                            hintText: "Terjual Minggu Ini",
                            labelText: "Terjual Minggu Ini",
                            icon: Icon(Icons.shopping_bag),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _sold_this_week = int.tryParse(value!) ?? 0;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Produk terjual tidak boleh kosong!";
                            }
                            if (int.tryParse(value) == null) {
                              return "Produk terjual harus berupa angka!";
                            }
                            if (int.parse(value) <= 0) {
                              return "Produk terjual tidak boleh negatif!";
                            }
                            return null;
                          },
                        ),
                      ), Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.peopleBought
                              .toString(),
                          decoration: InputDecoration(
                            hintText: "Jumlah Produk Terjual",
                            labelText: "Jumlah Produk Terjual",
                            icon: Icon(Icons.shopping_cart),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _people_bought = int.tryParse(value!) ?? 0;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Produk terjual tidak boleh kosong!";
                            }
                            if (int.tryParse(value) == null) {
                              return "Produk terjual harus berupa angka!";
                            }
                            if (int.parse(value) <= 0) {
                              return "Produk terjual tidak boleh negatif!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields
                              .productDescription,
                          decoration: InputDecoration(
                            hintText: "Penjelasan detail produk",
                            labelText: "Deskripsi Produk",
                            icon: Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 5,
                          minLines: 3,
                          onChanged: (String? value) {
                            setState(() {
                              _product_description =
                              value!; // Update your variable as needed
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Deskripsi Produk tidak boleh kosong!";
                            }
                            return null;
                          },
                        ),
                      ), Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.productAdvantages,
                          decoration: InputDecoration(
                            hintText: "Penjelasan kelebihan produk",
                            labelText: "Kelebihan Produk",
                            icon: Icon(Icons.check_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 5,
                          minLines: 3,
                          onChanged: (String? value) {
                            setState(() {
                              _product_advantages =
                              value!; // Update your variable as needed
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Kelebihan Produk tidak boleh kosong!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.productMaterial,
                          decoration: InputDecoration(
                            hintText: "Bahan Produk",
                            labelText: "Bahan Produk",
                            icon: Icon(Icons.star_border_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _product_material = value!;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Bahan Produk tidak boleh kosong!";
                            }
                            if (value.length > 255) {
                              return "Bahan Produk terlalu panjang!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.productSizeLength
                              .toString(),
                          decoration: InputDecoration(
                            hintText: "Lebar produk",
                            labelText: "Lebar produk",
                            icon: Icon(Icons.numbers),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _product_size_length = int.tryParse(value!) ?? 0;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Lebar produk tidak boleh kosong!";
                            }
                            if (int.tryParse(value) == null) {
                              return "Lebar produk harus berupa angka!";
                            }
                            if (int.parse(value) <= 0) {
                              return "Lebar produk tidak boleh negatif!";
                            }
                            return null;
                          },
                        ),
                      ), Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.productSizeHeight
                              .toString(),
                          decoration: InputDecoration(
                            hintText: "Tinggi produk",
                            labelText: "Tinggi produk",
                            icon: Icon(Icons.numbers),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _product_size_height = int.tryParse(value!) ?? 0;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Tinggi produk tidak boleh kosong!";
                            }
                            if (int.tryParse(value) == null) {
                              return "Tinggi produk harus berupa angka!";
                            }
                            if (int.parse(value) <= 0) {
                              return "Tinggi produk tidak boleh negatif!";
                            }
                            return null;
                          },
                        ),
                      ), Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.productSizeLong
                              .toString(),
                          decoration: InputDecoration(
                            hintText: "Panjang produk",
                            labelText: "Panjang produk",
                            icon: Icon(Icons.numbers),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _product_size_long = int.tryParse(value!) ?? 0;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Panjang produk tidak boleh kosong!";
                            }
                            if (int.tryParse(value) == null) {
                              return "Panjang produk harus berupa angka!";
                            }
                            if (int.parse(value) <= 0) {
                              return "Panjang produk tidak boleh negatif!";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.storeName
                              .toString(),
                          decoration: InputDecoration(
                            hintText: "Nama Toko",
                            labelText: "Nama Toko",
                            icon: Icon(Icons.store),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _store_name = value!;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Nama Toko tidak boleh kosong!";
                            }
                            if (value.length > 255) {
                              return "Nama Toko terlalu panjang!";
                            }
                            return null;
                          },
                        ),
                      ), Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: listProduct[0].fields.storeAddress
                              .toString(),
                          decoration: InputDecoration(
                            hintText: "Alamat Toko",
                            labelText: "Alamat Toko",
                            icon: Icon(Icons.storefront_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _store_address = value!;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Alamat Toko tidak boleh kosong!";
                            }
                            if (value.length > 10000) {
                              return "Alamat Toko terlalu panjang!";
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
                                  "http://127.0.0.1:8000/edit_product_flutter/",
                                  jsonEncode(<String, String>{
                                    'product_id': id,
                                    'product_image': _product_image,
                                    'product_name': _product_name,
                                    'product_subtitle': _product_subtitle,
                                    'product_price': _product_price.toString(),
                                    'sold_this_week': _sold_this_week
                                        .toString(),
                                    'people_bought': _people_bought.toString(),
                                    'product_description': _product_description,
                                    'product_advantages': _product_advantages,
                                    'product_material': _product_material,
                                    'product_size_length': _product_size_length
                                        .toString(),
                                    'product_size_height': _product_size_height
                                        .toString(),
                                    'product_size_long': _product_size_long
                                        .toString(),
                                    'product_category': _product_category,
                                    'store_name': _store_name,
                                    'store_address': _store_address,
                                  }),
                                );
                                if (context.mounted) {
                                  if (response['status'] == 'success') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          "Produk berhasil diedit!"),
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage()),
                              );
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
