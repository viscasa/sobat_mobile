// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';
import 'package:sobat_mobile/drug/screens/list_drugentry.dart';

List<DrugModel> welcomeFromJson(String str) =>
    List<DrugModel>.from(json.decode(str).map((x) => DrugModel.fromJson(x)));

String welcomeToJson(List<DrugModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DrugModel {
  Model model;
  String pk;
  DrugEntry fields;

  DrugModel({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory DrugModel.fromJson(Map<String, dynamic> json) => DrugModel(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: DrugEntry.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class DrugEntry {
  String name;
  String desc;
  String category;
  String drugType;
  String drugForm;
  int price;
  String image;
  List<String> shops;

  DrugEntry({
    required this.name,
    required this.desc,
    required this.category,
    required this.drugType,
    required this.drugForm,
    required this.price,
    required this.image,
    required this.shops,
  });

  factory DrugEntry.fromJson(Map<String, dynamic> json) => DrugEntry(
        name: json["name"] ?? "Unknown",
        desc: json["desc"] ?? "No description available",
        category: json["category"] ?? "Unknown",
        drugType: json["drug_type"] ?? "Unknown",
        drugForm: json["drug_form"] ?? "Unknown",
        price: json["price"] ?? 0,
        image: json["image"] ?? "",
        shops: json["shops"] != null
            ? List<String>.from(json["shops"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "desc": desc,
        "category": category,
        "drug_type": drugType,
        "drug_form": drugForm,
        "price": price,
        "image": image,
        "shops": List<dynamic>.from(shops.map((x) => x)),
      };
}

// enum DrugType {
//     MODERN,
//     TRADISIONAL
// }

// final drugTypeValues = EnumValues({
//     "Modern": DrugType.MODERN,
//     "Tradisional": DrugType.TRADISIONAL
// });

enum Model { PRODUCT_DRUGENTRY }

final modelValues = EnumValues({"product.drugentry": Model.PRODUCT_DRUGENTRY});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
