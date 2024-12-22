// To parse this JSON data, do
//
//     final question = questionFromJson(jsonString);

import 'dart:convert';

List<Question> questionFromJson(String str) => List<Question>.from(json.decode(str).map((x) => Question.fromJson(x)));

String questionToJson(List<Question> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Question {
    String pk;
    Fields fields;

    Question({
        required this.pk,
        required this.fields,
    });

    factory Question.fromJson(Map<String, dynamic> json) => Question(
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
    String drugAsked;
    String questionTitle;
    String question;
    List<dynamic> likes;
    int numLikes;
    int numAnswer;

    Fields({
        required this.user,
        required this.username,
        required this.role,
        required this.drugAsked,
        required this.questionTitle,
        required this.question,
        required this.likes,
        required this.numLikes,
        required this.numAnswer,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        username: json["username"],
        role: json["role"],
        drugAsked: json["drug_asked"],
        questionTitle: json["question_title"],
        question: json["question"],
        likes: List<dynamic>.from(json["likes"].map((x) => x)),
        numLikes: json["num_likes"],
        numAnswer: json["num_answer"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "username": username,
        "role": role,
        "drug_asked": drugAsked,
        "question_title": questionTitle,
        "question": question,
        "likes": List<dynamic>.from(likes.map((x) => x)),
        "num_likes": numLikes,
        "num_answer": numAnswer,
    };
}
