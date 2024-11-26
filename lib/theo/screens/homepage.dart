import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:furnico/theo/screens/dummy.dart';
import 'package:furnico/theo/widgets/categoryCarousel.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Furnico',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              CarouselSlider(
                items: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DummyPage()),
                      );
                    },
                    child: Image.asset('assets/images/image1.jpg', fit: BoxFit.cover),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DummyPage()),
                      );
                    },
                    child: Image.asset('assets/images/image2.jpg', fit: BoxFit.cover),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DummyPage()),
                      );
                    },
                    child: Image.asset('assets/images/image3.jpg', fit: BoxFit.cover),
                  ),
                ],
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Halo Username! Jelajahi kategori unggulan kami',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Temukan beragam produk yang sesuai dengan gaya dan kebutuhan anda',
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
                              builder: (context) => const DummyPage()),
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
                              builder: (context) => const DummyPage()),
                        );
                      },
                      child: const Text('Tambah Kategori Baru'),
                    ),
                  ]
                )
              ),

              // ini produk-produk


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

  Widget _buildFooterIcon(BuildContext context, IconData icon, String label, Widget page) {
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
