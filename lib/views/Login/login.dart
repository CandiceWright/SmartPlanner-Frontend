import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/main.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/Login/signup.dart';
import '/views/Goals/goals_page.dart';
import '/views/navigation_wrapper.dart';

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
  var questionIndex = 0;
  void login() {
    //validate login and if successful, go to home of app
    PlannerService.sharedInstance.user.LifeCategoriesColorMap["Other"] =
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
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: emailTextController,
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
