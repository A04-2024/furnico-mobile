import 'dart:convert';

CollectionWishlist welcomeFromJson(String str) => CollectionWishlist.fromJson(json.decode(str));

String welcomeToJson(CollectionWishlist data) => json.encode(data.toJson());

class CollectionWishlist {
    String status;
    List<Collection> collections;

    CollectionWishlist({
        required this.status,
        required this.collections,
    });

    factory CollectionWishlist.fromJson(Map<String, dynamic> json) => CollectionWishlist(
        status: json["status"],
        collections: List<Collection>.from(json["collections"].map((x) => Collection.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "collections": List<dynamic>.from(collections.map((x) => x.toJson())),
    };
}

class Collection {
    int collectionId;
    String collectionName;
    List<Item> items;

    Collection({
        required this.collectionId,
        required this.collectionName,
        required this.items,
    });

    factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        collectionId: json["collection_id"],
        collectionName: json["collection_name"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "collection_id": collectionId,
        "collection_name": collectionName,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class Item {
    String productId;
    String productName;

    Item({
        required this.productId,
        required this.productName,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        productId: json["product_id"],
        productName: json["product_name"],
    );

    Map<String, dynamic> toJson() => {
        "product_id": productId,
        "product_name": productName,
    };
}
