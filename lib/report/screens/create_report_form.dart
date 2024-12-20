import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furnico/report/models/user_dummy.dart';
import 'package:furnico/theo/screens/show_product_individual.dart';
import 'package:http/http.dart' as http;

class CreateReportFormPage extends StatefulWidget {
  final String productId;
  final User currentUser;

  const CreateReportFormPage({
    required this.productId,
    required this.currentUser,
    super.key,
  });

  @override
  State<CreateReportFormPage> createState() => _CreateReportFormPageState();
}

class _CreateReportFormPageState extends State<CreateReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  String? _additionalInfo;
  bool _isSubmitting = false; // State untuk loading

  // Daftar alasan
  final List<Map<String, String>> _reasons = [
    {'value': 'Kesalahan info furniture', 'label': 'Kesalahan info furniture'},
    {'value': 'Gambar furniture salah atau kurang jelas', 'label': 'Gambar furniture salah atau kurang jelas'},
    {'value': 'Masalah pada website', 'label': 'Masalah pada website'},
    {'value': 'Website lambat atau tidak responsif', 'label': 'Website lambat atau tidak responsif'},
    {'value': 'Tampilan website tidak rapi', 'label': 'Tampilan website tidak rapi'},
    {'value': 'Lainnya', 'label': 'Lainnya'},
  ];

  // Fungsi untuk mengubah state ketika user memilih alasan
  Future<void> _submitReport() async {
    // Validasi form
    if (!_formKey.currentState!.validate() || _selectedReason == null) {
      _showErrorDialog('Silakan pilih alasan dan lengkapi form.');
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isSubmitting = true;
    });

    // Mengirim laporan
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/report/create_report_mobile/"),
        body: jsonEncode({
          'user': widget.currentUser.id,
          'furniture': widget.productId,
          'reason': _selectedReason!,
          'additional_info': _additionalInfo ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          _showSuccessDialog('Laporan berhasil dikirim.');
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

  // Fungsi untuk menampilkan dialog sukses
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke halaman sebelumnya
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
        title: const Text('Laporkan Produk'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Menggunakan RadioListTile untuk setiap opsi alasan
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
                  // Tombol Kembali
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            Navigator.pop(context); // Kembali ke halaman sebelumnya
                            Navigator.pushReplacement( // Refresh halaman sebelumnya
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(id: widget.productId),
                              ));
                          },
                    child: const Text('Kembali'),
                  ),
                  // Tombol Kirim Laporan
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _isSubmitting ? null : _submitReport,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Kirim Laporan'),
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