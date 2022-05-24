import 'package:flutter/material.dart';
import '/views/Login/login.dart';
import '/views/Login/signup.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _WelcomePageState extends State<WelcomePage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var questionIndex = 0;
  void login() {
    print("I am in login function");
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
              // FractionallySizedBox(
              //   widthFactor: 0.5,
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     child: Text(
              //       "Login",
              //       style: TextStyle(fontSize: 18),
              //     ),
              //     style: ButtonStyle(
              //       backgroundColor: MaterialStateProperty.all<Color>(
              //           const Color(0xffef41a8)),
              //     ),
              //   ),
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Don't have an account yet?",
              //       style: TextStyle(color: Colors.white),
              //     ),
              //     TextButton(
              //         onPressed: () {},
              //         child: Text(
              //           "Sign Up",
              //           style: TextStyle(
              //             color: Color(0xff7ddcfa),
              //           ),
              //         ))
              //   ],
              // )
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
