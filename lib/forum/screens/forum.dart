import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sobat_mobile/colors.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';
import 'package:sobat_mobile/forum/models/question_entry.dart';
import 'package:sobat_mobile/forum/screens/answers.dart';
import 'package:sobat_mobile/forum/screens/question_form.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sobat_mobile/widgets/left_drawer.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Question> questions = [];
  List<Question> filteredQuestions = [];
  final TextEditingController _searchController = TextEditingController();
  final String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/media/';

  final Color primaryGreen = AppColors.primary;
  final Color secondaryGreen = AppColors.secondary;
  final Color backgroundGreen = AppColors.background;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterQuestions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredQuestions = List.from(questions);
      } else {
        filteredQuestions = questions.where((question) {
          final titleMatch = question.fields.questionTitle
              .toLowerCase()
              .contains(query.toLowerCase());
          final contentMatch = question.fields.question
              .toLowerCase()
              .contains(query.toLowerCase());

          bool drugMatch = false;
          if (question.fields.drugAsked.isNotEmpty) {
            try {
              final drugInfo = json.decode(question.fields.drugAsked);
              drugMatch = drugInfo["name"]
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            } catch (e) {
              // Handle parsing error
              drugMatch = false;
            }
          }

          return titleMatch || contentMatch || drugMatch;
        }).toList();
      }
    });
  }

  Future<DrugModel> fetchProduct(
      CookieRequest request, String productId) async {
    final response = await request
        .get('https://m-arvin-sobat.pbp.cs.ui.ac.id/product/json/$productId/');
    return DrugModel.fromJson(response[0]);
  }

  Future<List<Question>> fetchQuestions(CookieRequest request) async {
    final response =
        await request.get('https://m-arvin-sobat.pbp.cs.ui.ac.id/forum/json/');
    List<Question> listQuestion = [];

    for (var d in response) {
      if (d != null) {
        Question question = Question.fromJson(d);

        if (question.fields.drugAsked != "") {
          String productId = question.fields.drugAsked;
          DrugModel product = await fetchProduct(request, productId);
          question.fields.drugAsked = json.encode({
            "image": product.fields.image,
            "name": product.fields.name,
          });
        }

        listQuestion.add(question);
      }
    }
    return listQuestion;
  }

  Future<void> handleLike(
      CookieRequest request, Question question, int userId) async {
    final response = await request.post(
        'https://m-arvin-sobat.pbp.cs.ui.ac.id/forum/like_question/${question.pk}/',
        {});

    if (response['status'] == 'success') {
      setState(() {
        int index = questions.indexWhere((q) => q.pk == question.pk);
        if (index != -1) {
          if (questions[index].fields.likes.contains(userId)) {
            questions[index].fields.likes.remove(userId);
            questions[index].fields.numLikes--;
          } else {
            questions[index].fields.likes.add(userId);
            questions[index].fields.numLikes++;
          }
        }
      });
    }
  }

  Future<void> handleDelete(CookieRequest request, Question question) async {
    try {
      final response = await request.post(
          'https://m-arvin-sobat.pbp.cs.ui.ac.id/forum/delete_question_flutter/${question.pk}/',
          {});

      if (response['status'] == 'success') {
        setState(() {
          questions.removeWhere((q) => q.pk == question.pk);
          filteredQuestions.removeWhere((q) => q.pk == question.pk);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete question'),
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
      drawer: const LeftDrawer(),
      appBar: AppBar(
        title: const Text(
          'Forum Q&A',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                "Ask questions, get answers, and share your knowledge with the community!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: filterQuestions,
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  prefixIcon: Icon(Icons.search, color: primaryGreen),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            filterQuestions('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: primaryGreen.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: fetchQuestions(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.question_answer_outlined,
                        size: 64,
                        color: primaryGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'There are no questions yet...',
                        style: TextStyle(
                          fontSize: 20,
                          color: primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                } else {
                  questions = snapshot.data!;
                  if (filteredQuestions.isEmpty &&
                      _searchController.text.isEmpty) {
                    filteredQuestions = List.from(questions);
                  }

                  if (filteredQuestions.isEmpty &&
                      _searchController.text.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: primaryGreen,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No questions found',
                            style: TextStyle(
                              fontSize: 20,
                              color: primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filteredQuestions.length,
                    itemBuilder: (_, index) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            filteredQuestions[index].fields.role == "apoteker"
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
                                  if (filteredQuestions[index]
                                          .fields
                                          .drugAsked !=
                                      "") ...[
                                    SizedBox(
                                      width: 80,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDrugImage(
                                              filteredQuestions[index]
                                                  .fields
                                                  .drugAsked),
                                          const SizedBox(height: 8),
                                          _buildDrugName(
                                              filteredQuestions[index]
                                                  .fields
                                                  .drugAsked),
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
                                              "by ${filteredQuestions[index].fields.username}",
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 47, 47, 47),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            if (filteredQuestions[index]
                                                    .fields
                                                    .role ==
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
                                          filteredQuestions[index]
                                              .fields
                                              .questionTitle,
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          filteredQuestions[index]
                                              .fields
                                              .question,
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
                            _buildActionButtons(context,
                                filteredQuestions[index], request, userId),
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
              builder: (context) => const QuestionFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ask Question',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDrugImage(String drugAskedJson) {
    Map<String, dynamic> drugInfo = json.decode(drugAskedJson);
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

  Widget _buildDrugName(String drugAskedJson) {
    Map<String, dynamic> drugInfo = json.decode(drugAskedJson);
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

  Widget _buildActionButtons(BuildContext context, Question question,
      CookieRequest request, int userId) {
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
                onPressed: () => handleLike(request, question, userId),
                icon: Icon(
                  question.fields.likes.contains(userId)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                iconSize: 22,
              ),
              Text(
                "${question.fields.numLikes}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnswersPage(question: question),
                    ),
                  );
                },
                icon: Icon(
                  Icons.comment_outlined,
                  color: primaryGreen,
                ),
                iconSize: 22,
              ),
              Text(
                "${question.fields.numAnswer}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (question.fields.user == userId) ...[
            IconButton(
              onPressed: () => _showDeleteDialog(context, question, request),
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
      BuildContext context, Question question, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question?'),
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
                handleDelete(request, question);
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
