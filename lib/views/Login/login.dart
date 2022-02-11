import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/views/Goals/goals_page.dart';
import '/views/navigation_wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _LoginPageState extends State<LoginPage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var questionIndex = 0;
  void login() {
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => NavigationWrapper()));
  }

  @override
  Widget build(BuildContext context) {
    //MaterialApp is a flutter class which has a constructor

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      //body: Text('This is my default text'),
      body: Column(
        children: [
          ElevatedButton(child: Text("Login"), onPressed: login),
        ],
      ),
      //home: Text('hello world'),
    );
  }
}
