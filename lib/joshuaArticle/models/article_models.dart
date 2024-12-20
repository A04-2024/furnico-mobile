// To parse this JSON data, do
//
//     final articleEntry = articleEntryFromJson(jsonString);

import 'dart:convert';

List<ArticleEntry> articleEntryFromJson(String str) => List<ArticleEntry>.from(json.decode(str).map((x) => ArticleEntry.fromJson(x)));

String articleEntryToJson(List<ArticleEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArticleEntry {
    String id;
    String title;
    DateTime createdAt;
    String content;
    String image;
    String authorUsername;

    ArticleEntry({
        required this.id,
        required this.title,
        required this.createdAt,
        required this.content,
        required this.image,
        required this.authorUsername,
    });

    factory ArticleEntry.fromJson(Map<String, dynamic> json) => ArticleEntry(
        id: json["id"],
        title: json["title"],
        createdAt: DateTime.parse(json["created_at"]),
        content: json["content"],
        image: json["image"],
        authorUsername: json["author__username"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "created_at": "${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}",
        "content": content,
        "image": image,
        "author__username": authorUsername,
    };
}
