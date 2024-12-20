// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

List<Category> categoryFromJson(String str) => List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
  Model model;
  String pk;
  Fields fields;

  Category({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    model: modelValues.map[json["model"]]!,
    pk: json["pk"],
    fields: Fields.fromJson(json["fields"]),
  );

  Map<String, dynamic> toJson() => {
    "model": modelValues.reverse[model],
    "pk": pk,
    "fields": fields.toJson(),
  };
}

class Fields {
  String categoryName;
  int uniqueProducts;
  String imageUrl;

  Fields({
    required this.categoryName,
    required this.uniqueProducts,
    required this.imageUrl,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    categoryName: json["category_name"],
    uniqueProducts: json["unique_products"],
    imageUrl: json["image_url"],
  );

  Map<String, dynamic> toJson() => {
    "category_name": categoryName,
    "unique_products": uniqueProducts,
    "image_url": imageUrl,
  };
}

enum Model {
  SHOW_PRODUCTS_CATEGORIES
}

final modelValues = EnumValues({
  "show_products.categories": Model.SHOW_PRODUCTS_CATEGORIES
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
