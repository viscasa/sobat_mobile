import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';
import 'package:sobat_mobile/drug/widgets/button_review.dart';
import 'package:sobat_mobile/forum/screens/forum.dart';
import 'package:sobat_mobile/review/screens/review_page.dart';

class ProductDetailPage extends StatelessWidget {
  final DrugModel product;
  //  final DrugEntry product;
  final void Function()? detailRoute;
  final void Function()? onPressed;

  String formatedPrice(int price) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID', // Locale Indonesia
      symbol: 'Rp ', // Simbol mata uang
      decimalDigits: 0, // Tanpa desimal
    ).format(price);
    return formattedPrice;
  }

  const ProductDetailPage(
      {super.key,
      required this.product,
      required this.detailRoute,
      required this.onPressed});

  // Define the base URL
  final String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/media/';

  @override
  Widget build(BuildContext context) {
    void showReview() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPage(
              productID: product.pk,
              productName: product.fields.name,
              productPrice: product.fields.price.toString(),
              image: product.fields.image),
        ),
      );
    }

    void showForum() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForumPage(),
        ),
      );
    }

    String imageUrl = '$baseUrl${product.fields.image}';

    return Scaffold(
      appBar: AppBar(
        title: Text(product.fields.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: detailRoute,
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
                product.fields.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              Text(
                product.fields.drugForm,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customButton(
                        onPressed: () => showReview(),
                        icon: FontAwesomeIcons.commentDots,
                        text: "Review"),
                  ),
                  customButton(
                      onPressed: () => showForum(),
                      icon: FontAwesomeIcons.solidComments,
                      text: "Forum"),
                ],
              ),
              Text(
                "Deskripsi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                product.fields.desc,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Tipe Obat:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                product.fields.drugType,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
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
                "${formatedPrice(product.fields.price)}",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: onPressed,
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
