import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:furnico/theo/screens/dummy.dart';
import 'package:furnico/theo/screens/show_category.dart';
import 'package:furnico/theo/screens/show_productall.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';

class CategoryCarousel extends StatefulWidget {
  const CategoryCarousel({Key? key}) : super(key: key);

  @override
  State<CategoryCarousel> createState() => _Homepage();
}

class _Homepage extends State<CategoryCarousel> {
  Future<List<Category>> fetchProduct(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json_cat/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object Category
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
    return FutureBuilder<List<Category>>(
      future: fetchProduct(request),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories available.'));
        } else {
          final categories = snapshot.data!;
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
                          categoryId: 'All',
                        );
                      },
                    ),
                    // Card lainnya untuk setiap kategori
                    ...categories.map((category) {
                      return Builder(
                        builder: (BuildContext context) {
                          return buildCategoryCard(
                            context: context,
                            imageUrl: category.fields.imageUrl ?? 'assets/images/default.jpg',
                            categoryName: category.fields.categoryName,
                            categoryId: category.pk,
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
                    enableInfiniteScroll: false,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildCategoryCard({
    required BuildContext context,
    required String imageUrl,
    required String categoryName,
    required String categoryId,
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
                Image.network(
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
                if (!isAllCategories) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategoryPage(categoryId: categoryId, categoryName: categoryName,)),
                      );
                    },
                    child: Text(categoryName),
                  )
                ]
                else ... [
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
                  )
                ],
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
                        MaterialPageRoute(builder: (context) => CategoryPage(categoryId: categoryId, categoryName: categoryName,)),
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

  void _deleteCategoryFromServer() {
    print('Kategori dihapus dari server.');
  }
}
