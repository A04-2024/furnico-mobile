// lib/report/widgets/report_list.dart

import 'package:flutter/material.dart';
import '../models/report.dart';
import '../../report/models/user_dummy.dart';
import '../screens/edit_report_form.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ReportList extends StatefulWidget {
  final User currentUser;

  const ReportList({required this.currentUser, Key? key}) : super(key: key);

  @override
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  late List<Report> reports;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    final request = context.read<CookieRequest>();

    // Ganti [APP_URL_KAMU] dengan URL backend Anda
    final response = await request.get(
      "http://[APP_URL_KAMU]/report/get_filtered_reports_json/",
    );

    if (response['success'] == true) {
      List<dynamic> reportsJson = response['reports'];
      setState(() {
        reports = reportsJson.map((json) => Report.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        reports = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat laporan: ${response['message']}')),
      );
    }
  }

  // Future<void> _deleteReport(int reportId) async {
  //   final request = context.read<CookieRequest>();

  //   // Ganti [APP_URL_KAMU] dengan URL backend Anda
  //   final response = await request.delete(
  //     "http://[APP_URL_KAMU]/report/delete_report/$reportId/",
  //   );

  //   if (response['success'] == true) {
  //     setState(() {
  //       reports.removeWhere((report) => report.id == reportId);
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Laporan berhasil dihapus.')),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Gagal menghapus laporan: ${response['message']}')),
  //     );
  //   }
  // }

  Future<void> _editReport(Report report) async {
    // Buka modal edit report
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8, // Maksimal 80% tinggi layar
            ),
            child: EditReportForm(
              report: report,
              onReportEdited: (Report updatedReport) {
                setState(() {
                  int index = reports.indexWhere((r) => r.id == updatedReport.id);
                  if (index != -1) {
                    reports[index] = updatedReport;
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Laporan berhasil diperbarui.')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(int reportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // _deleteReport(reportId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return reports.isEmpty
        ? const Center(child: Text('Tidak ada laporan.'))
        : RefreshIndicator(
            onRefresh: _fetchReports,
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 3.0,
                  child: ListTile(
                    title: Text(
                      report.furniture,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.reason.toUpperCase(),
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Info: ${report.additionalInfo}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tanggal: ${report.dateReported.day}/${report.dateReported.month}/${report.dateReported.year} ${report.dateReported.hour}:${report.dateReported.minute}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    trailing: (widget.currentUser.role == 'admin' || report.user == widget.currentUser.username)
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _editReport(report);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDelete(report.id);
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          );
  }
}