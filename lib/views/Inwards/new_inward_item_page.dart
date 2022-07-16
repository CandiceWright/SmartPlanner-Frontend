import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/definition.dart';
import 'package:practice_planner/models/event.dart';
import 'package:practice_planner/models/inward_item.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/views/Inwards/video_capture_page.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:http/http.dart' as http;

class NewInwardItemPage extends StatefulWidget {
  const NewInwardItemPage({Key? key, required this.updateContent})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateContent;

  @override
  State<NewInwardItemPage> createState() => _NewInwardItemPageState();
}

class _NewInwardItemPageState extends State<NewInwardItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var captionTxtController = TextEditingController();
  String content = "";
  bool doneBtnDisabled = true;

  @override
  void initState() {
    super.initState();
    captionTxtController.addListener(setDoneBtnState);
  }

  Future<void> createContent() async {
    var caption = captionTxtController.text;
    var content;
    //first make a call to the server
    var body = {
      'userId': PlannerService.sharedInstance.user!.id,
      'caption': caption,
      'content': content,
    };
    String bodyF = jsonEncode(body);
    print(bodyF);

    var url = Uri.parse('http://192.168.1.4:7343/dictionary');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      print(decodedBody);
      var id = decodedBody["insertId"];
      var newInwardItem = InwardItem(id, caption, DateTime.now(), content);
      PlannerService.sharedInstance.user!.inwardContent.add(newInwardItem);
      widget.updateContent();
      _backToInwardsPage();
    } else {
      //500 error, show an alert
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

  void setDoneBtnState() {
    if (captionTxtController.text != "" && content != "") {
      setState(() {
        print("button enabled");
        doneBtnDisabled = false;
      });
    } else {
      setState(() {
        doneBtnDisabled = true;
      });
    }
  }

  void _backToInwardsPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
              "New Thought",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,

            centerTitle: true,
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const VideoCapturePage()));
                  },
                  child: CircleAvatar(
                    child: const Icon(
                      Icons.video_camera_front,
                      color: Colors.white,
                    ),
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     CupertinoPageRoute(
                    //         builder: (context) => NewInwardItemPage(
                    //             updateContent: _updateContent)));
                  },
                  child: CircleAvatar(
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                    ),
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ]),
          ),
        )
      ],
    );
  }
}
