// // widgets/report_item_widget.dart

// import 'package:flutter/material.dart';
// import '../models/report.dart';

// class ReportItemWidget extends StatelessWidget {
//   final Report report;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   ReportItemWidget({
//     required this.report,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text('Furniture ID: ${report.furnitureId}'),
//       subtitle: Text(reasonToString(report.reason)),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             icon: Icon(Icons.edit),
//             onPressed: onEdit,
//           ),
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: onDelete,
//           ),
//         ],
//       ),
//     );
//   }
// }
