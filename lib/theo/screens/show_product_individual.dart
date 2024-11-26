import 'package:flutter/material.dart';
import 'package:furnico/theo/models/product_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:furnico/theo/screens/dummy.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final String id;

  const ProductDetailPage({required this.id, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFavorite = false;
  Future<List<ProductEntry>> fetchProduct(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json/${widget.id}/');

    // Melakukan decode response menjadi bentuk json
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
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            AspectRatio(
              aspectRatio: 1, // Rasio 1:1
              child: ClipRRect(
                child: Image.network(
                  "${snapshot.data![0].fields.productImage}",
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
                      "${snapshot.data![0].fields.productName}",
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
                "${snapshot.data![0].fields.productSubtitle}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, color: Colors.yellow, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${snapshot.data![0].fields.productRating}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${snapshot.data![0].fields.storeAddress}",
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
                  Text("${snapshot.data![0].fields.productDescription}"),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Panjang: ${snapshot.data![0].fields.productSizeLong} cm"),
                  Text("Lebar: ${snapshot.data![0].fields.productSizeLength} cm"),
                  Text("Tinggi: ${snapshot.data![0].fields.productSizeHeight} cm"),
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
                backgroundColor: Colors.green, // Warna hijau
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DummyPage()),
                );
              },
              child: Text('Tambah ke Wishlist',
                style: TextStyle(color: Color(0xffffffff)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna merah
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DummyPage()),
                );
              },
              child: Text('Laporkan Produk',
                style: TextStyle(color: Color(0xffffffff)),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
