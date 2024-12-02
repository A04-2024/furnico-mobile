// To parse this JSON data, do
//
//     final productEntry = productEntryFromJson(jsonString);

import 'dart:convert';

List<ProductEntry> productEntryFromJson(String str) => List<ProductEntry>.from(json.decode(str).map((x) => ProductEntry.fromJson(x)));

String productEntryToJson(List<ProductEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductEntry {
  // Model model;
  String pk;
  Fields fields;

  ProductEntry({
    // required this.model,
    required this.pk,
    required this.fields,
  });

  factory ProductEntry.fromJson(Map<String, dynamic> json) => ProductEntry(
    // model: modelValues.map[json["model"]]!,
    pk: json["pk"],
    fields: Fields.fromJson(json["fields"]),
  );

  Map<String, dynamic> toJson() => {
    // "model": modelValues.reverse[model],
    "pk": pk,
    "fields": fields.toJson(),
  };
}

class Fields {
  String productImage;
  String productName;
  String productSubtitle;
  int productPrice;
  int soldThisWeek;
  int peopleBought;
  String productDescription;
  String productAdvantages;
  String productMaterial;
  int productSizeLength;
  int productSizeHeight;
  int productSizeLong;
  String productCategory;
  int productRating;
  String storeName;
  String storeAddress;
  bool inWishlist;

  Fields({
    required this.productImage,
    required this.productName,
    required this.productSubtitle,
    required this.productPrice,
    required this.soldThisWeek,
    required this.peopleBought,
    required this.productDescription,
    required this.productAdvantages,
    required this.productMaterial,
    required this.productSizeLength,
    required this.productSizeHeight,
    required this.productSizeLong,
    required this.productCategory,
    required this.productRating,
    required this.storeName,
    required this.storeAddress,
    required this.inWishlist,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    productImage: json["product_image"],
    productName: json["product_name"],
    productSubtitle: json["product_subtitle"],
    productPrice: json["product_price"],
    soldThisWeek: json["sold_this_week"],
    peopleBought: json["people_bought"],
    productDescription: json["product_description"],
    productAdvantages: json["product_advantages"],
    productMaterial: json["product_material"],
    productSizeLength: json["product_size_length"],
    productSizeHeight: json["product_size_height"],
    productSizeLong: json["product_size_long"],
    productCategory: json["product_category"],
    productRating: json["product_rating"],
    storeName: json["store_name"],
    storeAddress: json["store_address"],
    inWishlist: json["in_wishlist"],
  );

  Map<String, dynamic> toJson() => {
    "product_image": productImage,
    "product_name": productName,
    "product_subtitle": productSubtitle,
    "product_price": productPrice,
    "sold_this_week": soldThisWeek,
    "people_bought": peopleBought,
    "product_description": productDescription,
    "product_advantages": productAdvantages,
    "product_material": productMaterial,
    "product_size_length": productSizeLength,
    "product_size_height": productSizeHeight,
    "product_size_long": productSizeLong,
    "product_category": productCategory,
    "product_rating": productRating,
    "store_name": storeName,
    "store_address": storeAddress,
    "in_wishlist": inWishlist,
  };
}

// enum ProductMaterial {
//   BAHAN_ANTI_JAMUR_UNTUK_MENJAGA_KEBERSIHAN_DAN_KESEHATAN,
//   BAHAN_CAMPURAN_POLIESTER_DAN_KATUN_UNTUK_DAYA_TAHAN_YANG_BAIK,
//   BAHAN_ELASTIS_UNTUK_BANTAL_YANG_NYAMAN_DAN_MENDUKUNG,
//   BAHAN_KATUN_YANG_LEMBUT_DAN_RAMAH_LINGKUNGAN,
//   BAHAN_KOMPOSIT_YANG_MEMBERIKAN_FLEKSIBILITAS_DESAIN,
//   BAHAN_LINEN_YANG_BREATHABLE_DAN_NYAMAN_UNTUK_DIGUNAKAN,
//   BAHAN_MICROFIBER_YANG_LEMBUT_DAN_TIDAK_MUDAH_PUDAR,
//   BAHAN_POLYESTER_YANG_TAHAN_AIR_DAN_TAHAN_NODA,
//   BAHAN_RAJUTAN_YANG_MEMBERIKAN_NUANSA_HANGAT_DAN_COZY,
//   BAHAN_TAHAN_API_UNTUK_MENINGKATKAN_KEAMANAN,
//   BAHAN_VELOUR_YANG_MEMBERIKAN_SENTUHAN_MEWAH_DAN_NYAMAN,
//   BUSA_MEMORI_YANG_MENGIKUTI_BENTUK_TUBUH_UNTUK_KENYAMANAN_EKSTRA,
//   KAIN_BREATHABLE_UNTUK_SIRKULASI_UDARA_YANG_BAIK,
//   KAIN_DENIM_YANG_KUAT_DAN_TAHAN_LAMA,
//   KAIN_SINTETIS_YANG_TAHAN_LAMA_DAN_MUDAH_DIBERSIHKAN,
//   KAIN_TENUN_YANG_MEMBERIKAN_TEKSTUR_MENARIK,
//   KAYU_LAPIS_YANG_RINGAN_NAMUN_TETAP_KUAT,
//   KAYU_SOLID_UNTUK_RANGKA_YANG_KOKOH_DAN_STABIL,
//   KULIT_ASLI_YANG_MEMBERIKAN_KESAN_ELEGAN_DAN_MEWAH,
//   SERAT_BAMBU_YANG_ALAMI_DAN_RAMAH_LINGKUNGAN
// }
//
// final productMaterialValues = EnumValues({
//   "Bahan anti-jamur untuk menjaga kebersihan dan kesehatan": ProductMaterial.BAHAN_ANTI_JAMUR_UNTUK_MENJAGA_KEBERSIHAN_DAN_KESEHATAN,
//   "Bahan campuran poliester dan katun untuk daya tahan yang baik": ProductMaterial.BAHAN_CAMPURAN_POLIESTER_DAN_KATUN_UNTUK_DAYA_TAHAN_YANG_BAIK,
//   "Bahan elastis untuk bantal yang nyaman dan mendukung": ProductMaterial.BAHAN_ELASTIS_UNTUK_BANTAL_YANG_NYAMAN_DAN_MENDUKUNG,
//   "Bahan katun yang lembut dan ramah lingkungan": ProductMaterial.BAHAN_KATUN_YANG_LEMBUT_DAN_RAMAH_LINGKUNGAN,
//   "Bahan komposit yang memberikan fleksibilitas desain": ProductMaterial.BAHAN_KOMPOSIT_YANG_MEMBERIKAN_FLEKSIBILITAS_DESAIN,
//   "Bahan linen yang breathable dan nyaman untuk digunakan": ProductMaterial.BAHAN_LINEN_YANG_BREATHABLE_DAN_NYAMAN_UNTUK_DIGUNAKAN,
//   "Bahan microfiber yang lembut dan tidak mudah pudar": ProductMaterial.BAHAN_MICROFIBER_YANG_LEMBUT_DAN_TIDAK_MUDAH_PUDAR,
//   "Bahan polyester yang tahan air dan tahan noda": ProductMaterial.BAHAN_POLYESTER_YANG_TAHAN_AIR_DAN_TAHAN_NODA,
//   "Bahan rajutan yang memberikan nuansa hangat dan cozy": ProductMaterial.BAHAN_RAJUTAN_YANG_MEMBERIKAN_NUANSA_HANGAT_DAN_COZY,
//   "Bahan tahan api untuk meningkatkan keamanan": ProductMaterial.BAHAN_TAHAN_API_UNTUK_MENINGKATKAN_KEAMANAN,
//   "Bahan velour yang memberikan sentuhan mewah dan nyaman": ProductMaterial.BAHAN_VELOUR_YANG_MEMBERIKAN_SENTUHAN_MEWAH_DAN_NYAMAN,
//   "Busa memori yang mengikuti bentuk tubuh untuk kenyamanan ekstra": ProductMaterial.BUSA_MEMORI_YANG_MENGIKUTI_BENTUK_TUBUH_UNTUK_KENYAMANAN_EKSTRA,
//   "Kain breathable untuk sirkulasi udara yang baik": ProductMaterial.KAIN_BREATHABLE_UNTUK_SIRKULASI_UDARA_YANG_BAIK,
//   "Kain denim yang kuat dan tahan lama": ProductMaterial.KAIN_DENIM_YANG_KUAT_DAN_TAHAN_LAMA,
//   "Kain sintetis yang tahan lama dan mudah dibersihkan": ProductMaterial.KAIN_SINTETIS_YANG_TAHAN_LAMA_DAN_MUDAH_DIBERSIHKAN,
//   "Kain tenun yang memberikan tekstur menarik": ProductMaterial.KAIN_TENUN_YANG_MEMBERIKAN_TEKSTUR_MENARIK,
//   "Kayu lapis yang ringan namun tetap kuat": ProductMaterial.KAYU_LAPIS_YANG_RINGAN_NAMUN_TETAP_KUAT,
//   "Kayu solid untuk rangka yang kokoh dan stabil": ProductMaterial.KAYU_SOLID_UNTUK_RANGKA_YANG_KOKOH_DAN_STABIL,
//   "Kulit asli yang memberikan kesan elegan dan mewah": ProductMaterial.KULIT_ASLI_YANG_MEMBERIKAN_KESAN_ELEGAN_DAN_MEWAH,
//   "Serat bambu yang alami dan ramah lingkungan": ProductMaterial.SERAT_BAMBU_YANG_ALAMI_DAN_RAMAH_LINGKUNGAN
// });
//
// enum Model {
//   SHOW_PRODUCTS_PRODUCT
// }
//
// final modelValues = EnumValues({
//   "show_products.product": Model.SHOW_PRODUCTS_PRODUCT
// });
//
// class EnumValues<T> {
//   Map<String, T> map;
//   late Map<T, String> reverseMap;
//
//   EnumValues(this.map);
//
//   Map<T, String> get reverse {
//     reverseMap = map.map((k, v) => MapEntry(v, k));
//     return reverseMap;
//   }
// }
