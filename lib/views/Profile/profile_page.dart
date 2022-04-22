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
import 'package:image_picker/image_picker.dart';

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
  var categoryNameTxtController = TextEditingController();
  var emailTxtConroller =
      TextEditingController(text: PlannerService.sharedInstance.user.email);
  var usernameTxtFieldController =
      TextEditingController(text: PlannerService.sharedInstance.user.username);
  var editCategoryTxtController = TextEditingController();
  bool saveEditCategoryBtnDisabled = false;
  bool categoryDoneBtnDisabled = true;
  bool accountDetailsDoneBtnDisabled = true;
  bool hasSelectedColor = false;
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color editPickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    categoryNameTxtController.addListener(setCategoryDoneBtnState);
    emailTxtConroller.addListener(setAccountUpdateBtnState);
    usernameTxtFieldController.addListener(setAccountUpdateBtnState);
    setCategoryDoneBtnState();
    setAccountUpdateBtnState();
  }

  void createCategory() {
    var category = LifeCategory(categoryNameTxtController.text, pickerColor);
    PlannerService.sharedInstance.user.lifeCategories.add(category);
    PlannerService.sharedInstance.user.backlogMap[category.name] = [];
    PlannerService.sharedInstance.user.LifeCategoriesColorMap[category.name] =
        pickerColor;
    setState(() {
      categoryNameTxtController.text = "";
      hasSelectedColor = false;
    });
    setCategoryDoneBtnState();
    Navigator.pop(context);
  }

  void setAccountUpdateBtnState() {
    print("printing email ttext");
    print(emailTxtConroller.text);
    if ((usernameTxtFieldController.text != "" ||
            emailTxtConroller.text != "") &&
        (usernameTxtFieldController.text !=
                PlannerService.sharedInstance.user.username ||
            emailTxtConroller.text !=
                PlannerService.sharedInstance.user.email)) {
      setState(() {
        accountDetailsDoneBtnDisabled = false;
      });
    } else {
      setState(() {
        accountDetailsDoneBtnDisabled = true;
      });
    }
  }

  void saveAccountUpdates() {
    PlannerService.sharedInstance.user.username =
        usernameTxtFieldController.text;
    PlannerService.sharedInstance.user.email = emailTxtConroller.text;
    setAccountUpdateBtnState();
  }

  void setCategoryDoneBtnState() {
    print("I am in set done button state");
    print(categoryNameTxtController.text);
    print(hasSelectedColor);
    if (categoryNameTxtController.text != "" && hasSelectedColor) {
      setState(() {
        print("button enabled");
        categoryDoneBtnDisabled = false;
      });
    } else {
      setState(() {
        categoryDoneBtnDisabled = true;
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
    setCategoryDoneBtnState();
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
              controller: categoryNameTxtController,
              onChanged: (text) {
                setDialogState(() {
                  if (categoryNameTxtController.text != "" &&
                      hasSelectedColor) {
                    setState(() {
                      print("button enabled");
                      categoryDoneBtnDisabled = false;
                    });
                  } else {
                    setState(() {
                      categoryDoneBtnDisabled = true;
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
                if (categoryNameTxtController.text != "" && hasSelectedColor) {
                  setState(() {
                    print("button enabled");
                    categoryDoneBtnDisabled = false;
                  });
                } else {
                  setState(() {
                    categoryDoneBtnDisabled = true;
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
              actions: <Widget>[
                TextButton(
                    onPressed: categoryDoneBtnDisabled ? null : createCategory,
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

  showEditCategoryDialog(int idx) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: Container(
                child: Text(
                  PlannerService.sharedInstance.user.lifeCategories[idx].name,
                  textAlign: TextAlign.center,
                ),
              ),
              content: editDialogContent(setDialogState, idx),
              actions: <Widget>[
                TextButton(
                    onPressed: saveEditCategoryBtnDisabled
                        ? null
                        : () {
                            editCategory(idx);
                          },
                    child: const Text('Save')),
                // TextButton(
                //     onPressed: () {
                //       deleteCategory(idx);
                //     },
                //     child: const Text('Delete')),
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

  editDialogContent(StateSetter setDialogState, int idx) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: editCategoryTxtController,
              //initialValue:
              //PlannerService.sharedInstance.user.lifeCategories[idx].name,
              onChanged: (text) {
                setDialogState(() {
                  if (editCategoryTxtController.text != "" &&
                      hasSelectedColor) {
                    setState(() {
                      print("button enabled");
                      saveEditCategoryBtnDisabled = false;
                    });
                  } else {
                    setState(() {
                      saveEditCategoryBtnDisabled = true;
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
            pickerColor: editPickerColor,
            onColorChanged: (color) {
              setDialogState(() {
                editPickerColor = color;
                hasSelectedColor = true;
                if (editCategoryTxtController.text != "" && hasSelectedColor) {
                  setState(() {
                    print("button enabled");
                    saveEditCategoryBtnDisabled = false;
                  });
                } else {
                  setState(() {
                    saveEditCategoryBtnDisabled = true;
                  });
                }
              });
            },
          ),
        ],
      ),
    );
  }

  void editCategory(int idx) {
    var oldCategoryName =
        PlannerService.sharedInstance.user.lifeCategories[idx].name;
    if (PlannerService.sharedInstance.user.lifeCategories[idx].name !=
        editCategoryTxtController.text) {
      //need to change the category backlog map
      var backlogArr =
          PlannerService.sharedInstance.user.backlogMap[oldCategoryName];
      //create a new map entry for the new name and delete the old
      PlannerService.sharedInstance.user
          .backlogMap[editCategoryTxtController.text] = backlogArr!;
      PlannerService.sharedInstance.user.backlogMap.remove(oldCategoryName);
      PlannerService.sharedInstance.user.lifeCategories[idx].name =
          editCategoryTxtController.text;
      PlannerService.sharedInstance.user.lifeCategories[idx].color =
          editPickerColor;
      PlannerService.sharedInstance.user.LifeCategoriesColorMap
          .remove(oldCategoryName);
      PlannerService.sharedInstance.user
              .LifeCategoriesColorMap[editCategoryTxtController.text] =
          editPickerColor;
    } else {
      PlannerService.sharedInstance.user.lifeCategories[idx].color =
          editPickerColor;
      PlannerService.sharedInstance.user
          .LifeCategoriesColorMap[oldCategoryName] = editPickerColor;
    }
    setState(() {});
    Navigator.pop(context);
  }

  void deleteCategory(int idx) {}

  Future pickImage() async {
    await _picker.pickImage(source: ImageSource.gallery);
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

            title: Text(
              PlannerService.sharedInstance.user.username,
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            //leading: BackButton(color: Colors.black),
          ),
          body: Card(
            child: Container(
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Image.asset(
                      PlannerService.sharedInstance.user.profileImage,
                      height: 80,
                      width: 80,
                    ),
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
                            PlannerService.sharedInstance.user.themeId =
                                newValue!;

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
                            Container(
                              height: 80.0,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                    PlannerService.sharedInstance.user
                                        .lifeCategories.length, (int index) {
                                  return GestureDetector(
                                      onTap: () {
                                        //print("I tapped.");
                                        editCategoryTxtController.text =
                                            PlannerService.sharedInstance.user
                                                .lifeCategories[index].name;
                                        editPickerColor = PlannerService
                                            .sharedInstance
                                            .user
                                            .lifeCategories[index]
                                            .color;
                                        showEditCategoryDialog(index);
                                      },
                                      child: Card(
                                        //color: Colors.blue[index * 100],
                                        child: Flex(
                                            direction: Axis.horizontal,
                                            children: [
                                              Column(
                                                //width: 50.0,
                                                //height: 50.0,
                                                children: [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Text(PlannerService
                                                          .sharedInstance
                                                          .user
                                                          .lifeCategories[index]
                                                          .name)),
                                                  Icon(
                                                    Icons.circle,
                                                    color: PlannerService
                                                        .sharedInstance
                                                        .user
                                                        .lifeCategories[index]
                                                        .color,
                                                  ),
                                                ],
                                              )
                                            ]),
                                      ));
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
                        //elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      Card(
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "Account Details",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )),
                            Padding(
                              padding: EdgeInsets.all(4),
                              child: TextFormField(
                                controller: usernameTxtFieldController,
                                decoration: InputDecoration(
                                  hintText: "Username",
                                  icon: Icon(
                                    Icons.person,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                onTap: () {},
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4),
                              child: TextFormField(
                                controller: emailTxtConroller,
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  icon: Icon(
                                    Icons.email,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                onTap: () {},
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            TextButton(
                                onPressed: accountDetailsDoneBtnDisabled
                                    ? null
                                    : saveAccountUpdates,
                                child: Text("Save")),
                            TextButton(
                                onPressed: () => {showAddCategoryDialog()},
                                child: Text("Change Password")),
                          ],
                        ),
                        color: Colors.white,
                        //elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      ElevatedButton(onPressed: () {}, child: Text("Log Out")),
                    ],
                  )
                ],
              ),
              margin: EdgeInsets.all(15),
            ),
            //color: Colors.pink.shade50,
            // margin: EdgeInsets.all(20),
            margin: EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
            //elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        )
      ],
    );
  }
}
