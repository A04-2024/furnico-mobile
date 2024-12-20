import 'package:flutter/material.dart';
import 'package:furnico/report/models/report.dart';
import 'package:furnico/report/models/user_dummy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:furnico/report/widgets/report_card.dart';

class ReportListScreen extends StatefulWidget {
  final User currentUser;

  const ReportListScreen({required this.currentUser, super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late Future<List<Report>> _futureReports;

  @override
  void initState() {
    super.initState();
    _futureReports = fetchReports();
  }

  Future<List<Report>> fetchReports() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/report/get_reports_mobile/"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> reportJson = jsonDecode(response.body);
      return reportJson.map((json) => Report.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat laporan');
    }
  }

  void _refreshReports() {
    setState(() {
      _futureReports = fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Laporan'),
        ),
        body: FutureBuilder<List<Report>>(
          future: _futureReports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada laporan.'));
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  _refreshReports();
                },
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final report = snapshot.data![index];
                    return ReportCard(
                      report: report,
                      currentUser: widget.currentUser,
                      onDelete: _refreshReports,
                      onEdit: _refreshReports,
                    );
                  },
                ),
              );
            }
          },
        ));
  }
}