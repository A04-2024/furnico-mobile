import 'dart:convert';

List<Report> reportFromJson(String str) => List<Report>.from(json.decode(str).map((x) => Report.fromJson(x)));

String reportToJson(List<Report> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Report {
  final int id;
  final int userId;
  final String username; 
  final String furnitureId;
  final String furnitureName;
  final String reason;
  final String? additionalInfo;
  final DateTime dateReported;

  Report({
    required this.id,
    required this.userId,
    required this.username, 
    required this.furnitureId,
    required this.furnitureName,
    required this.reason,
    this.additionalInfo,
    required this.dateReported,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"],
        userId: json["user_id"],
        username: json["username"], 
        furnitureId: json["furniture_id"],
        furnitureName: json["furniture_name"],
        reason: json["reason"],
        additionalInfo: json["additional_info"],
        dateReported: DateTime.parse(json["date_reported"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "username": username,
        "furniture_id": furnitureId,
        "furniture_name": furnitureName,
        "reason": reason,
        "additional_info": additionalInfo,
        "date_reported": dateReported.toIso8601String(),
      };
}
