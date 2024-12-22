// To parse this JSON data, do
//
//     final answer = answerFromJson(jsonString);

import 'dart:convert';

List<Answer> answerFromJson(String str) => List<Answer>.from(json.decode(str).map((x) => Answer.fromJson(x)));

String answerToJson(List<Answer> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Answer {
    String pk;
    Fields fields;

    Answer({
        required this.pk,
        required this.fields,
    });

    factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int user;
    String username;
    String role;
    dynamic drugAns;
    String question;
    String answer;
    List<dynamic> likes;
    int numLikes;

    Fields({
        required this.user,
        required this.username,
        required this.role,
        required this.drugAns,
        required this.question,
        required this.answer,
        required this.likes,
        required this.numLikes,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        username: json["username"],
        role: json["role"],
        drugAns: json["drug_ans"],
        question: json["question"],
        answer: json["answer"],
        likes: List<dynamic>.from(json["likes"].map((x) => x)),
        numLikes: json["num_likes"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "username": username,
        "role": role,
        "drug_ans": drugAns,
        "question": question,
        "answer": answer,
        "likes": List<dynamic>.from(likes.map((x) => x)),
        "num_likes": numLikes,
    };
}
