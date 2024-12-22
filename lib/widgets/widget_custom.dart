import 'package:flutter/material.dart';

class WidgetCustom extends StatelessWidget {
  const WidgetCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(child: Text("Custom aja \n         ini \ncontainernya")),
    );
  }
}
