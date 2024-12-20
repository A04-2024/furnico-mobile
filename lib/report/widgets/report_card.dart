import 'package:flutter/material.dart';
import 'package:furnico/report/models/report.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:furnico/report/models/user_dummy.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final User currentUser;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ReportCard({
    required this.report,
    required this.currentUser,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  Future<void> _deleteReport(BuildContext context) async {
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

    if (confirm == true) {
      // Mengirim permintaan penghapusan ke backend
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/report/delete_report_mobile/"),
        body: jsonEncode({'report_id': report.id}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan berhasil dihapus.')),
          );
          onDelete(); // Memanggil callback untuk memperbarui daftar
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
            Text('ID Laporan: ${report.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Alasan: ${report.reason}'),
            const SizedBox(height: 8),
            if (report.additionalInfo != null && report.additionalInfo!.isNotEmpty)
              Text('Informasi Tambahan: ${report.additionalInfo}'),
            const SizedBox(height: 8),
            Text('Tanggal Laporan: ${report.dateReported.toLocal()}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () => _deleteReport(context),
                  child: const Text('Hapus Laporan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}