import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sobat_mobile/colors.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';
import 'package:sobat_mobile/forum/models/answer_entry.dart';
import 'package:sobat_mobile/forum/models/question_entry.dart';
import 'package:sobat_mobile/forum/screens/answer_form.dart';
import 'package:sobat_mobile/forum/screens/answers.dart';
import 'package:sobat_mobile/forum/screens/forum.dart';
import 'package:sobat_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class AnswersPage extends StatefulWidget {
  final Question question;

  const AnswersPage({super.key, required this.question});

  @override
  State<AnswersPage> createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  List<Answer> answers = [];
  String _drugAns = "-1";
  DrugModel? _selectedDrug;
  final TextEditingController _answer = TextEditingController();
  final String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/media/';

  final Color primaryGreen = AppColors.primary;
  final Color secondaryGreen = AppColors.secondary;
  final Color backgroundGreen = AppColors.background;

  Future<List<Answer>> fetchAnswers(CookieRequest request) async {
    String questionId = widget.question.pk;

    final response = await request.get(
        'https://m-arvin-sobat.pbp.cs.ui.ac.id/forum/show_json_answer/$questionId/');

    List<Answer> listAnswer = [];
    for (var d in response) {
      if (d != null) {
        Answer answer = Answer.fromJson(d);

        if (answer.fields.drugAns != "") {
          String productId = answer.fields.drugAns;
          DrugModel product = await fetchProductbyId(request, productId);
          answer.fields.drugAns = json.encode({
            "image": product.fields.image,
            "name": product.fields.name,
          });
        }

        listAnswer.add(answer);
      }
    }
    return listAnswer;
  }

  Future<DrugModel> fetchProductbyId(
      CookieRequest request, String productId) async {
    final response = await request
        .get('https://m-arvin-sobat.pbp.cs.ui.ac.id/product/json/$productId/');
    return DrugModel.fromJson(response[0]);
  }

  Future<List<DrugModel>> fetchProductEntries(CookieRequest request) async {
    final response = await request
        .get('https://m-arvin-sobat.pbp.cs.ui.ac.id/product/json/');
    List<DrugModel> listProduct = [];
    for (var d in response) {
      if (d != null) {
        listProduct.add(DrugModel.fromJson(d));
      }
    }
    return listProduct;
  }

  Future<void> handleLike(
      CookieRequest request, Answer answer, int userId) async {
    final response = await request.post(
        'https://m-arvin-sobat.pbp.cs.ui.ac.id/like_answer/${answer.pk}/', {});

    if (response['status'] == 'success') {
      setState(() {
        int index = answers.indexWhere((q) => q.pk == answer.pk);
        if (index != -1) {
          if (answers[index].fields.likes.contains(userId)) {
            answers[index].fields.likes.remove(userId);
            answers[index].fields.numLikes--;
          } else {
            answers[index].fields.likes.add(userId);
            answers[index].fields.numLikes++;
          }
        }
      });
    }
  }

  Future<void> handleDelete(CookieRequest request, Answer answer) async {
    try {
      final response = await request.post(
          'https://m-arvin-sobat.pbp.cs.ui.ac.id/forum/delete_answer_flutter/${answer.pk}/',
          {});

      if (response['status'] == 'success') {
        setState(() {
          answers.removeWhere((q) => q.pk == answer.pk);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete answer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    int userId = request.jsonData['id'];

    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: AppBar(
        title: const Text(
          'Answers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ForumPage(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Display the question text
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Provide helpful answers and share your expertise to guide others in the community!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question content
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.question.fields.drugAsked != "") ...[
                              SizedBox(
                                width: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDrugImage(
                                        widget.question.fields.drugAsked),
                                    const SizedBox(height: 8),
                                    _buildDrugName(
                                        widget.question.fields.drugAsked),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "by ${widget.question.fields.username}",
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 47, 47, 47),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      if (widget.question.fields.role ==
                                          "apoteker")
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: primaryGreen,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: const Text(
                                            "Apoteker",
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(
                                                  255, 47, 47, 47),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.question.fields.questionTitle,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.question.fields.question,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // FutureBuilder for answers
            FutureBuilder(
              future: fetchAnswers(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 64,
                          color: primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'There are no answers yet...',
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  answers = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: answers.length,
                    itemBuilder: (_, index) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: answers[index].fields.role == "apoteker"
                            ? const Color.fromARGB(255, 220, 252, 231)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: primaryGreen,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (answers[index].fields.drugAns != "") ...[
                                    SizedBox(
                                      width: 80,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDrugImage(
                                              answers[index].fields.drugAns),
                                          const SizedBox(height: 8),
                                          _buildDrugName(
                                              answers[index].fields.drugAns),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "by ${answers[index].fields.username}",
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 47, 47, 47),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            if (answers[index].fields.role ==
                                                "apoteker")
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: primaryGreen,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Apoteker",
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color.fromARGB(
                                                        255, 47, 47, 47),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          answers[index].fields.answer,
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Actions row
                            _buildActionButtons(
                                context, answers[index], request, userId),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnswerFormPage(question: widget.question),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Answer The Question',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDrugImage(String drugAnsJson) {
    Map<String, dynamic> drugInfo = json.decode(drugAnsJson);
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryGreen,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          baseUrl + drugInfo["image"],
          height: 80,
          width: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: secondaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: primaryGreen,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrugName(String drugAnsJson) {
    Map<String, dynamic> drugInfo = json.decode(drugAnsJson);
    return Center(
      child: Text(
        drugInfo["name"],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: primaryGreen,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, Answer answer, CookieRequest request, int userId) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => handleLike(request, answer, userId),
                icon: Icon(
                  answer.fields.likes.contains(userId)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                iconSize: 22,
              ),
              Text(
                "${answer.fields.numLikes}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (answer.fields.user == userId) ...[
            IconButton(
              onPressed: () => _showDeleteDialog(context, answer, request),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              iconSize: 22,
            ),
          ]
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Answer answer, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Answer'),
          content: const Text('Are you sure you want to delete this answer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: primaryGreen),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                handleDelete(request, answer);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
