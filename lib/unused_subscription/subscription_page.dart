import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '/views/Login/login.dart';
import '/views/Login/signup.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _SubscriptionPageState extends State<SubscriptionPage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget

  @override
  void dispose() {}

  @override
  initState() {
    super.initState();
  }

  void login() {
    //print("I am in login function");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const LoginPage();
      },
      // settings: const RouteSettings(
      //   name: 'navigaionPage',
      // ),
    ));
    // Navigator.push(
    //     context, CupertinoPageRoute(builder: (context) => NavigationWrapper()));
  }

  void signup() {
    //print("I am in signup function");
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
          "assets/images/black_stars_background.jpeg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.

            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: Column(
            children: [
              Padding(
                child: Image.asset(
                  "assets/images/welcome_graphic_brownpink.png",
                ),
                padding: EdgeInsets.all(10),
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
                      // style: ButtonStyle(
                      //   backgroundColor: MaterialStateProperty.all<Color>(
                      //       const Color(0xffd4ac62)),
                      // ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xffef41a8)),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account yet?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                          onPressed: signup,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Color(0xff7ddcfa),
                              //color: Color(0xffef41a8)
                              //color: Color(0xffd4ac62),
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
