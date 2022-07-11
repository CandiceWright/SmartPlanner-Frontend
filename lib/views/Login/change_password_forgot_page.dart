import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/main.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/Login/choose_theme_page.dart';
import 'package:practice_planner/views/Login/login.dart';
import 'package:practice_planner/views/Login/password_resetpin_page.dart';
import '/views/Goals/goals_page.dart';
import '/views/navigation_wrapper.dart';
import 'package:http/http.dart' as http;

class ChangePasswordForgotPage extends StatefulWidget {
  const ChangePasswordForgotPage({Key? key, required this.email})
      : super(key: key);
  final String email;

  @override
  State<ChangePasswordForgotPage> createState() =>
      _ChangePasswordForgotPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _ChangePasswordForgotPageState extends State<ChangePasswordForgotPage> {
  var passwordTxtController = TextEditingController();
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var questionIndex = 0;

  void changePassword() async {
    String password = passwordTxtController.text;

    var body = {'email': widget.email, 'newPass': password};
    String bodyF = jsonEncode(body);
    print(bodyF);

    var url = Uri.parse('http://192.168.1.4:7343/user/password');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body == "password updated successfully") {
        //show alert that password updated successful
        print("password updated successfully");
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return const LoginPage();
          },
          // settings: const RouteSettings(
          //   name: 'navigaionPage',
          // ),
        ));
      }
    } else {
      //404 error, show an alert

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
                        controller: passwordTxtController,
                        enableSuggestions: false,
                        autocorrect: false,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "New Password",
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
                            return 'Please enter new password';
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
                  onPressed: changePassword,
                  child: Text(
                    "OK",
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
