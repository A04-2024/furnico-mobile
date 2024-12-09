enum Reason {
  infoError,
  imageError,
  websiteIssue,
  pricingError,
  outOfStock,
  slowPerformance,
  layoutIssue,
  other,
}

String reasonToString(Reason reason) {
  switch (reason) {
    case Reason.infoError:
      return 'Kesalahan info furniture';
    case Reason.imageError:
      return 'Gambar furniture salah atau kurang jelas';
    case Reason.websiteIssue:
      return 'Masalah pada website';
    case Reason.pricingError:
      return 'Kesalahan harga';
    case Reason.outOfStock:
      return 'Barang tidak tersedia';
    case Reason.slowPerformance:
      return 'Website lambat atau tidak responsif';
    case Reason.layoutIssue:
      return 'Tampilan website tidak rapi';
    case Reason.other:
      return 'Lainnya';
  }
}

Reason stringToReason(String reasonStr) {
  switch (reasonStr) {
    case 'info_error':
      return Reason.infoError;
    case 'image_error':
      return Reason.imageError;
    case 'website_issue':
      return Reason.websiteIssue;
    case 'pricing_error':
      return Reason.pricingError;
    case 'out_of_stock':
      return Reason.outOfStock;
    case 'slow_performance':
      return Reason.slowPerformance;
    case 'layout_issue':
      return Reason.layoutIssue;
    case 'other':
      return Reason.other;
    default:
      return Reason.other;
  }
}

class Report {
  final int id;
  final String user; // Menggunakan username langsung
  final String furniture; // Menggunakan nama furniture langsung
  final String reason;
  final String additionalInfo;
  final DateTime dateReported;

  Report({
    required this.id,
    required this.user,
    required this.furniture,
    required this.reason,
    required this.additionalInfo,
    required this.dateReported,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      user: json['user'],
      furniture: json['furniture'],
      reason: json['reason'],
      additionalInfo: json['additional_info'],
      dateReported: DateTime.parse(json['date_reported']),
    );
  }
}
