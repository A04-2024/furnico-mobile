import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furnico/theo/screens/show_product_individual.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:furnico/wishlist/model/CollectionWishlist.dart';

import '../models/product_entry.dart';

class ShowProductAll extends StatefulWidget {
  const ShowProductAll({Key? key}) : super(key: key);

  @override
  State<ShowProductAll> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ShowProductAll> {
  late CookieRequest _request; // Inisialisasi untuk CookieRequest
  List<ProductEntry> allProducts = [];
  List<ProductEntry> filteredProducts = [];
  String searchQuery = "";
  Map<String, bool> productFavoriteStatus = {};
  List<dynamic> collections = [];

  @override
  void initState() {
    super.initState();
    _request = CookieRequest();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadProducts();
    await fetchCollections();
  }

  Future<List<ProductEntry>> fetchProduct(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json/');

    // Decode response menjadi bentuk JSON
    var data = response;

    // Konversi data JSON menjadi daftar objek ProductEntry
    List<ProductEntry> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(ProductEntry.fromJson(d));
      }
    }
    return listProduct;
  }

  Future<void> _loadProducts() async {
    try {
      final products = await fetchProduct(_request);
      setState(() {
        allProducts = products;
        filteredProducts = products;
      });
      await checkWishlistStatus();
    } catch (error) {
      // Tangani error, misalnya tampilkan pesan kepada pengguna
      debugPrint("Error loading products: $error");
    }
  }

  Future<void> checkWishlistStatus() async {
    if (allProducts.isEmpty) return;

    final response = await _request.get('http://127.0.0.1:8000/wishlist/wishlist-json/');

    if (response != null) {
      CollectionWishlist wishlistData = CollectionWishlist.fromJson(response);
      Map<String, bool> newStatus = {};

      for (var product in allProducts) {
        String productId = "${product.pk}";
        newStatus[productId] = false;
      }

      // Check each collection for products
      for (var collection in wishlistData.collections) {
        for (var item in collection.items) {
          newStatus[item.productId] = true;
        }
      }

      if (mounted) {
        setState(() {
          productFavoriteStatus = newStatus;
        });
      }
    }
  }

  Future<void> fetchCollections() async {
    final response = await _request.get('http://127.0.0.1:8000/wishlist/wishlist-json/');
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

  Future<void> _removeFromWishlist(String productId) async {
    final response = await _request.post(
      'http://127.0.0.1:8000/wishlist/remove-wishlist/$productId/',
      jsonEncode({}),
    );

    if (response['success'] == true) {
      setState(() {
        productFavoriteStatus[productId] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove from wishlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCollectionSelectionDialog(String productId) async {
    // Fetch collections if they haven't been loaded yet
    if (collections.isEmpty) {
      await fetchCollections();
    }

    if (collections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No collections available. Please create a collection first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
                                const Icon(Icons.folder, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    collection['collection_name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                                await _addToCollection(productId, selectedCollectionId!);
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

  Future<void> _addToCollection(String productId, String collectionId) async {
    final response = await _request.post(
      'http://127.0.0.1:8000/wishlist/add-to-wishlist/$productId/',
      jsonEncode({
        'collection_id': collectionId,
      }),
    );

    if (response['success'] == true) {
      setState(() {
        productFavoriteStatus[productId] = true;
      });
      if (mounted) {
        String collectionName = collections
            .firstWhere((c) => c['collection_id'].toString() == collectionId)['collection_name'];
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
          const SnackBar(
            content: Text('Failed to add to collection'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _searchProducts(String query) {
    final results = allProducts.where((product) {
      final nameLower = product.fields.productName.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Products"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: "Search by product name...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("No products found."))
                : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.63,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (_, index) {
                final product = filteredProducts[index];
                final productId = "${product.pk}";
                return InkWell(
                  onTap: () {
                    // Navigasi ke DummyPage saat card diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(id: productId),
                      ),
                    );
                  },
                  child: Card(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                    "${product.fields.productImage}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "${product.fields.productName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                "Rp ${product.fields.productPrice}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.yellow, size: 16.0),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    "${product.fields.productRating}",
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  const Icon(Icons.store, size: 16.0, color: Colors.grey),
                                  const SizedBox(width: 4.0),
                                  Expanded(
                                    child: Text(
                                      "${product.fields.storeName}",
                                      style: const TextStyle(fontSize: 12.0),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              productFavoriteStatus[productId] == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: productFavoriteStatus[productId] == true
                                  ? Colors.red
                                  : null,
                            ),
                            onPressed: () {
                              if (productFavoriteStatus[productId] == true) {
                                _removeFromWishlist(productId);
                              } else {
                                _showCollectionSelectionDialog(productId);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}