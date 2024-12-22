import 'package:flutter/material.dart';

class cart extends StatelessWidget {
  const cart({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 177, 57, 57),

              // borderRadius: BorderRadius.circular(180),
            ),
            height: 5,
            width: screenWidth * 0.2,
            child: Center(
              child: Icon(Icons.home),
            ),
          ),
        ),
        Text("TEST")
      ],
    );
  }
}
