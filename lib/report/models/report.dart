import 'dart:convert';

List<Report> reportFromJson(String str) => List<Report>.from(json.decode(str).map((x) => Report.fromJson(x)));

String reportToJson(List<Report> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Report {
  final int id;
  final int userId;
  final String furnitureId;
  final String reason;
  final String? additionalInfo;
  final DateTime dateReported;

  Report({
    required this.id,
    required this.userId,
    required this.furnitureId,
    required this.reason,
    this.additionalInfo,
    required this.dateReported,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"],
        userId: json["user_id"],
        furnitureId: json["furniture_id"],
        reason: json["reason"],
        additionalInfo: json["additional_info"],
        dateReported: DateTime.parse(json["date_reported"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "furniture_id": furnitureId,
        "reason": reason,
        "additional_info": additionalInfo,
        "date_reported": dateReported.toIso8601String(),
      };
}
