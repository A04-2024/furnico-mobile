import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furnico/report/models/report.dart';
import 'package:furnico/report/models/user_dummy.dart';
import 'package:furnico/theo/screens/show_product_individual.dart';
import 'package:http/http.dart' as http;

class EditReportFormPage extends StatefulWidget {
  final Report existingReport;
  final User currentUser;

  const EditReportFormPage({
    required this.existingReport,
    required this.currentUser,
    super.key,
  });

  @override
  State<EditReportFormPage> createState() => _EditReportFormPageState();
}

class _EditReportFormPageState extends State<EditReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  String? _additionalInfo;
  bool _isSubmitting = false;

  // Daftar opsi alasan
  final List<Map<String, String>> _reasons = [
    {'value': 'Kesalahan info furniture', 'label': 'Kesalahan info furniture'},
    {'value': 'Gambar furniture salah atau kurang jelas', 'label': 'Gambar furniture salah atau kurang jelas'},
    {'value': 'Masalah pada website', 'label': 'Masalah pada website'},
    {'value': 'Website lambat atau tidak responsif', 'label': 'Website lambat atau tidak responsif'},
    {'value': 'Tampilan website tidak rapi', 'label': 'Tampilan website tidak rapi'},
    {'value': 'Lainnya', 'label': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedReason = widget.existingReport.reason;
    _additionalInfo = widget.existingReport.additionalInfo;
  }

  // Fungsi untuk mengirim laporan
  Future<void> _submitEditReport() async {
    // Validasi form
    if (!_formKey.currentState!.validate() || _selectedReason == null) {
      _showErrorDialog('Silakan pilih alasan dan lengkapi form.');
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isSubmitting = true;
    });

    // Mengirim laporan ke server
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/report/edit_report_mobile/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'report_id': widget.existingReport.id, 
          'user': widget.currentUser.id,
          'furniture': widget.existingReport.furnitureId,
          'reason': _selectedReason!,
          'additional_info': _additionalInfo ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          _showSuccessDialog('Laporan berhasil diperbarui.', navigateBack: true);
        } else {
          _showErrorDialog(responseBody['message'] ?? 'Terjadi kesalahan. Silakan coba lagi.');
        }
      } else {
        _showErrorDialog(
            'Terjadi kesalahan. Status code: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Fungsi untuk menghapus laporan
  Future<void> _deleteReport(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penghapusan'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
        actions: [
          // Tombol batal menghapus laporan
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          // Tombol menghapus laporan
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    Navigator.pop(context); // Tutup dialog 
                    Navigator.pop(context); // Tutup modal edit laporan
                    Navigator.pushReplacement( // Refresh halaman produk
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductDetailPage(id: widget.existingReport.furnitureId),
                      ));
                  },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // Jika pengguna mengklik tombol menghapus laporan
    if (confirm == true) {
      setState(() {
        _isSubmitting = true;
      });

      // Menghapus laporan
      try {
        final response = await http.post(
          Uri.parse("http://127.0.0.1:8000/report/delete_report_mobile/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'report_id': widget.existingReport.id}),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          if (responseBody['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Laporan berhasil dihapus.')),
            );
            Navigator.pop(context); // Tutup halaman edit laporan
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  // Fungsi untuk menampilkan dialog sukses
  void _showSuccessDialog(String message, {bool navigateBack = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              if (navigateBack) {
                Navigator.pop(context); // Tutup modal edit laporan
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan dialog gagal
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Laporan Produk'),
        actions: [
          // Tombol hapus
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _isSubmitting ? null : () => _deleteReport(context), // Perbaikan di sini
            tooltip: 'Hapus Laporan',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // RadioListTile untuk setiap opsi alasan
              ..._reasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason['label']!),
                  value: reason['value']!,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 16),

              // TextFormField untuk informasi tambahan
              TextFormField(
                initialValue: _additionalInfo,
                decoration: const InputDecoration(
                  labelText: 'Informasi Tambahan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _additionalInfo = value;
                },
              ),
              const SizedBox(height: 20),

              // Tombol untuk kembali dan kirim laporan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tombol Batal
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            Navigator.pop(context); // Kembali ke halaman sebelumnya
                          },
                    child: const Text('Batal'),
                  ),
                  // Tombol Update Laporan
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.yellow.shade700,
                    ),
                    onPressed: _isSubmitting ? null : _submitEditReport,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Update Laporan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
