import 'package:flutter/material.dart';

class AppThemes {
  static const int pink = 0;
  static const int blue = 1;
  static const int neutral = 2;

  final Map<int, Color> _pinkMap = {
    50: Colors.pink.shade50,
    100: Colors.pink.shade100,
    200: Colors.pink.shade200,
    300: Colors.pink.shade300,
    400: Colors.pink.shade400,
    500: Colors.pink.shade500,
    600: Colors.pink.shade600,
    700: Colors.pink.shade700,
    800: Colors.pink.shade800,
    900: Colors.pink.shade900,
  };

  late MaterialColor pinkPrimarySwatch =
      MaterialColor(Colors.pink[400]!.value, _pinkMap);

  late MaterialColor pinkAccentSwatch =
      MaterialColor(Colors.pink[50]!.value, _pinkMap);

  final Map<int, Color> _blueMap = {
    50: Colors.blue.shade50,
    100: Colors.blue.shade100,
    200: Colors.blue.shade200,
    300: Colors.blue.shade300,
    400: Colors.blue.shade400,
    500: Colors.blue.shade500,
    600: Colors.blue.shade600,
    700: Colors.blue.shade700,
    800: Colors.blue.shade800,
    900: Colors.blue.shade900,
  };
  late MaterialColor bluePrimarySwatch = Colors.blue;
  // late MaterialColor bluePrimarySwatch =
  //     MaterialColor(Colors.blue[700]!.value, _blueMap);

  late MaterialColor blueAccentSwatch =
      MaterialColor(Colors.blue[50]!.value, _blueMap);

  final Map<int, Color> _neutralMap = {
    50: Colors.brown.shade50,
    100: Colors.brown.shade100,
    200: Colors.brown.shade200,
    300: Colors.brown.shade300,
    400: Colors.brown.shade400,
    500: Colors.brown.shade500,
    600: Colors.brown.shade600,
    700: Colors.brown.shade700,
    800: Colors.brown.shade800,
    900: Colors.brown.shade900,
  };

  late MaterialColor neutralPrimarySwatch =
      MaterialColor(Colors.brown[700]!.value, _neutralMap);

  late MaterialColor neutralAccentSwatch =
      MaterialColor(Colors.brown[100]!.value, _neutralMap);
}
