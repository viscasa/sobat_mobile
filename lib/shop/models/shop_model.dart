// lib/shop/models/shop_model.dart

class ShopEntry {
  String model;
  String pk;
  Fields fields;

  ShopEntry({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory ShopEntry.fromJson(Map<String, dynamic> json) => ShopEntry(
        model: json["model"],
        pk: json["pk"].toString(),
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  int owner;
  String name;
  String profileImage;
  String address;
  String openingTime;
  String closingTime;
  DateTime createdAt;
  DateTime updatedAt;

  Fields({
    required this.owner,
    required this.name,
    required this.profileImage,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        owner: json["owner"],
        name: json["name"],
        profileImage: json["profile_image"],
        address: json["address"],
        openingTime: json["opening_time"],
        closingTime: json["closing_time"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "owner": owner,
        "name": name,
        "profile_image": profileImage,
        "address": address,
        "opening_time": openingTime,
        "closing_time": closingTime,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}