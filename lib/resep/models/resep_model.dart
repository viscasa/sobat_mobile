// To parse this JSON data, do
//
//     final resep = resepFromJson(jsonString);

import 'dart:convert';

List<Resep> resepFromJson(String str) =>
    List<Resep>.from(json.decode(str).map((x) => Resep.fromJson(x)));

String resepToJson(List<Resep> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Resep {
  String model;
  String pk;
  Fields fields;

  Resep({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Resep.fromJson(Map<String, dynamic> json) => Resep(
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
  int user;
  String product;
  int amount;

  Fields({
    required this.user,
    required this.product,
    required this.amount,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        product: json["product"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "product": product,
        "amount": amount,
      };
}
