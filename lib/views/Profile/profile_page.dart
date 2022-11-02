import 'dart:convert';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:practice_planner/Themes/app_themes.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Home/home_page.dart';
import 'package:practice_planner/views/Legal/help_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login/login.dart';
import '../Subscription/subscription_page.dart';
import '../Subscription/subscription_page_no_free_trial.dart';
import '../navigation_wrapper.dart';
import '/services/planner_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
      TextEditingController(text: PlannerService.sharedInstance.user!.email);
  var usernameTxtFieldController = TextEditingController(
      text: PlannerService.sharedInstance.user!.planitName);
  var editCategoryTxtController = TextEditingController();
  bool saveEditCategoryBtnDisabled = false;
  bool categoryDoneBtnDisabled = true;
  bool accountDetailsDoneBtnDisabled = true;
  bool hasSelectedColor = false;
  var currentPasswordTextController = TextEditingController();
  bool enterCurrentPasswordBtnDisabled = true;
  var newPasswordTextController = TextEditingController();
  bool enterNewPasswordBtnDisabled = true;
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color editPickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  final ImagePicker _picker = ImagePicker();
  int selectedThemeId = PlannerService.sharedInstance.user!.themeId;
  String selectedSpaceTheme = PlannerService.sharedInstance.user!.spaceImage;
  // final LocalStorage storage = LocalStorage('planner_app');
  final Future<SharedPreferences> storage = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();

    categoryNameTxtController.addListener(setCategoryDoneBtnState);
    emailTxtConroller.addListener(setAccountUpdateBtnState);
    usernameTxtFieldController.addListener(setAccountUpdateBtnState);
    setCategoryDoneBtnState();
    setAccountUpdateBtnState();
    PlannerService.subscriptionProvider.receipt.addListener(saveReceipt);
  }

  void createCategory() async {
    //first save to server
    var body = {
      'name': categoryNameTxtController.text,
      'color': pickerColor.value,
      'userId': PlannerService.sharedInstance.user!.id
    };
    String bodyF = jsonEncode(body);
    //print(bodyF);

    var url =
        Uri.parse(PlannerService.sharedInstance.serverUrl + '/categories');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var decodedBody = json.decode(response.body);
      //print(decodedBody);
      var id = decodedBody["insertId"];
      var category =
          LifeCategory(id, categoryNameTxtController.text, pickerColor);
      int color = pickerColor.value;
      PlannerService.sharedInstance.user!.lifeCategories.add(category);
      PlannerService.sharedInstance.user!.backlogMap[category.name] = [];
      PlannerService.sharedInstance.user!
          .LifeCategoriesColorMap[category.name] = pickerColor;
      setState(() {
        categoryNameTxtController.text = "";
        hasSelectedColor = false;
      });
      setCategoryDoneBtnState();
      Navigator.pop(context);
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

  restorePurchase() {
    PlannerService.subscriptionProvider.restorePurchases();
    //this should trigger saveReceipt() after successful
  }

  saveReceipt() async {
    if (PlannerService.subscriptionProvider.receipt.value != "") {
      //print("Saving receipt");
      var receipt = PlannerService.subscriptionProvider.receipt.value;
      //print(receipt);
      var body = {
        'receipt': receipt,
        //'userId': PlannerService.sharedInstance.user!.id
        'email': PlannerService.sharedInstance.user!.email
      };
      var bodyF = jsonEncode(body);
      ////print(bodyF);

      var url =
          Uri.parse(PlannerService.sharedInstance.serverUrl + '/user/receipt');
      var response = await http.patch(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);
      //print('Response status: ${response.statusCode}');
      ////print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        //PlannerService.sharedInstance.user!.receipt = receipt;
        //I am done with these values so now I can reset thee values
        PlannerService.subscriptionProvider.purchaseSuccess.value = false;
        PlannerService.subscriptionProvider.purchaseRestored.value = false;
        PlannerService.subscriptionProvider.receipt.value = "";
        PlannerService.sharedInstance.user!.receipt = receipt;
        //verify the receipt and update its status as needed

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                    "Your purchase has been restore your purchase. Try using your premium subscription."),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      PlannerService.subscriptionProvider.receipt
                          .removeListener(saveReceipt);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      } else {
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
  }

  void setAccountUpdateBtnState() {
    //print("printing email ttext");
    //print(emailTxtConroller.text);
    if ((usernameTxtFieldController.text != "" ||
            emailTxtConroller.text != "") &&
        (usernameTxtFieldController.text !=
                PlannerService.sharedInstance.user!.planitName ||
            emailTxtConroller.text !=
                PlannerService.sharedInstance.user!.email)) {
      setState(() {
        accountDetailsDoneBtnDisabled = false;
      });
    } else {
      setState(() {
        accountDetailsDoneBtnDisabled = true;
      });
    }
  }

  Future<void> saveAccountUpdates() async {
    if (PlannerService.sharedInstance.user!.planitName !=
        usernameTxtFieldController.text) {
      //planit name changed
      var body = {
        'userId': PlannerService.sharedInstance.user!.id,
        'planitName': usernameTxtFieldController.text,
      };
      String bodyF = jsonEncode(body);
      //print(bodyF);

      var url = Uri.parse(
          PlannerService.sharedInstance.serverUrl + '/user/planitname');
      var response = await http.patch(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        PlannerService.sharedInstance.user!.planitName =
            usernameTxtFieldController.text;
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
    if (PlannerService.sharedInstance.user!.email != emailTxtConroller.text) {
      //email changed
      var body = {
        'userId': PlannerService.sharedInstance.user!.id,
        'email': emailTxtConroller.text,
      };
      String bodyF = jsonEncode(body);
      //print(bodyF);

      var url =
          Uri.parse(PlannerService.sharedInstance.serverUrl + '/user/email');
      var response = await http.patch(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        PlannerService.sharedInstance.user!.email = emailTxtConroller.text;
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

    setAccountUpdateBtnState();
  }

  void setCategoryDoneBtnState() {
    //print("I am in set done button state");
    //print(categoryNameTxtController.text);
    //print(hasSelectedColor);
    if (categoryNameTxtController.text != "" && hasSelectedColor) {
      setState(() {
        //print("button enabled");
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
    //print("I am in change color");
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
                      //print("button enabled");
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
                    //print("button enabled");
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
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: AlertDialog(
                  title: Container(
                    child: const Text(
                      "New Category",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  content: dialogContent(setDialogState),
                  actions: <Widget>[
                    TextButton(
                        onPressed:
                            categoryDoneBtnDisabled ? null : createCategory,
                        child: const Text('Create')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                  ],
                ),
              ),
            );
          });
        });
  }

  showEditCategoryDialog(int idx) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: AlertDialog(
                  title: Container(
                    child: Text(
                      PlannerService
                          .sharedInstance.user!.lifeCategories[idx].name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  content: editDialogContent(setDialogState, idx),
                  // content: SingleChildScrollView(
                  //   child: editDialogContent(setDialogState, idx),
                  // ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: saveEditCategoryBtnDisabled
                            ? null
                            : () {
                                editCategory(idx);
                              },
                        child: const Text('Save')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                  ],
                ),
              ),
            );
          });
        });
  }

  editDialogContent(StateSetter setDialogState, int idx) {
    return Column(
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
                if (editCategoryTxtController.text != "" && hasSelectedColor) {
                  setState(() {
                    //print("button enabled");
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
                  //print("button enabled");
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
    );
  }

  Future<void> editCategory(int idx) async {
    //first make a call to the server to edit
    var body = {
      'name': editCategoryTxtController.text,
      'color': editPickerColor.value,
      'userId': PlannerService.sharedInstance.user!.id,
      'categoryId': PlannerService.sharedInstance.user!.lifeCategories[idx].id
    };
    String bodyF = jsonEncode(body);
    //print(bodyF);

    var url =
        Uri.parse(PlannerService.sharedInstance.serverUrl + '/categories');
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var oldCategoryName =
          PlannerService.sharedInstance.user!.lifeCategories[idx].name;
      if (PlannerService.sharedInstance.user!.lifeCategories[idx].name !=
          editCategoryTxtController.text) {
        //need to change the category backlog map
        var backlogArr =
            PlannerService.sharedInstance.user!.backlogMap[oldCategoryName];
        //create a new map entry for the new name and delete the old
        PlannerService.sharedInstance.user!
            .backlogMap[editCategoryTxtController.text] = backlogArr!;
        PlannerService.sharedInstance.user!.backlogMap.remove(oldCategoryName);
        PlannerService.sharedInstance.user!.lifeCategories[idx].name =
            editCategoryTxtController.text;
        PlannerService.sharedInstance.user!.lifeCategories[idx].color =
            editPickerColor;
        PlannerService.sharedInstance.user!.LifeCategoriesColorMap
            .remove(oldCategoryName);
        PlannerService.sharedInstance.user!
                .LifeCategoriesColorMap[editCategoryTxtController.text] =
            editPickerColor;
      } else {
        PlannerService.sharedInstance.user!.lifeCategories[idx].color =
            editPickerColor;
        PlannerService.sharedInstance.user!
            .LifeCategoriesColorMap[oldCategoryName] = editPickerColor;
      }
      setState(() {});
      Navigator.pop(context);
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

  void deleteCategory(int idx) {}

  Future pickImage() async {
    //await _picker.pickImage(source: ImageSource.gallery);
    //print("I am picking image");
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    var path = image!.path;
    var name = image.name;
    //imageCache!.clear();

    //save image locally
    // final directory = await getApplicationDocumentsDirectory();
    // String localDirPath = directory.path;
    // String profilePicPath = '$localDirPath/profilepic';
    // File file = File(profilePicPath);
    // file.delete();
    // image.saveTo(profilePicPath);

    // setState(() {
    //   //print("setting path state");
    //   PlannerService.sharedInstance.user!.localProfileImage = profilePicPath;
    // });

    //first upload image to firebase and get image url. then save url to db
    String? result =
        await PlannerService.firebaseStorage.uploadProfilePic(path, name);
    if (result == "error") {
      //error message
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
    } else {
      //success and result holds url
      var url = Uri.parse(
          PlannerService.sharedInstance.serverUrl + '/user/profileimage');
      var body = {
        'image': result,
        'id': PlannerService.sharedInstance.user!.id
      };
      String bodyF = jsonEncode(body);
      var response = await http.patch(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);

      //print("server came back with a response after saving image");
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ////print(PlannerService.sharedInstance.user!.profileImage = result!);
        setState(() {
          // PlannerService.sharedInstance.user!.profileImage = path;
          PlannerService.sharedInstance.user!.profileImage = result!;
        });
      } else {
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
  }

  storeProfileImage(String path, String name) async {
    //first upload image to firebase and get image url. then save url to db
    String? result =
        await PlannerService.firebaseStorage.uploadProfilePic(path, name);
    if (result == "error") {
      //error message
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
    } else {
      //success and result holds url to profile pic so store in db
      var url = Uri.parse(
          PlannerService.sharedInstance.serverUrl + '/user/profileimage');
      var body = {
        'image': result,
        'id': PlannerService.sharedInstance.user!.id
      };
      String bodyF = jsonEncode(body);
      var response = await http.patch(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);

      //print("server came back with a response after saving image");
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        //print(PlannerService.sharedInstance.user!.profileImage = result!);
        //setState(() {
        // PlannerService.sharedInstance.user!.profileImage = path;
        PlannerService.sharedInstance.user!.profileImage = result!;
        //});
      } else {
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
  }

  void changePasswordClicked() {
    showDialog(
      context: context, // user must tap button!

      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            //insetPadding: EdgeInsets.symmetric(vertical: 200, horizontal: 100),
            //child: Expanded(
            //child: Container(
            title: const Text("Change Password"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: changePasswordDialogContent(setDialogState),

            actions: <Widget>[
              TextButton(
                  child: const Text('next'),
                  onPressed: enterCurrentPasswordBtnDisabled
                      ? null
                      : validateCurrentPassword),
              TextButton(
                child: const Text('cancel'),
                onPressed: () {
                  currentPasswordTextController.text = "";
                  Navigator.of(context).pop();
                },
              )
            ],
            // ),
            //),
          );
        });
      },
    );
  }

  changePasswordDialogContent(StateSetter setDialogState) {
    return TextFormField(
      controller: currentPasswordTextController,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      onChanged: (text) {
        setDialogState(() {
          if (text != "") {
            setState(() {
              //print("button enabled");
              enterCurrentPasswordBtnDisabled = false;
            });
          } else {
            setState(() {
              enterCurrentPasswordBtnDisabled = true;
            });
          }
        });
      },
      decoration: const InputDecoration(
        hintText: "Enter current password",
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Future<void> validateCurrentPassword() async {
    //I need to encrypt this before sending to server
    var body = {
      'email': PlannerService.sharedInstance.user!.email,
      'password': currentPasswordTextController.text
    };
    String bodyF = jsonEncode(body);
    //print(bodyF);

    var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/login');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body == "wrong password") {
        //show error
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Wrong Password!'),
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
        //all good. show dialong for new password
        Navigator.of(context).pop();
        changePassword();
      }
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

  void changePassword() {
    showDialog(
      context: context, // user must tap button!

      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            //insetPadding: EdgeInsets.symmetric(vertical: 200, horizontal: 100),
            //child: Expanded(
            //child: Container(
            title: const Text("Choose a New Password"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: newPasswordDialogContent(setDialogState),

            actions: <Widget>[
              TextButton(
                  child: const Text('save & log out'),
                  onPressed:
                      enterNewPasswordBtnDisabled ? null : saveNewPassword),
              TextButton(
                child: const Text('cancel'),
                onPressed: () {
                  newPasswordTextController.text = "";
                  Navigator.of(context).pop();
                },
              )
            ],
            // ),
            //),
          );
        });
      },
    );
  }

  newPasswordDialogContent(StateSetter setDialogState) {
    return Column(
      children: [
        Text(
            "You will be logged out after changing your password so that you can sign back in with your new password."),
        TextFormField(
          controller: newPasswordTextController,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          onChanged: (text) {
            setDialogState(() {
              if (text != "") {
                setState(() {
                  //print("button enabled");
                  enterNewPasswordBtnDisabled = false;
                });
              } else {
                setState(() {
                  enterNewPasswordBtnDisabled = true;
                });
              }
            });
          },
          decoration: const InputDecoration(
            hintText: "Enter new password",
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        )
      ],
    );
  }

  Future<void> saveNewPassword() async {
    //first make a call to the server with habit name, userId
    var body = {
      'email': PlannerService.sharedInstance.user!.email,
      'newPass': newPasswordTextController.text
    };
    String bodyF = jsonEncode(body);
    //print(bodyF);

    var url =
        Uri.parse(PlannerService.sharedInstance.serverUrl + '/user/password');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body == "password updated successfully") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginPage(),
          ),
          (route) => false,
        );
      } else {
        Navigator.of(context).pop();
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

  void changeThemeColor() async {
    var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/theme/');
    var body = {
      'theme': selectedThemeId,
      'email': PlannerService.sharedInstance.user!.email
    };
    String bodyF = jsonEncode(body);
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        PlannerService.sharedInstance.user!.themeId = selectedThemeId;

        //     PlannerService
        //         .sharedInstance.themeColorMap[newValue]!;
        DynamicTheme.of(context)!.setTheme(selectedThemeId);
      });
    } else {
      //error message
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

  void changeSpaceTheme() async {
    var url =
        Uri.parse(PlannerService.sharedInstance.serverUrl + '/spaceTheme/');
    var body = {
      'image': selectedSpaceTheme,
      'email': PlannerService.sharedInstance.user!.email
    };
    String bodyF = jsonEncode(body);
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        PlannerService.sharedInstance.user!.spaceImage = selectedSpaceTheme;
      });
    } else {
      //error message
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

  void deleteAccount() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              child: const Text(
                "Are you sure you want to delete your account? ",
                textAlign: TextAlign.center,
              ),
            ),
            content: Text(
                "This action cannot be reversed. If yes, all of your content along with your account will be deleted. After account deletion, end your subscription in your phone settings."),
            actions: <Widget>[
              TextButton(
                child: Text('yes, delete my account.'),
                onPressed: () async {
                  //first send server request
                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/user/' +
                      PlannerService.sharedInstance.user!.id.toString());
                  var response = await http.delete(
                    url,
                  );
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    //await storage.setItem('login', false);
                    await storage.then((SharedPreferences prefs) {
                      prefs.setBool('login', false);
                    });
                    //navigate to login screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                      (route) => false,
                    );
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
                },
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('cancel'))
            ],
          );
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
            backgroundColor: Colors.transparent,

            title: Text(
              PlannerService.sharedInstance.user!.planitName,
              // style: GoogleFonts.roboto(
              //   textStyle: const TextStyle(
              //     color: Colors.white,
              //   ),
              // ),
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            //leading: BackButton(color: Colors.black),
            leading: BackButton(onPressed: () {
              PlannerService.subscriptionProvider.receipt
                  .removeListener(saveReceipt);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const NavigationWrapper();
                },
                settings: const RouteSettings(
                  name: 'navigaionPage',
                ),
              ));
            }),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const HelpPage();
                      },
                    ));
                  },
                  icon: const Icon(Icons.help))
            ],
          ),
          body: Card(
            child: Container(
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Center(
                      child: PlannerService.sharedInstance.user!.profileImage ==
                              "assets/images/profile_pic_icon.png"
                          ? CircleAvatar(
                              // // backgroundImage: AssetImage(
                              //     PlannerService.sharedInstance.user!.profileImage),
                              backgroundImage: AssetImage(PlannerService
                                  .sharedInstance.user!.profileImage),
                              radius: 40,
                            )
                          :
                          // File(PlannerService
                          //             .sharedInstance.user!.localProfileImage)
                          //         .existsSync()
                          //     ? CircleAvatar(
                          //         backgroundImage: FileImage(File(PlannerService
                          //             .sharedInstance.user!.localProfileImage)),
                          //         radius: 30,
                          //       )
                          //     :
                          CircleAvatar(
                              // // backgroundImage: AssetImage(
                              //     PlannerService.sharedInstance.user!.profileImage),
                              backgroundImage: NetworkImage(PlannerService
                                  .sharedInstance.user!.profileImage),
                              radius: 40,
                            ),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.circle),
                            iconSize:
                                PlannerService.sharedInstance.user!.themeId == 0
                                    ? 40
                                    : 24,
                            color: AppThemes().pinkPrimarySwatch,
                            onPressed: () {
                              setState(() {
                                //PlannerService.sharedInstance.user!.themeId = 0;
                                selectedThemeId = 0;
                                changeThemeColor();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.circle),
                            iconSize:
                                PlannerService.sharedInstance.user!.themeId == 1
                                    ? 40
                                    : 24,
                            color: AppThemes().bluePrimarySwatch,
                            onPressed: () {
                              setState(() {
                                //PlannerService.sharedInstance.user!.themeId = 1;
                                selectedThemeId = 1;
                                changeThemeColor();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.circle),
                            iconSize:
                                PlannerService.sharedInstance.user!.themeId == 2
                                    ? 40
                                    : 24,
                            color: AppThemes().greenPrimarySwatch,
                            onPressed: () {
                              setState(() {
                                //PlannerService.sharedInstance.user!.themeId = 2;
                                selectedThemeId = 2;
                                changeThemeColor();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.circle),
                            iconSize:
                                PlannerService.sharedInstance.user!.themeId == 3
                                    ? 40
                                    : 24,
                            color: AppThemes().orangePrimarySwatch,
                            onPressed: () {
                              setState(() {
                                //PlannerService.sharedInstance.user!.themeId = 3;
                                selectedThemeId = 3;
                                changeThemeColor();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.circle),
                            iconSize:
                                PlannerService.sharedInstance.user!.themeId == 4
                                    ? 40
                                    : 24,
                            color: AppThemes().greyPrimarySwatch,
                            onPressed: () {
                              setState(() {
                                //PlannerService.sharedInstance.user!.themeId = 4;
                                selectedThemeId = 4;
                                changeThemeColor();
                              });
                            },
                          ),
                        ],
                      ),
                      //Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      //children: [
                      // GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         selectedSpaceTheme =
                      //             'assets/images/black_stars_background.jpeg';
                      //         changeSpaceTheme();
                      //       });
                      //     },
                      //     child: Padding(
                      //       padding: EdgeInsets.all(10),
                      //       child: CircleAvatar(
                      //         backgroundImage: const AssetImage(
                      //             'assets/images/black_stars_background.jpeg'),
                      //         //backgroundColor: Colors.white,
                      //         radius: PlannerService.sharedInstance.user!
                      //                     .spaceImage ==
                      //                 'assets/images/black_stars_background.jpeg'
                      //             ? 17.0
                      //             : 10.0,
                      //         // child: ClipRRect(
                      //         //   child: Image.asset(
                      //         //       'assets/images/black_stars_background.jpeg'),
                      //         //   borderRadius: BorderRadius.circular(50.0),
                      //         // ),
                      //       ),
                      //     )),
                      // GestureDetector(
                      //   onTap: () {
                      //     setState(() {
                      //       selectedSpaceTheme =
                      //           'assets/images/login_screens_background.png';
                      //       changeSpaceTheme();
                      //     });
                      //   },
                      //   child: Padding(
                      //     padding: EdgeInsets.all(10),
                      //     child: CircleAvatar(
                      //       backgroundImage: const AssetImage(
                      //           'assets/images/login_screens_background.png'),
                      //       //backgroundColor: Colors.white,
                      //       radius: PlannerService
                      //                   .sharedInstance.user!.spaceImage ==
                      //               'assets/images/login_screens_background.png'
                      //           ? 17.0
                      //           : 10.0,
                      //       child: ClipRRect(
                      //         child: Image.asset(
                      //             'assets/images/login_screens_background.png'),
                      //         borderRadius: BorderRadius.circular(50.0),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      //],
                      //),
                      Card(
                        child: Column(
                          children: [
                            const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "My Life Categories",
                                  // style: GoogleFonts.roboto(
                                  //   textStyle: const TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )),
                            Container(
                              height: 80.0,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                    PlannerService.sharedInstance.user!
                                        .lifeCategories.length, (int index) {
                                  return GestureDetector(
                                      onTap: () {
                                        ////print("I tapped.");
                                        editCategoryTxtController.text =
                                            PlannerService.sharedInstance.user!
                                                .lifeCategories[index].name;
                                        editPickerColor = PlannerService
                                            .sharedInstance
                                            .user!
                                            .lifeCategories[index]
                                            .color;
                                        showEditCategoryDialog(index);
                                      },
                                      child: Card(
                                        //color: Colors.white,
                                        color: PlannerService.sharedInstance
                                            .user!.lifeCategories[index].color,
                                        elevation: 2,
                                        // shape:
                                        //     const ContinuousRectangleBorder(),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        shadowColor: PlannerService
                                            .sharedInstance
                                            .user!
                                            .lifeCategories[index]
                                            .color,
                                        //color: Colors.blue[index * 100],
                                        child: Flex(
                                            direction: Axis.horizontal,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                //width: 50.0,
                                                //height: 50.0,
                                                children: [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Text(
                                                        PlannerService
                                                            .sharedInstance
                                                            .user!
                                                            .lifeCategories[
                                                                index]
                                                            .name,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )),
                                                  // Icon(
                                                  //   Icons.circle,
                                                  //   color: PlannerService
                                                  //       .sharedInstance
                                                  //       .user!
                                                  //       .lifeCategories[index]
                                                  //       .color,
                                                  // ),
                                                ],
                                              )
                                            ]),
                                      ));
                                }),
                              ),
                              color: Colors.white,
                            ),
                            TextButton(
                                onPressed: () async {
                                  if (PlannerService
                                      .sharedInstance.user!.isPremiumUser!) {
                                    showAddCategoryDialog();
                                  } else {
                                    if (PlannerService
                                            .sharedInstance.user!.receipt ==
                                        "") {
                                      //should geet free trial
                                      List<ProductDetails> productDetails =
                                          await PlannerService
                                              .subscriptionProvider
                                              .fetchSubscriptions();

                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return SubscriptionPage(
                                              fromPage: 'inapp',
                                              products: productDetails);
                                        },
                                      ));
                                    } else {
                                      List<ProductDetails> productDetails =
                                          await PlannerService
                                              .subscriptionProvider
                                              .fetchSubscriptions();

                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return SubscriptionPageNoTrial(
                                              fromPage: 'inapp',
                                              products: productDetails);
                                        },
                                      ));
                                    }
                                  }
                                },
                                child: Text(
                                  "Add New",
                                  style: TextStyle(color: Colors.black),
                                )),
                          ],
                        ),
                        color: Colors.white,
                        elevation: 0,
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
                                  hintText: "Planit Name",
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
                                onPressed: () => {changePasswordClicked()},
                                child: Text("Change Password")),
                            TextButton(
                                onPressed: () => {deleteAccount()},
                                child: Text("Delete Account")),
                          ],
                        ),
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      !PlannerService.sharedInstance.user!.isPremiumUser!
                          ? ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black)),
                              onPressed: () async {
                                PlannerService.subscriptionProvider.receipt
                                    .removeListener(saveReceipt);
                                if (PlannerService
                                        .sharedInstance.user!.receipt ==
                                    "") {
                                  //should geet free trial
                                  List<ProductDetails> productDetails =
                                      await PlannerService.subscriptionProvider
                                          .fetchSubscriptions();

                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return SubscriptionPage(
                                          fromPage: 'inapp',
                                          products: productDetails);
                                    },
                                  ));
                                } else {
                                  List<ProductDetails> productDetails =
                                      await PlannerService.subscriptionProvider
                                          .fetchSubscriptions();

                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return SubscriptionPageNoTrial(
                                          fromPage: 'inapp',
                                          products: productDetails);
                                    },
                                  ));
                                }
                              },
                              child: Text("Upgrade to premium!"),
                            )
                          : Container(),
                      ElevatedButton(
                        onPressed: () async {
                          //storage.setItem('login', false);
                          await storage.then((SharedPreferences prefs) {
                            prefs.setBool('login', false);
                          });
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text("Log out"),
                      ),
                      PlannerService.sharedInstance.user!.isPremiumUser!
                          ? TextButton(
                              onPressed: () => {restorePurchase()},
                              child: const Text("Restore Purchase"))
                          : Container(),
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
