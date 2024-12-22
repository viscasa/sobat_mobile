import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';

class detailPage extends StatefulWidget {
  final DrugEntry product;
  final void Function()? detailRoute;
  final void Function()? addCart;
  final String pk;
  final CookieRequest request;

  const detailPage(
      {super.key,
      required this.product,
      required this.detailRoute,
      required this.pk,
      required this.request,
      required this.addCart});

  @override
  State<detailPage> createState() => _detailPageState();
}

Future<void> editFavorite(
    String favoriteId, String newNote, CookieRequest request) async {
  final url =
      'https://m-arvin-sobat.pbp.cs.ui.ac.id/favorite/api/edit/$favoriteId/';
  if (newNote.isNotEmpty) {
    try {
      final response = await request.post(
          'https://m-arvin-sobat.pbp.cs.ui.ac.id/favorite/api/edit/$favoriteId/',
          {"catatan": newNote});
    } catch (e) {
      print("Request failed: $e");
    }
  }
}

TextEditingController test = TextEditingController();

class _detailPageState extends State<detailPage> {
  Future<void> fetchFavoriteNote() async {
    final url =
        'https://m-arvin-sobat.pbp.cs.ui.ac.id/favorite/favorites/json/'; // Adjust the URL if needed
    final response = await widget.request.get(url);
    var data = response;

    for (var w in data) {
      if (w["id"] == widget.pk) {
        test.text = w["catatan"];
      }
    }
  }

  String formatedPrice(int price) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID', // Locale Indonesia
      symbol: 'Rp ', // Simbol mata uang
      decimalDigits: 0, // Tanpa desimal
    ).format(price);
    return formattedPrice;
  }

  @override
  void initState() {
    super.initState();
    // Fetch the note when the page loads
    fetchFavoriteNote();
  }

  // Define the base URL
  final String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/media/';

  @override
  Widget build(BuildContext context) {
    String imageUrl = '$baseUrl${widget.product.image}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => {
            editFavorite(widget.pk, test.text, widget.request),
            Navigator.of(context).pop()
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Favorite Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: widget.detailRoute,
                    icon: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                    ),
                    iconSize: 30,
                  ),
                ],
              ),
              // Image
              Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width - 32,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Unable to load image',
                        textAlign: TextAlign.center);
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Product Details
              Text(
                widget.product.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              Text(
                widget.product.drugForm,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Text(
                "Deskripsi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                widget.product.desc,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Tipe Obat",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                widget.product.drugType,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),

              Text(
                "Kategori",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                widget.product.category,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "Catatan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              TextField(
                controller: test, // Sambungkan controller ke TextField
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                minLines: 3,
              ),
              // ElevatedButton(
              //     onPressed: () =>
              //         editFavorite(widget.pk, test.text, widget.request),
              //     child: Text("Save"))
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(25),
          color: const Color.fromARGB(255, 149, 191, 116),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${formatedPrice(widget.product.price)}",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: widget.addCart,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.cartShopping,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add To Cart',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
