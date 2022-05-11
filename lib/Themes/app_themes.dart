import 'package:flutter/material.dart';

class AppThemes {
  static const int pink = 0;
  static const int blue = 1;
  static const int green = 2;
  static const int orange = 3;
  static const int grey = 4;

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

  final Map<int, Color> _greenMap = {
    50: Colors.green.shade50,
    100: Colors.green.shade100,
    200: Colors.green.shade200,
    300: Colors.green.shade300,
    400: Colors.green.shade400,
    500: Colors.green.shade500,
    600: Colors.green.shade600,
    700: Colors.green.shade700,
    800: Colors.green.shade800,
    900: Colors.green.shade900,
  };

  late MaterialColor greenPrimarySwatch =
      MaterialColor(Colors.green[700]!.value, _greenMap);

  late MaterialColor greenAccentSwatch =
      MaterialColor(Colors.green[50]!.value, _greenMap);

  final Map<int, Color> _orangeMap = {
    50: Colors.orange.shade50,
    100: Colors.orange.shade100,
    200: Colors.orange.shade200,
    300: Colors.orange.shade300,
    400: Colors.orange.shade400,
    500: Colors.orange.shade500,
    600: Colors.orange.shade600,
    700: Colors.orange.shade700,
    800: Colors.orange.shade800,
    900: Colors.orange.shade900,
  };

  late MaterialColor orangePrimarySwatch =
      MaterialColor(Colors.orange[900]!.value, _orangeMap);

  late MaterialColor orangeAccentSwatch =
      MaterialColor(Colors.orange[50]!.value, _orangeMap);

  final Map<int, Color> _greyMap = {
    50: Colors.grey.shade50,
    100: Colors.grey.shade100,
    200: Colors.grey.shade200,
    300: Colors.grey.shade300,
    400: Colors.grey.shade400,
    500: Colors.grey.shade500,
    600: Colors.grey.shade600,
    700: Colors.grey.shade700,
    800: Colors.grey.shade800,
    900: Colors.grey.shade900,
  };

  late MaterialColor greyPrimarySwatch =
      MaterialColor(Colors.grey[800]!.value, _greyMap);

  late MaterialColor greyAccentSwatch =
      MaterialColor(Colors.grey[100]!.value, _greyMap);
}
