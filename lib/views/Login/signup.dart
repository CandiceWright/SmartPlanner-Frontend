import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/main.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Legal/privacy_policy_page.dart';
import 'package:practice_planner/views/Legal/terms_of_use.dart';
import 'package:practice_planner/views/Login/login.dart';
import 'package:practice_planner/views/Login/planit_name_page.dart';
import '/views/Goals/goals_page.dart';
import '/views/navigation_wrapper.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _SignupPageState extends State<SignupPage> {
  //var subscriptionProvider = SubscriptionsProvider();

  var emailTextController = TextEditingController();
  var passwordTextController = TextEditingController();
  var usernameTextController = TextEditingController();
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var questionIndex = 0;
  void login() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const LoginPage();
      },
    ));
    // Navigator.push(
    //     context, CupertinoPageRoute(builder: (context) => NavigationWrapper()));
  }

  @override
  initState() {
    //PlannerService.subscriptionProvider.purchaseInProgress = false;
    super.initState();
  }

  void signup() async {
    //first check that this icloud accountt doesn't already have a subscription
    //await PlannerService.subscriptionProvider.restorePurchases();
    if (PlannerService.subscriptionProvider.purchases.isNotEmpty) {
      //user has already subscribed
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                  'You have already subscribed and created an account. Only one Planit is allowed per subscription. Please login to your original account.'),
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
    } else {
      var email = emailTextController.text;
      var password = passwordTextController.text;
      //call sign up server route and then go to home of app
      var url = Uri.parse(
          PlannerService.sharedInstance.serverUrl + '/email/' + email);
      var response = await http.get(url);
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.body == "no user exists") {
        //can go to the next page to get planit name
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => PlanitNamePage(
                      email: email,
                      password: password,
                    )));
      } else {
        //show alert that user already exists with that email
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    'Oops! Looks like there is already an account with this email. Please sign in.'),
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
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  child: Image.asset(
                    "assets/images/text_logo.png",
                  ),
                  padding: EdgeInsets.all(10),
                ),
              ),
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
                  //style: TextStyle(color: Colors.white),
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
          persistentFooterButtons: [
            Container(
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      onPressed: signup,
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              //const Color(0xffd1849e),
                              Colors.transparent),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: const BorderSide(
                                          //color: Color(0xffd1849e),
                                          color: Colors.white)))),

                      // style: ButtonStyle(
                      //   backgroundColor: MaterialStateProperty.all<Color>(
                      //       const Color(0xffef41a8)),
                      // ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return const PrivacyPolicyPage();
                            },
                          ));
                        },
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Text(
                        "and",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return const TermsPage();
                            },
                          ));
                        },
                        child: Text(
                          "Terms of Use.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Have an account already?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                          onPressed: login,
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Color(0xffd1849e),
                              //color: Colors.grey
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
