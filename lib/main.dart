import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'views/Login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final Map<int, Color> themeColorMap = {
    //   100: Color(0xFFF8BBD0),
    // };
    // final MaterialColor _pink100Swatch =
    //     MaterialColor(Colors.pink[100]!.value, themeColorMap);
    return MaterialApp(
      title: 'Planner App',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.pink,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              centerTitle: false,
              titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: kToolbarHeight / 2,
                  fontWeight: FontWeight.bold),
              elevation: 0)),
      home: const LoginPage(),
    );
  }
}
