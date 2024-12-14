import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furnico/theo/models/product_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:furnico/theo/screens/dummy.dart';
import 'package:provider/provider.dart';

import 'edit_product.dart';
import 'homepage.dart';

import 'package:furnico/report/models/report.dart';
import 'package:furnico/report/screens/list_report_screen.dart';
import 'package:furnico/report/screens/create_report_form.dart'; // Pastikan path ini benar
import 'package:furnico/report/models/user_dummy.dart';

class ProductDetailPage extends StatefulWidget {
  final String id;

  const ProductDetailPage({required this.id, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late CookieRequest _request = CookieRequest();
  final User currentUser = regularUser; // Atur pengguna saat ini sesuai kebutuhan

  bool isFavorite = false;
  late Future<List<ProductEntry>> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = fetchProduct(_request);
  }

  Future<List<ProductEntry>> fetchProduct(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json/${widget.id}/');

    // Melakukan decode menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object ProductEntry
    List<ProductEntry> listProduct = [];
    for (var d in data) {
      if (d != null) {
        print(ProductEntry.fromJson(d));
        listProduct.add(ProductEntry.fromJson(d));
      }
    }
    return listProduct;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DummyPage()),
              );
            },
            label: Text(
              "See Wishlist",
              style: TextStyle(color: Colors.black),
            ),
            icon: Icon(
              Icons.favorite_border,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _futureProduct,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum ada data Product pada furnico.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            } else {
              // Ambil produk pertama dari list
              ProductEntry product = snapshot.data![0];
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar produk
                    AspectRatio(
                      aspectRatio: 1, // Rasio 1:1
                      child: ClipRRect(
                        child: Image.network(
                          "${product.fields.productImage}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${product.fields.productName}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "${product.fields.productSubtitle}",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Harga produk
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Rp ${product.fields.productPrice}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            "Terjual ${product.fields.peopleBought}",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, color: Colors.yellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${product.fields.productRating}",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductEditFormPage(id: "${product.pk}"),
                                ),
                              );
                            },
                            child: const Text('Edit Produk'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                            ),
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, product.pk);
                            },
                            child: const Text('Hapus Produk'),
                          ),
                        ],
                      ),
                    ),

                    // Garis pembatas
                    const Divider(height: 24, thickness: 1),

                    // Nama toko dan alamat
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${product.fields.storeName}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${product.fields.storeAddress}",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // Garis pembatas
                    const Divider(height: 24, thickness: 1),

                    // Detail produk
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detail Produk",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("${product.fields.productDescription}"),
                        ],
                      ),
                    ),

                    const Divider(height: 24, thickness: 1),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kelebihan Produk",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text("${product.fields.productAdvantages}"),
                        ],
                      ),
                    ),

                    const Divider(height: 24, thickness: 1),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bahan Produk",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text("${product.fields.productMaterial}"),
                        ],
                      ),
                    ),

                    // Garis pembatas
                    const Divider(height: 24, thickness: 1),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ukuran Produk",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("Panjang: ${product.fields.productSizeLong} cm"),
                          Text("Lebar: ${product.fields.productSizeLength} cm"),
                          Text("Tinggi: ${product.fields.productSizeHeight} cm"),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
      bottomNavigationBar: FutureBuilder(
        future: _futureProduct,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data.isEmpty) {
            return SizedBox.shrink(); // Tidak menampilkan apa-apa jika data belum siap
          }

          ProductEntry product = snapshot.data![0];

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Warna hijau
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DummyPage()),
                    );
                  },
                  child: Text(
                    'Tambah ke Wishlist',
                    style: TextStyle(color: Color(0xffffffff)),
                  ),
                ),
                // Tombol "Laporkan Produk"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentUser.role == 'regularuser' ? Colors.red : Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  onPressed: () {
                    if (currentUser.role == 'regularuser') {
                      _showCreateReportModal(context, product);
                    } else if (currentUser.role == 'adminuser') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReportListScreen(currentUser: currentUser)),
                      );
                    }
                  },
                  child: Text(
                    currentUser.role == 'regularuser' ? 'Laporkan Produk' : 'Lihat Daftar Produk',
                    style: TextStyle(color: Color(0xffffffff)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah anda yakin?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final response = await _request.postJson(
                      "http://127.0.0.1:8000/delete_product_flutter/",
                      jsonEncode(<String, String>{
                        'product_id': productId,
                      }),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close the dialog
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Produk berhasil dihapus!"),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Terdapat kesalahan, silakan coba lagi."),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showCreateReportModal(BuildContext context, ProductEntry product) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8, // Maksimal 80% tinggi layar
            ),
            child: CreateReportForm(
              user: currentUser,
              furniture: product,
              onReportCreated: (Report newReport) {
                // Implementasikan apa yang ingin dilakukan setelah laporan dibuat
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Laporan berhasil dibuat!')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
