import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/Themes/app_themes.dart';
import 'package:practice_planner/models/life_category.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:date_format/date_format.dart';
import '/models/event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.updateEvents}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateEvents;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var nameTxtController = TextEditingController();
  bool doneBtnDisabled = true;
  bool hasSelectedColor = false;
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  @override
  void initState() {
    super.initState();
    nameTxtController.addListener(setDoneBtnState);
    setDoneBtnState();
  }

  void createCategory() {
    var category = LifeCategory(nameTxtController.text, pickerColor);
    PlannerService.sharedInstance.user.lifeCategories.add(category);
    PlannerService.sharedInstance.user.backlogMap[category.name] = [];
    PlannerService.sharedInstance.user.LifeCategoriesColorMap[category.name] =
        pickerColor;
    setState(() {
      nameTxtController.text = "";
      hasSelectedColor = false;
    });
    setDoneBtnState();
    Navigator.pop(context);
  }

  void setDoneBtnState() {
    print("I am in set done button state");
    print(nameTxtController.text);
    print(hasSelectedColor);
    if (nameTxtController.text != "" && hasSelectedColor) {
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

// ValueChanged<Color> callback
  void changeColor(Color color) {
    print("I am in change color");
    setState(() {
      pickerColor = color;
      hasSelectedColor = true;
    });
    setDoneBtnState();
  }

  Widget dialogContent(StateSetter setDialogState) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: nameTxtController,
              onChanged: (text) {
                setDialogState(() {
                  if (nameTxtController.text != "" && hasSelectedColor) {
                    setState(() {
                      print("button enabled");
                      doneBtnDisabled = false;
                    });
                  } else {
                    setState(() {
                      doneBtnDisabled = true;
                    });
                  }
                });
              },
              decoration: InputDecoration(
                hintText: "Name",
                icon: Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
          ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              setDialogState(() {
                pickerColor = color;
                hasSelectedColor = true;
                if (nameTxtController.text != "" && hasSelectedColor) {
                  setState(() {
                    print("button enabled");
                    doneBtnDisabled = false;
                  });
                } else {
                  setState(() {
                    doneBtnDisabled = true;
                  });
                }
              });
            },
          ),
        ],
      ),
    );
  }

  void showAddCategoryDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Container(
                child: const Text(
                  "New Category",
                  textAlign: TextAlign.center,
                ),
              ),
              content: dialogContent(setDialogState),
              // Container(
              //   child: Column(
              //     mainAxisSize: MainAxisSize.min,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Padding(
              //         padding: EdgeInsets.only(bottom: 8),
              //         child: TextFormField(
              //           controller: nameTxtController,
              //           decoration: InputDecoration(
              //             hintText: "Name",
              //             icon: Icon(
              //               Icons.description,
              //               color: Theme.of(context).colorScheme.primary,
              //             ),
              //           ),
              //           validator: (String? value) {
              //             if (value == null || value.isEmpty) {
              //               return 'Please enter some text';
              //             }
              //             return null;
              //           },
              //         ),
              //       ),
              //       ColorPicker(
              //         pickerColor: pickerColor,
              //         onColorChanged: changeColor,
              //       ),
              //     ],
              //   ),
              // ),
              actions: <Widget>[
                TextButton(
                    onPressed: doneBtnDisabled ? null : createCategory,
                    child: const Text('Create')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          PlannerService.sharedInstance.user.username,
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
      ),
      body: Card(
        child: Container(
          child: ListView(
            children: [
              Image.asset(
                PlannerService.sharedInstance.user.profileImage,
                height: 80,
                width: 80,
              ),
              Column(
                children: [
                  DropdownButton(
                    //value: PlannerService.sharedInstance.user.theme.themeId,
                    value: PlannerService.sharedInstance.user.themeId,
                    items: [
                      DropdownMenuItem(
                        //value: "pink",
                        value: AppThemes.pink,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.circle,
                              color: Colors.pink,
                            ),
                            Text("Pink")
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        //value: "blue",
                        value: AppThemes.blue,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.circle,
                              color: Colors.blue,
                            ),
                            Text("Blue")
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        //value: "neutral",
                        value: AppThemes.neutral,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.circle,
                              color: Colors.brown,
                            ),
                            Text("Neutral")
                          ],
                        ),
                      ),
                    ],
                    // onChanged: (String? newValue) {
                    onChanged: (int? newValue) {
                      setState(() {
                        PlannerService.sharedInstance.user.themeId = newValue!;
                        //     PlannerService
                        //         .sharedInstance.themeColorMap[newValue]!;
                        DynamicTheme.of(context)!.setTheme(newValue);
                      });
                    },
                  ),
                  Card(
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "My Life Categories",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )),
                        // Padding(
                        //   padding: EdgeInsets.all(5),
                        //   child: Row(
                        //     children: [
                        //       Text(
                        //         "MY LIFE CATTEGORIES",
                        //         style: TextStyle(fontWeight: FontWeight.bold),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //       TextButton(
                        //           onPressed: () => {}, child: Text("Add New"))
                        //     ],
                        //   ),
                        // ),
                        Container(
                          height: 80.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(
                                PlannerService.sharedInstance.user
                                    .lifeCategories.length, (int index) {
                              return Card(
                                color: Colors.blue[index * 100],
                                child:
                                    Flex(direction: Axis.horizontal, children: [
                                  Column(
                                    //width: 50.0,
                                    //height: 50.0,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(PlannerService
                                              .sharedInstance
                                              .user
                                              .lifeCategories[index]
                                              .name)),
                                      Icon(
                                        Icons.circle,
                                        color: PlannerService.sharedInstance
                                            .user.lifeCategories[index].color,
                                      ),
                                    ],
                                  )
                                ]),
                              );
                            }),
                          ),
                          color: Colors.white,
                        ),
                        TextButton(
                            onPressed: () => {showAddCategoryDialog()},
                            child: Text("Add New")),
                      ],
                    ),
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ],
              )
            ],
          ),
          margin: EdgeInsets.all(15),
        ),
        //color: Colors.pink.shade50,
        // margin: EdgeInsets.all(20),
        margin: EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
