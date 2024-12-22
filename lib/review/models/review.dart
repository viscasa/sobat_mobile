// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

List<Review> reviewFromJson(String str) =>
    List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
  String id;
  int user;
  String username;
  String product;
  int rating;
  String comment;
  DateTime dateCreated;

  Review({
    required this.id,
    required this.user,
    required this.username,
    required this.product,
    required this.rating,
    required this.comment,
    required this.dateCreated,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        user: json["user"],
        username: json["username"],
        product: json["product"],
        rating: json["rating"],
        comment: json["comment"],
        dateCreated: DateTime.parse(json["date_created"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "username": username,
        "product": product,
        "rating": rating,
        "comment": comment,
        "date_created":
            "${dateCreated.year.toString().padLeft(4, '0')}-${dateCreated.month.toString().padLeft(2, '0')}-${dateCreated.day.toString().padLeft(2, '0')}",
      };
}
