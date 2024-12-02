import 'package:flutter/material.dart';
import 'package:furnico/theo/models/product_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:furnico/theo/screens/show_product_individual.dart';

class ShowProductAll extends StatefulWidget {
  const ShowProductAll({super.key});

  @override
  State<ShowProductAll> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ShowProductAll> {
  Future<List<ProductEntry>> fetchProduct(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json/');

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
        title: const Text('Products in Furnico'),
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
              return Column(
                children: [
                  const Text(
                    'Belum ada data Product pada furnico.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            } else {
              // Menampilkan grid produk
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Dua card per baris
                    crossAxisSpacing: 8.0, // Spasi horizontal antar card
                    mainAxisSpacing: 8.0, // Spasi vertikal antar card
                    childAspectRatio: 0.63, // Rasio lebar dan tinggi card
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) {
                    return InkWell(
                        onTap: () {
                      // Navigasi ke DummyPage saat card diklik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(id: "${snapshot.data![index].pk}"),
                        ),
                      );
                    },
                      child: Card(
                      elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        clipBehavior: Clip.antiAlias, // Mencegah overflow
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gambar produk
                              AspectRatio(
                                aspectRatio: 1, // Rasio 1:1
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                    "${snapshot.data![index].fields.productImage}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              // Nama produk
                              Text(
                                "${snapshot.data![index].fields.productName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              // Harga
                              Text(
                                "Rp ${snapshot.data![index].fields.productPrice}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              // Rating
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.yellow, size: 16.0),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    "${snapshot.data![index].fields.productRating}",
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              // Nama toko
                              Row(
                                children: [
                                  const Icon(Icons.store, size: 16.0, color: Colors.grey),
                                  const SizedBox(width: 4.0),
                                  Expanded(
                                    child: Text(
                                      "${snapshot.data![index].fields.storeName}",
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
                      )
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}
