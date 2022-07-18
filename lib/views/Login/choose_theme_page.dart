import 'dart:convert';

import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/main.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/views/Login/login.dart';
import '../../Themes/app_themes.dart';
import '../../models/user.dart';
import '/views/Goals/goals_page.dart';
import '/views/navigation_wrapper.dart';
import 'package:http/http.dart' as http;

import 'enter_planit_video_page.dart';

class ChooseThemePage extends StatefulWidget {
  const ChooseThemePage(
      {Key? key,
      required this.email,
      required this.planitName,
      required this.userId})
      : super(key: key);

  final String email;
  final String planitName;
  final int userId;

  @override
  State<ChooseThemePage> createState() => _ChooseThemePageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _ChooseThemePageState extends State<ChooseThemePage> {
  //var planitNameTextController = TextEditingController();
  int themeId = 0;
  int spaceThemeId = 0;
  MaterialColor goBtnColor = AppThemes().pinkPrimarySwatch;

  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var questionIndex = 0;

  void signup() async {
    //call sign up server route and then go to home of app
    var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/theme/');
    //var response = await http.post(url);
    var body = {'theme': themeId, 'email': widget.email};
    String bodyF = jsonEncode(body);
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      DynamicTheme.of(context)!.setTheme(themeId);
      //create other category
      var body = {
        'name': "other",
        'color': Colors.grey.value.toString(),
        'userId': widget.userId
      };
      String bodyF = jsonEncode(body);
      print(bodyF);

      var url =
          Uri.parse(PlannerService.sharedInstance.serverUrl + '/categories');
      var response2 = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);

      if (response2.statusCode == 200) {
        var decodedBody = json.decode(response2.body);
        print(decodedBody);
        var id = decodedBody["insertId"];

//save spacetheme choice
        var url =
            Uri.parse(PlannerService.sharedInstance.serverUrl + '/spacetheme/');
        //var response = await http.post(url);
        String image;
        if (spaceThemeId == 0) {
          image = 'assets/images/black_stars_background.jpeg';
        } else {
          image = 'assets/images/login_screens_background.png';
        }
        var body = {'image': image, 'email': widget.email};
        String bodyF = jsonEncode(body);
        var response3 = await http.patch(url,
            headers: {"Content-Type": "application/json"}, body: bodyF);

        if (response3.statusCode == 200) {
          var user = User(
              id: widget.userId,
              planitName: widget.planitName,
              email: widget.email,
              profileImage: "assets/images/profile_pic_icon.png",
              themeId: themeId,
              spaceImage: image,
              //theme: PinkTheme(),
              didStartTomorrowPlanning: false,
              lifeCategories: [
                LifeCategory(id, "other", Colors.grey),
              ]);
          PlannerService.sharedInstance.user = user;
          PlannerService.sharedInstance.user!.LifeCategoriesColorMap["other"] =
              Colors.grey;

          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return const EnterPlannerVideoPage();
            },
          ));
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
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
      } else {
        //500 error, show an alert (something wrong creating category)
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
    } else {
      //404 error, show an alert (Something wrong choosing theme)
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
          spaceThemeId == 0
              ? 'assets/images/black_stars_background.jpeg'
              : 'assets/images/login_screens_background.png',
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
            // leading: Image.asset(
            //   "assets/images/planit_logo.png",
            // ),
          ),
          body: ListView(
            children: [
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: const Text(
                        "Choose a color theme for your planit",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.circle),
                          iconSize: themeId == 0 ? 60 : 40,
                          color: AppThemes().pinkPrimarySwatch,
                          onPressed: () {
                            setState(() {
                              themeId = 0;
                              goBtnColor = AppThemes().pinkPrimarySwatch;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.circle),
                          iconSize: themeId == 1 ? 60 : 40,
                          color: AppThemes().bluePrimarySwatch,
                          onPressed: () {
                            setState(() {
                              themeId = 1;
                              goBtnColor = AppThemes().bluePrimarySwatch;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.circle),
                          iconSize: themeId == 2 ? 60 : 40,
                          color: AppThemes().greenPrimarySwatch,
                          onPressed: () {
                            setState(() {
                              themeId = 2;
                              goBtnColor = AppThemes().greenPrimarySwatch;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.circle),
                          iconSize: themeId == 3 ? 60 : 40,
                          color: AppThemes().orangePrimarySwatch,
                          onPressed: () {
                            setState(() {
                              themeId = 3;
                              goBtnColor = AppThemes().orangePrimarySwatch;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.circle),
                          iconSize: themeId == 4 ? 60 : 40,
                          color: AppThemes().greyPrimarySwatch,
                          onPressed: () {
                            setState(() {
                              themeId = 4;
                              goBtnColor = AppThemes().greyPrimarySwatch;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: const Text(
                        "Choose your space theme",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                spaceThemeId = 0;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: spaceThemeId == 0 ? 30.0 : 20.0,
                                child: ClipRRect(
                                  child: Image.asset(
                                      'assets/images/black_stars_background.jpeg'),
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                              ),
                            )),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              spaceThemeId = 1;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: spaceThemeId == 1 ? 30.0 : 20.0,
                              child: ClipRRect(
                                child: Image.asset(
                                    'assets/images/login_screens_background.png'),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          persistentFooterButtons: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      onPressed: signup,
                      child: Text(
                        "Ok",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ButtonStyle(
                          // backgroundColor: MaterialStateProperty.all<Color>(
                          //     const Color(0xffef41a8)),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(goBtnColor)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
