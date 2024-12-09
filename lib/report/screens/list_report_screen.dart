// lib/report/screens/report_list_screen.dart

import 'package:flutter/material.dart';
import '../widgets/list_report.dart';
import '../../report/models/user_dummy.dart';

class ReportListScreen extends StatefulWidget {
  final User currentUser;

  const ReportListScreen({required this.currentUser, Key? key}) : super(key: key);

  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Laporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ReportList(currentUser: widget.currentUser),
    );
  }
}