import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/main.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/Login/choose_theme_page.dart';
import 'package:practice_planner/views/Login/login.dart';
import '/views/Goals/goals_page.dart';
import '/views/navigation_wrapper.dart';
import 'package:http/http.dart' as http;

class PlanitNamePage extends StatefulWidget {
  const PlanitNamePage({Key? key, required this.email, required this.password})
      : super(key: key);

  final String email;
  final String password;
  @override
  State<PlanitNamePage> createState() => _PlanitNamePageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _PlanitNamePageState extends State<PlanitNamePage> {
  var planitNameTextController = TextEditingController();
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var questionIndex = 0;

  void signup() async {
    String planitName = planitNameTextController.text;
    String email = widget.email;
    String password = widget.password;
    //call sign up server route and then go to home of app
//     var client = http.Client();
// //try {
//     var response = await client
//         .post(Uri.https('', 'signup'), body: {
//       'email': widget.email,
//       'password': widget.password,
//       'planitName': planitName
//     });
    var body = {
      'email': email,
      'password': password,
      'planitName': planitName,
      'didStartPlanningTomorrow': false,
      'profileImage': "assets/images/profile_pic_icon.png"
    };
    String bodyF = jsonEncode(body);
    print(bodyF);

    var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/signup');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body == "planit name taken") {
        //show alert that planit already exists with that name
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('This Planit name is taken. Try again.'),
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
        //can go to the next page to choose theme
        var decodedBody = json.decode(response.body);
        print(decodedBody);
        var id = decodedBody["insertId"];
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ChooseThemePage(
                    email: widget.email, planitName: planitName, userId: id)));
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
                        controller: planitNameTextController,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Planit Name",
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
                            return 'Please enter planit name';
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
                  onPressed: signup,
                  child: Text(
                    "Next",
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
