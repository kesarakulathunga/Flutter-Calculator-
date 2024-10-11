//IM 2021 090 Kezara Kulathunga

import 'package:flutter/material.dart';
import 'ui.dart';

// above Importing the CalculatorUI widget

void main() {
  runApp(const SimpleCalculatorApp());
}

class SimpleCalculatorApp extends StatelessWidget {
  const SimpleCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CalculatorUI(),
      debugShowCheckedModeBanner: false,
    );
  }
}
