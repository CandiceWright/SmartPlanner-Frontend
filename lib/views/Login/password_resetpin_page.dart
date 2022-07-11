import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/main.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/Login/change_password_forgot_page.dart';
import 'package:practice_planner/views/Login/choose_theme_page.dart';
import 'package:practice_planner/views/Login/login.dart';
import '/views/Goals/goals_page.dart';
import '/views/navigation_wrapper.dart';
import 'package:http/http.dart' as http;

class PasswordResetPinPage extends StatefulWidget {
  const PasswordResetPinPage({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  State<PasswordResetPinPage> createState() => _PasswordResetPinPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _PasswordResetPinPageState extends State<PasswordResetPinPage> {
  var pinTxtController = TextEditingController();
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var questionIndex = 0;

  void validatePin() async {
    String pin = pinTxtController.text;

    var body = {
      'email': widget.email,
      'pin': pin,
    };
    String bodyF = jsonEncode(body);
    print(bodyF);

    var url = Uri.parse('http://192.168.1.4:7343/user/pin/validate');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body == "pin expired") {
        //show alert that pin expired
        print("pin expired");
      } else if (response.body == "incorrect pin") {
        //show alert that the pin is incorrect
        print("incorrect pin");
      } else {
        //pin is correct, go to page to change password
        print("pin is correct");
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) =>
                    ChangePasswordForgotPage(email: widget.email)));
      }
    } else {
      //404 error, show an alert
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                  'Oops! Looks like something went wrong. Please try again.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    //MaterialApp is a flutter class which has a constructor

    return Stack(
      children: [
        Image.asset(
          "assets/images/login_screens_background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: ListView(
            children: [
              Padding(
                child: Image.asset(
                  "assets/images/planit_logo.png",
                ),
                padding: EdgeInsets.all(10),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: pinTxtController,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Pin",
                          icon: Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pin';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          persistentFooterButtons: [
            Container(
              alignment: Alignment.center,
              child:
                  //Column(
                  //children: [
                  FractionallySizedBox(
                widthFactor: 0.5,
                child: ElevatedButton(
                  onPressed: validatePin,
                  child: Text(
                    "Ok",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xffef41a8)),
                  ),
                ),
              ),
              //],
              //),
            )
          ],
        ),
      ],
    );
  }
}
