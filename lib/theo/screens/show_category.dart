import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:furnico/main.dart';
import 'package:furnico/theo/screens/dummy.dart';
import 'package:furnico/theo/screens/show_product_individual.dart';
import 'package:furnico/theo/widgets/categoryCarousel.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/product_entry.dart';
import 'add_category.dart';
import 'add_product.dart';

class CategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryPage({super.key, required this.categoryId, required this.categoryName});
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Future<List<ProductEntry>> fetchProduct(CookieRequest request) async {
    final response = await request.get(
        'http://127.0.0.1:8000/json_filtered/${widget.categoryId}/');

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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Furnico',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        iconTheme: const IconThemeData(color: Colors.white),
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
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Jelajahi ${widget.categoryName} unggulan kami',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Temukan beragam ${widget
                              .categoryName} yang sesuai dengan gaya dan kebutuhan anda',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: CategoryCarousel(),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Produk Populer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0,
                                ),
                              ),
                              const Text(
                                'Temukan penawaran menarik untuk melihat yang sedang hits di Furnico',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ]
                        ),
                      ),

                      Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.black45,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (
                                              context) => const ProductEntryFormPage()),
                                    );
                                  },
                                  child: const Text('Tambah Produk Baru'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.black45,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (
                                              context) => const CategoryEntryFormPage()),
                                    );
                                  },
                                  child: const Text('Tambah Kategori Baru'),
                                ),
                              ]
                          )
                      ),

                      if (!snapshot.hasData || snapshot.data.isEmpty) ... [
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Belum ada produk di kategori ini!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                    color: Colors.red,
                                  ),
                                ),
                                const Text(
                                  'Temukan penawaran menarik di kategori lainnya untuk melihat yang sedang hits di Furnico',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.red,
                                  ),
                                ),
                              ]
                          ),
                        ),
                      ]
                      else ... [
                        // ini produk-produk
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0, top: 10, right: 0, bottom: 10),
                          child: SizedBox(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.6, // Adjust height as needed
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 0.63,
                              ),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (_, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailPage(
                                                id: "${snapshot.data![index]
                                                    .pk}"),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                  12.0),
                                              child: Image.network(
                                                "${snapshot.data![index].fields
                                                    .productImage}",
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) =>
                                                    Icon(Icons.broken_image,
                                                        size: 50,
                                                        color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            "${snapshot.data![index].fields
                                                .productName}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            "Rp ${snapshot.data![index].fields
                                                .productPrice}",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Colors.yellow,
                                                  size: 16.0),
                                              const SizedBox(width: 4.0),
                                              Text(
                                                "${snapshot.data![index].fields
                                                    .productRating}",
                                                style: const TextStyle(
                                                    fontSize: 12.0),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4.0),
                                          Row(
                                            children: [
                                              const Icon(Icons.store, size: 16.0,
                                                  color: Colors.grey),
                                              const SizedBox(width: 4.0),
                                              Expanded(
                                                child: Text(
                                                  "${snapshot.data![index].fields
                                                      .storeName}",
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
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
                        ),
                      ],

                      const SizedBox(height: 20),

                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Terbaru di Furnico',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0,
                                ),
                              ),
                              const Text(
                                'Butuh inspirasi? Cek ide-ide ruangan kami yang telah dikurasi di artikel Furnico!',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ]
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black45,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DummyPage()),
                            );
                          },
                          child: const Text('Kunjungi Artikel Furnico'),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          }

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
            _buildFooterIcon(context, Icons.home, 'Home', DummyPage()),
            _buildFooterIcon(context, Icons.search, 'Search', DummyPage()),
            _buildFooterIcon(context, Icons.favorite, 'Wishlist', DummyPage()),
            _buildFooterIcon(context, Icons.article, 'Article', DummyPage()),
            _buildFooterIcon(context, Icons.person, 'Profile', DummyPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterIcon(BuildContext context, IconData icon, String label,
      Widget page) {
    return GestureDetector(
      onTap: () {
        // Menavigasi ke halaman lain
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade700),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}