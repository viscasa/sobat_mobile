import 'package:flutter/material.dart';

class tagline extends StatelessWidget {
  const tagline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 70, 142, 72),
        border:
            Border.all(color: const Color.fromARGB(255, 51, 45, 45), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  "Pilih Obatmu,\nSehat UntukMu!",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                )
              ],
            ),
            SizedBox(
              width: 30,
            ),
            Expanded(
                child: Image.asset(
              'assets/tagline.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: 150,
            ))
          ],
        ),
      ),
    );
  }
}
