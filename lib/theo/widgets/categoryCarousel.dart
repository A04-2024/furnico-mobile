import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:furnico/theo/screens/dummy.dart';
import 'package:furnico/theo/screens/show_productall.dart';
import 'package:furnico/theo/models/product_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';

class CategoryCarousel extends StatefulWidget {
  const CategoryCarousel({Key? key}) : super(key: key);

  @override
  State<CategoryCarousel> createState() => _Homepage();
}

class _Homepage extends State<CategoryCarousel> {
  // Dummy data kategori, bisa diganti dengan data dari server Django
  final List<Map<String, String>> categories = [
  {
  'image': 'assets/images/image1.jpg', // Ganti dengan URL gambar dari server Django
  'name': 'Kategori 1',
  },
  {
  'image': 'assets/images/image2.jpg', // Ganti dengan URL gambar dari server Django
  'name': 'Kategori 2',
  },
  {
  'image': 'assets/images/image3.jpg', // Ganti dengan URL gambar dari server Django
  'name': 'Kategori 3',
  },
  ];

  Future<List<Category>> fetchProduct(CookieRequest request) async {
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return SingleChildScrollView(
      child: Column(
        children: [
          CarouselSlider(
            items: [
              // Card pertama untuk "All Categories"
              Builder(
                builder: (BuildContext context) {
                  return buildCategoryCard(
                    context: context,
                    imageUrl: 'assets/images/image1.jpg', // Gambar default
                    categoryName: 'All Categories',
                    isAllCategories: true,
                  );
                },
              ),
              // Card lainnya untuk setiap kategori
              ...categories.map((category) {
                return Builder(
                  builder: (BuildContext context) {
                    return buildCategoryCard(
                      context: context,
                      imageUrl: category['image']!,
                      categoryName: category['name']!,
                    );
                  },
                );
              }).toList(),
            ],
            options: CarouselOptions(
              height: 350.0,
              autoPlay: false,
              enlargeCenterPage: true,
              aspectRatio: 3 / 5,
              viewportFraction: 0.8,
              enableInfiniteScroll: false, // Tidak memungkinkan geser ke kiri dari awal
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCard({
    required BuildContext context,
    required String imageUrl,
    required String categoryName,
    bool isAllCategories = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gambar kategori dengan overlay shadow
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  color: Colors.black.withOpacity(0.5), // Overlay shadow
                  width: double.infinity,
                  height: double.infinity,
                ),
              ],
            ),
          ),
          // Tombol-tombol di tengah gambar
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShowProductAll()),
                    );
                  },
                  child: Text(categoryName),
                ),
                const SizedBox(height: 10),
                if (!isAllCategories) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DummyPage()),
                      );
                    },
                    child: const Text('Edit Kategori'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context);
                    },
                    child: const Text('Hapus Kategori'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi penghapusan
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah anda yakin?'),
          actions: [
            Row(
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
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _deleteCategoryFromServer();
                    Navigator.of(context).pop();
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

  // Fungsi untuk menghapus kategori dari server Django
  void _deleteCategoryFromServer() {
    print('Kategori dihapus dari server.');
  }
}
