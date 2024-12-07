// To parse this JSON data, do
//
//     final articleEntry = articleEntryFromJson(jsonString);

import 'dart:convert';

List<ArticleEntry> articleEntryFromJson(String str) => List<ArticleEntry>.from(json.decode(str).map((x) => ArticleEntry.fromJson(x)));

String articleEntryToJson(List<ArticleEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArticleEntry {
    String model;
    int pk;
    Fields fields;

    ArticleEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ArticleEntry.fromJson(Map<String, dynamic> json) => ArticleEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String article;
    int user;
    String name;
    String body;
    DateTime createdAt;

    Fields({
        required this.article,
        required this.user,
        required this.name,
        required this.body,
        required this.createdAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        article: json["article"],
        user: json["user"],
        name: json["name"],
        body: json["body"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "article": article,
        "user": user,
        "name": name,
        "body": body,
        "created_at": createdAt.toIso8601String(),
    };
}
