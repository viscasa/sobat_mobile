import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResepTile extends StatefulWidget {
  final String name;
  final int price;
  final String imageUrl;
  final String drugForm;
  final String category;
  int quantity; // Jumlah produk
  final Function(int, String)
      onQuantityChanged; // Callback untuk perubahan jumlah

  ResepTile({
    Key? key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.drugForm,
    required this.category,
    this.quantity = 1,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  _ResepTileState createState() => _ResepTileState();
}

class _ResepTileState extends State<ResepTile> {
  void _incrementQuantity() {
    setState(() {
      if (widget.quantity < 99) {
        widget.quantity++;
        widget.onQuantityChanged(widget.quantity, 'increase');
      }
    });
  }

  void _decrementQuantity() {
    if (widget.quantity > 0) {
      setState(() {
        widget.quantity--;
        widget.onQuantityChanged(widget.quantity, 'decrease');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(widget.price);

    final subtotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(widget.price * widget.quantity);

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 100);
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(formattedPrice,
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    Text("Form: ${widget.drugForm}",
                        style: TextStyle(fontSize: 14)),
                    Text("Category: ${widget.category}",
                        style: TextStyle(fontSize: 14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: _decrementQuantity,
                            ),
                            Text(widget.quantity.toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: _incrementQuantity,
                            ),
                          ],
                        ),
                        Text(subtotal,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
