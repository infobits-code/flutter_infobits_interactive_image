import 'package:flutter/material.dart';
import 'package:infobits_interactive_image/infobits_interactive_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'infobits_interactive_image example',
      home: Scaffold(
        body: InfobitsInteractiveImage(),
      ),
    );
  }
}
