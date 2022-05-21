import 'dart:convert';

import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/Login/signup.dart';
import '../../models/life_category.dart';
import '../../models/user.dart';
import '/views/navigation_wrapper.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _LoginPageState extends State<LoginPage> {
  var emailTextController = TextEditingController();
  var passwordTextController = TextEditingController();
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  //var questionIndex = 0;
  void login() async {
    //validate login and if successful, go to home of app
    var email = emailTextController.text;
    var password = passwordTextController.text;
    var body = {'email': email, 'password': password};
    String bodyF = jsonEncode(body);
    print(bodyF);

    var url = Uri.parse('http://localhost:7343/login');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body == "no user exists") {
        //show an error alert for no account
      } else if (response.body == "wrong password") {
        //show alert for wrong password
      } else {
        var decodedBody = json.decode(response.body);
        print(decodedBody);
        var userId = decodedBody[0]["userId"];
        var planitName = decodedBody[0]["planitName"];
        var themeId = decodedBody[0]["theme"];
        var didStartPlanningTomorrow =
            decodedBody[0]["didStartPlanningTomorrow"];

        //get all life categories
        var url = Uri.parse('http://localhost:7343/categories');
        var response2 = await http.get(url);
        print('Response status: ${response2.statusCode}');
        print('Response body: ${response2.body}');
        var lifeCategories;

        if (response2.statusCode == 200) {
          var decodedBody = json.decode(response2.body);
          print(decodedBody);
          lifeCategories = decodedBody;
        } else {
          //show alert that user already exists with that email
        }

        //get all goals

        //get all calendar events

        //get all habits

        //get all backlog items

        //get all dictionary items
        DynamicTheme.of(context)!.setTheme(themeId);
        var user = User(
            id: userId,
            planitName: planitName,
            email: email,
            profileImage: "assets/images/profile_pic_icon.png",
            themeId: themeId,
            //theme: PinkTheme(),
            didStartTomorrowPlanning: didStartPlanningTomorrow,
            lifeCategories: lifeCategories);
        PlannerService.sharedInstance.user = user;
        PlannerService.sharedInstance.user!.LifeCategoriesColorMap["Other"] =
            Colors.grey;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return const NavigationWrapper();
          },
          settings: const RouteSettings(
            name: 'navigaionPage',
          ),
        ));
      }
    } else {
      //404 error, show an alert

    }

    PlannerService.sharedInstance.user!.LifeCategoriesColorMap["Other"] =
        Theme.of(context).colorScheme.primary;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const NavigationWrapper();
      },
      settings: const RouteSettings(
        name: 'navigaionPage',
      ),
    ));
    // Navigator.push(
    //     context, CupertinoPageRoute(builder: (context) => NavigationWrapper()));
  }

  void signup() {
    print("I am in signup function");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SignupPage();
      },
      // settings: const RouteSettings(
      //   name: 'navigaionPage',
      // ),
    ));
    // Navigator.push(
    //     context, CupertinoPageRoute(builder: (context) => NavigationWrapper()));
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
          body: Column(
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
                        controller: emailTextController,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Email",
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
                            return 'Please enter email';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: passwordTextController,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                            hintText: "Password",
                            icon: Icon(
                              Icons.password,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
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
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      onPressed: login,
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xffef41a8)),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account yet?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                          onPressed: signup,
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Color(0xff7ddcfa),
                            ),
                          ))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
