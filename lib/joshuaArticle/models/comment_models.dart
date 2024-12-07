// To parse this JSON data, do
//
//     final commentEntry = commentEntryFromJson(jsonString);

import 'dart:convert';

List<CommentEntry> commentEntryFromJson(String str) => List<CommentEntry>.from(json.decode(str).map((x) => CommentEntry.fromJson(x)));

String commentEntryToJson(List<CommentEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CommentEntry {
    String body;
    DateTime createdAt;
    String userUsername;

    CommentEntry({
        required this.body,
        required this.createdAt,
        required this.userUsername,
    });

    factory CommentEntry.fromJson(Map<String, dynamic> json) => CommentEntry(
        body: json["body"],
        createdAt: DateTime.parse(json["created_at"]),
        userUsername: json["user__username"],
    );

    Map<String, dynamic> toJson() => {
        "body": body,
        "created_at": createdAt.toIso8601String(),
        "user__username": userUsername,
    };
}
