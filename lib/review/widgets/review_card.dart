import 'package:flutter/material.dart';
import 'package:sobat_mobile/review/models/review.dart';
import 'package:sobat_mobile/review/screens/review_edit_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ReviewTile extends StatelessWidget {
  final Review item;
  final Function onChanged;

  const ReviewTile(this.item, {super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    int userID = request.jsonData['id'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "By: ${item.username}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rating: ${item.rating}/5",
                  style: TextStyle(color: Colors.yellow[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.comment,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Date Published: ${item.dateCreated.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(color: Color.fromARGB(255, 127, 127, 127)),
            ),
            const SizedBox(height: 16),
            if (userID == item.user)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReviewPage(
                            reviewID: item.id,
                            productID: item.product,
                            initialRating: item.rating,
                            initialComment: item.comment,
                          ),
                        ),
                      ).then((value) {
                        if (context.mounted) {
                          if (value == true) {
                            onChanged();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Review successfully updated!"),
                              ),
                            );
                          }
                        }
                      });
                    },
                    child: const Text("Edit"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      // Show confirmation dialog
                      bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: const Text(
                              "Are you sure you want to delete this review?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                      if (confirmDelete == true) {
                        final response = await request.post(
                          "http://m-arvin-sobat.pbp.cs.ui.ac.id/review/${item.product}/${item.id}/delete-flutter/",
                          {},
                        );
                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Review successfully deleted!"),
                              ),
                            );
                            onChanged();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Failed to delete review. Please try again."),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text("Delete"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
