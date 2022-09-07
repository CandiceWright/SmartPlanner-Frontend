import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/views/Goals/accomplished_goals_page.dart';
import 'package:practice_planner/views/Legal/privacy_policy_page.dart';
import 'package:practice_planner/views/Legal/terms_of_use.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    //List<Widget> goalsListView = buildGoalsListView();

    return Stack(
      children: [
        Image.asset(
          PlannerService.sharedInstance.user!.spaceImage,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: const Text(
              "Help Center",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: true,
            bottom: const PreferredSize(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "www.anotherplanit.com",
                      style: TextStyle(color: Colors.white),
                      //textAlign: TextAlign.center,
                    ),
                  ),
                ),
                preferredSize: Size.fromHeight(10.0)),
          ),
          body: ListView(
            children: [
              Card(
                margin: EdgeInsets.all(10),
                child: TextButton(
                  child: Text("Privacy Policy"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const PrivacyPolicyPage();
                      },
                    ));
                  },
                ),
              ),
              Card(
                margin: EdgeInsets.all(10),
                child: TextButton(
                  child: Text("Terms of Use"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const TermsPage();
                      },
                    ));
                  },
                ),
              ),
            ],
          ),

          // This trailing comma makes auto-formatting nicer for build methods.
        )
      ],
    );
  }
}
