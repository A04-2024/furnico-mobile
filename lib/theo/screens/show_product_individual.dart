import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furnico/theo/models/product_entry.dart';
import 'package:furnico/wishlist/screens/MyWishlist.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:furnico/theo/screens/dummy.dart';
import 'package:provider/provider.dart';
import 'package:furnico/wishlist/model/CollectionWishlist.dart';

import 'edit_product.dart';
import 'homepage.dart';

class ProductDetailPage extends StatefulWidget {
  final String id;

  const ProductDetailPage({required this.id, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late CookieRequest _request = CookieRequest();
  bool isFavorite = false;
  List<dynamic> collections = [];

  @override
  void initState() {
    super.initState();
    checkWishlistStatus();
    fetchCollections();
  }

  Future<void> checkWishlistStatus() async {
    final response =
        await _request.get('http://127.0.0.1:8000/wishlist/wishlist-json/');

    if (response != null) {
      CollectionWishlist wishlistData = CollectionWishlist.fromJson(response);
      bool found = false;

      // Check if product exists in any collection
      for (var collection in wishlistData.collections) {
        if (collection.items.any((item) => item.productId == widget.id)) {
          found = true;
          break;
        }
      }

      setState(() {
        isFavorite = found;
      });
    }
  }
  
  Future<void> fetchCollections() async {
    final response =
        await _request.get('http://127.0.0.1:8000/wishlist/wishlist-json/');
    if (response != null) {
      CollectionWishlist wishlistData = CollectionWishlist.fromJson(response);
      setState(() {
        collections = wishlistData.collections
            .map((collection) => {
                  'collection_id': collection.collectionId,
                  'collection_name': collection.collectionName,
                })
            .toList();
      });
    }
  }

  Future<void> toggleWishlist() async {
    if (!isFavorite) {
      _showCollectionSelectionDialog();
    } else {
      // Remove from wishlist
      final response = await _request.post(
        'http://127.0.0.1:8000/wishlist/remove-wishlist/${widget.id}/',
        jsonEncode({}),
      );

      if (response['success'] == true) {
        setState(() {
          isFavorite = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from wishlist'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove from wishlist'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showCollectionSelectionDialog() {
    String? selectedCollectionId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Collection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Choose a collection'),
                        value: selectedCollectionId,
                        items: collections.map((collection) {
                          return DropdownMenuItem<String>(
                            value: collection['collection_id'].toString(),
                            child: Row(
                              children: [
                                const Icon(Icons.folder,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text(collection['collection_name']),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedCollectionId = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: selectedCollectionId == null
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await _addToCollection(selectedCollectionId!);
                              },
                        child: const Text('Add to Collection'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _addToCollection(String collectionId) async {
    final response = await _request.post(
      'http://127.0.0.1:8000/wishlist/add-to-wishlist/${widget.id}/',
      jsonEncode({
        'collection_id': collectionId,
      }),
    );

    if (response['success'] == true) {
      setState(() {
        isFavorite = true;
      });
      if (mounted) {
        String collectionName = collections.firstWhere((c) =>
            c['collection_id'].toString() == collectionId)['collection_name'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to $collectionName'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to add to collection'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<List<ProductEntry>> fetchProduct(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/json/${widget.id}/');

    // Melakukan decode  menjadi bentuk json
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
                MaterialPageRoute(builder: (context) => const MyWishlist()),
              );
            },
            label: const Text(
              "See Wishlist",
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchProduct(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return const Column(
                children: [
                  Text(
                    'Belum ada data Product pada furnico.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1, // Rasio 1:1
                      child: ClipRRect(
                        child: Image.network(
                          "${snapshot.data![0].fields.productImage}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey),
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
                              "${snapshot.data![0].fields.productName}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: toggleWishlist,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "${snapshot.data![0].fields.productSubtitle}",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Harga produk
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Rp ${snapshot.data![0].fields.productPrice}",
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
                            "Terjual ${snapshot.data![0].fields.peopleBought}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${snapshot.data![0].fields.productRating}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                    builder: (context) => ProductEditFormPage(
                                          id: "${snapshot.data![0].pk}",
                                        )),
                              );
                            },
                            child: const Text('Edit Produk'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                            ),
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                  context, snapshot.data![0].pk);
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
                            "${snapshot.data![0].fields.storeName}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${snapshot.data![0].fields.storeAddress}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              "${snapshot.data![0].fields.productDescription}"),
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text("${snapshot.data![0].fields.productAdvantages}"),
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text("${snapshot.data![0].fields.productMaterial}"),
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              "Panjang: ${snapshot.data![0].fields.productSizeLong} cm"),
                          Text(
                              "Lebar: ${snapshot.data![0].fields.productSizeLength} cm"),
                          Text(
                              "Tinggi: ${snapshot.data![0].fields.productSizeHeight} cm"),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFavorite ? Colors.red : Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              onPressed: toggleWishlist,
              child: Text(
                isFavorite ? 'Remove from Wishlist' : 'Add to Wishlist',
                style: TextStyle(color: Color(0xffffffff)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna merah
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DummyPage()),
                );
              },
              child: Text(
                'Laporkan Produk',
                style: TextStyle(color: Color(0xffffffff)),
              ),
            ),
          ],
        ),
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
                            content:
                                Text("Terdapat kesalahan, silakan coba lagi."),
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
}
