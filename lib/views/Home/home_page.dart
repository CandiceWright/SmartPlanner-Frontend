import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/views/Goals/goals_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _HomePageState extends State<HomePage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget

  @override
  Widget build(BuildContext context) {
    //MaterialApp is a flutter class which has a constructor

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      //body: Text('This is my default text'),
      body: Column(
        children: const [
          Text("This is home."),
        ],
      ),
    );
  }
}
