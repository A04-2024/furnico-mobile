// lib/report/models/product_dummy.dart

import 'package:furnico/theo/models/product_entry.dart';

// Daftar produk dummy
List<ProductEntry> dummyProducts = [
  ProductEntry(
    pk: '1',
    fields: Fields(
      productImage: 'https://via.placeholder.com/150',
      productName: 'Sofa Elegant',
      productSubtitle: 'Sofa dengan desain modern',
      productPrice: 1500000,
      soldThisWeek: 10,
      peopleBought: 50,
      productDescription: 'Sofa ini terbuat dari bahan berkualitas tinggi dengan desain yang elegan.',
      productAdvantages: 'Nyaman, tahan lama, dan mudah dibersihkan.',
      productMaterial: 'Kulit sintetis',
      productSizeLength: 200,
      productSizeHeight: 100,
      productSizeLong: 80,
      productCategory: 'Furniture',
      productRating: 4,
      storeName: 'Toko Furniture A',
      storeAddress: 'Jl. Merdeka No. 10, Jakarta',
      inWishlist: false,
    ),
  ),
  ProductEntry(
    pk: '2',
    fields: Fields(
      productImage: 'https://via.placeholder.com/150',
      productName: 'Meja Makan Kayu',
      productSubtitle: 'Meja makan dengan empat kursi',
      productPrice: 2500000,
      soldThisWeek: 5,
      peopleBought: 30,
      productDescription: 'Meja makan terbuat dari kayu jati asli dengan desain klasik.',
      productAdvantages: 'Stabil, estetis, dan mudah dipadukan dengan dekorasi lainnya.',
      productMaterial: 'Kayu Jati',
      productSizeLength: 180,
      productSizeHeight: 75,
      productSizeLong: 90,
      productCategory: 'Furniture',
      productRating: 5,
      storeName: 'Toko Furniture B',
      storeAddress: 'Jl. Sudirman No. 20, Bandung',
      inWishlist: true,
    ),
  ),
  // Tambahkan lebih banyak produk dummy sesuai kebutuhan
];
