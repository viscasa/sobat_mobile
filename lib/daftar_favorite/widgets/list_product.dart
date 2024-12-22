import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class productTile extends StatefulWidget {
  int price;
  String name;
  String imageUrl;
  String drugForm;
  String category;
  void Function()? onPressed;
  void Function()? detailRoute;
  void Function()? addCart;

  productTile(
      {super.key,
      required this.name,
      required this.price,
      required this.imageUrl,
      required this.onPressed,
      required this.drugForm,
      required this.category,
      required this.detailRoute,
      required this.addCart});

  @override
  State<productTile> createState() => _productTileState();
}

class _productTileState extends State<productTile> {
  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID', // Locale Indonesia
      symbol: 'Rp ', // Simbol mata uang
      decimalDigits: 0, // Tanpa desimal
    ).format(widget.price);
    return GestureDetector(
      onTap: widget.detailRoute,
      child: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            border: Border.all(
                color: const Color.fromARGB(255, 76, 189, 83), width: 2),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.imageUrl, // Use the full URL here
                  height: 120,

                  // Adjusting to the screen width minus paddin

                  errorBuilder: (context, error, stackTrace) {
                    return Text('Unable to load image',
                        textAlign: TextAlign.center);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedPrice,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[400]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Jenis : " + widget.drugForm,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Kategori: " + widget.category,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // TextField(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.cartShopping),
                          onPressed: widget.addCart,
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.trash),
                          onPressed: widget.onPressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
