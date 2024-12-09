// lib/report/widgets/edit_report_form.dart

import 'package:flutter/material.dart';
import '../models/report.dart';
// import '../models/user_dummy.dart';
// import '../models/product_dummy.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditReportForm extends StatefulWidget {
  final Report report;
  final Function(Report) onReportEdited;

  const EditReportForm({
    required this.report,
    required this.onReportEdited,
    Key? key,
  }) : super(key: key);

  @override
  _EditReportFormState createState() => _EditReportFormState();
}

class _EditReportFormState extends State<EditReportForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  final TextEditingController _additionalInfoController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedReason = widget.report.reason;
    _additionalInfoController.text = widget.report.additionalInfo;
  }

  // Future<void> _submitEdit() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() {
  //     _isSubmitting = true;
  //   });

  //   final request = context.read<CookieRequest>();

  //   // Ganti [APP_URL_KAMU] dengan URL backend Anda
  //   final response = await request.put(
  //     "http://[APP_URL_KAMU]/report/update_report/${widget.report.id}/",
  //     {
  //       'reason': _selectedReason!,
  //       'additional_info': _additionalInfoController.text,
  //     },
  //   );

  //   setState(() {
  //     _isSubmitting = false;
  //   });

  //   if (response['success'] == true) {
  //     // Buat objek Report baru dengan data yang diperbarui
  //     final updatedReport = Report(
  //       id: widget.report.id,
  //       user: widget.report.user,
  //       furniture: widget.report.furniture,
  //       reason: _selectedReason!,
  //       additionalInfo: _additionalInfoController.text,
  //       dateReported: widget.report.dateReported, // Atau update tanggal jika diperlukan
  //     );

  //     widget.onReportEdited(updatedReport);

  //     Navigator.of(context).pop(); // Tutup dialog

  //     // Tampilkan pesan berhasil
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         content: const Text('Laporan berhasil diperbarui!'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Keluar'),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     // Tampilkan pesan error
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Gagal memperbarui laporan: ${response['message']}')),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Membungkus konten dengan scroll
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Mengambil ukuran minimum
          children: [
            const Text(
              'Edit Laporan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Pilih Alasan Laporan:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ...Reason.values.map((reason) {
                    return RadioListTile<String>(
                      title: Text(reasonToString(reason)),
                      value: reason.toString().split('.').last, // Mengambil string dari enum
                      groupValue: _selectedReason,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _additionalInfoController,
                    decoration: const InputDecoration(
                      labelText: 'Info Tambahan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan masukkan info tambahan.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _selectedReason == null ? null : null, //_submitEdit,
                          child: const Text('Perbarui'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50), // Button full width
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
