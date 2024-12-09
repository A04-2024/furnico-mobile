// data/dummy_data.dart

import '../models/user_dummy.dart';
import '../models/product_dummy.dart';

// Dummy Users
final User adminUser = User(
  id: 1,
  username: 'admin',
  email: 'admin@example.com',
  role: 'admin',
);

final User regularUser = User(
  id: 2,
  username: 'john_doe',
  email: 'john@example.com',
  role: 'user',
);

// Dummy Products
final Product sofa = Product(
  id: 101,
  name: 'Sofa Minimalis',
  description: 'Sofa minimalis dengan warna abu-abu dan material kain berkualitas.',
  price: 1500.00,
  imageUrl: 'https://example.com/images/sofa_minimalis.jpg',
);

final Product meja = Product(
  id: 102,
  name: 'Meja Makan Kayu',
  description: 'Meja makan terbuat dari kayu jati, cocok untuk 6 orang.',
  price: 1200.00,
  imageUrl: 'https://example.com/images/meja_makan_kayu.jpg',
);

final Product kursi = Product(
  id: 103,
  name: 'Kursi Kantor Ergonomis',
  description: 'Kursi kantor dengan desain ergonomis untuk kenyamanan maksimal.',
  price: 800.00,
  imageUrl: 'https://example.com/images/kursi_kantor_ergonomis.jpg',
);

// // Dummy Reports
// final List<Report> dummyReports = [
//   Report(
//     id: 201,
//     user: regularUser,
//     furniture: sofa,
//     reason: Reason.infoError,
//     additionalInfo: 'Deskripsi sofa tidak mencantumkan ukuran secara lengkap.',
//     dateReported: DateTime.now().subtract(Duration(days: 2)),
//   ),
//   Report(
//     id: 202,
//     user: regularUser,
//     furniture: meja,
//     reason: Reason.imageError,
//     additionalInfo: 'Gambar meja terlihat buram dan tidak jelas.',
//     dateReported: DateTime.now().subtract(Duration(days: 1)),
//   ),
//   Report(
//     id: 203,
//     user: adminUser,
//     furniture: kursi,
//     reason: Reason.pricingError,
//     additionalInfo: 'Harga kursi kantor seharusnya 750.00, bukan 800.00.',
//     dateReported: DateTime.now(),
//   ),
// ];
