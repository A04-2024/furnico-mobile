import 'package:flutter/material.dart';
import 'package:furnico/theo/screens/show_product_individual.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _request = CookieRequest(); // Inisialisasi objek CookieRequest
    _loadProducts();
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
    } catch (error) {
      // Tangani error, misalnya tampilkan pesan kepada pengguna
      debugPrint("Error loading products: $error");
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
                return InkWell(
                    onTap: () {
                  // Navigasi ke DummyPage saat card diklik
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(id: "${product.pk}"),
                    ),
                  );
                },
                child: Card(
                  child: Padding(
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