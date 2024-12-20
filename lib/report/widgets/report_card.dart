import 'package:flutter/material.dart';
import 'package:furnico/report/models/report.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:furnico/report/models/user_dummy.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final User currentUser;
  final VoidCallback onDelete; // Callback untuk memperbarui daftar

  const ReportCard({
    required this.report,
    required this.currentUser,
    required this.onDelete,
    super.key,
  });

  // Fungsi untuk menghapus report
  Future<void> _deleteReport(BuildContext context) async {
    // Menampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penghapusan'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // Jika pengguna memilih "Hapus"
    if (confirm == true) {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/report/delete_report_mobile/"),
        headers: {'Content-Type': 'application/json'}, // Menambahkan header
        body: jsonEncode({'report_id': report.id}),
      );

      if (response.statusCode == 200) {
        // Jika berhasil, memperbarui daftar report
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan berhasil dihapus.')),
          );
          onDelete(); // Memanggil callback untuk memperbarui daftar
        // Jika gagal, menampilkan pesan error
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Gagal menghapus laporan.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Isi report
            Text(report.reason, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Dilaporkan oleh: ${report.username}', style: const TextStyle(color: Colors.grey)), // Menampilkan username
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Produk: '),
                Text(report.furnitureName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            if (report.additionalInfo != null && report.additionalInfo!.isNotEmpty)
              Text('Informasi Tambahan: ${report.additionalInfo}'),
            const SizedBox(height: 8),
            Text('Tanggal Laporan: ${report.dateReported.toLocal()}'),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tombol hapus
                IconButton(
                  onPressed: () => _deleteReport(context),
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus Laporan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}