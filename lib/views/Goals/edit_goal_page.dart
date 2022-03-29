import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/life_category.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';

class EditGoalPage extends StatefulWidget {
  const EditGoalPage(
      {Key? key, required this.updateGoal, required this.goalIdx})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateGoal;
  final int goalIdx;

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final descriptionTxtController = TextEditingController(
      text:
          PlannerService.sharedInstance.user.goals[widget.goalIdx].description);
  late final dateTxtController = TextEditingController(
      text: DateFormat.yMMMd().format(
          PlannerService.sharedInstance.user.goals[widget.goalIdx].date));
  //late final categoryTxtController = TextEditingController(
  //text: PlannerService.sharedInstance.user.goals[widget.goalIdx].category);
  late final notesTxtController = TextEditingController(
      text: PlannerService.sharedInstance.user.goals[widget.goalIdx].notes);
  late var selectedDate =
      PlannerService.sharedInstance.user.goals[widget.goalIdx].date;
  bool doneBtnDisabled = true;
  late var currChosenCategory =
      PlannerService.sharedInstance.user.goals[widget.goalIdx].category;

  @override
  void initState() {
    super.initState();
    dateTxtController.addListener(setDoneBtnState);
    descriptionTxtController.addListener(setDoneBtnState);
    setDoneBtnState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateTxtController.text = DateFormat.yMMMd().format(selectedDate);
        //print(DateFormat.yMMMd().format(selectedDate));
      });
  }

  void editGoal() {
    var goalTitle = descriptionTxtController.text;
    var goalNotes = notesTxtController.text;
    //var category = categoryTxtController.text;

    PlannerService.sharedInstance.user.goals[widget.goalIdx].description =
        goalTitle;
    PlannerService.sharedInstance.user.goals[widget.goalIdx].notes = goalNotes;
    PlannerService.sharedInstance.user.goals[widget.goalIdx].category =
        currChosenCategory;
    PlannerService.sharedInstance.user.goals[widget.goalIdx].date =
        selectedDate;
    widget.updateGoal();
    _backToGoalsPage();
  }

  void setDoneBtnState() {
    print(dateTxtController.text);
    print(descriptionTxtController.text);
    if (dateTxtController.text != "" && descriptionTxtController.text != "") {
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

  void _backToGoalsPage() {
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
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Edit Goal"),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: doneBtnDisabled ? null : editGoal,
            child: const Text("Done"),
          ),
          // IconButton(
          //   icon: const Icon(Icons.check),
          //   color: Colors.pink,
          //   tooltip: 'Open shopping cart',
          //   onPressed: () {
          //     // handle the press
          //   },
          // ),
        ],
      ),
      body: Card(
        child: Container(
          child: ListView(
            children: [
              Image.asset(
                "assets/images/goal_icon.png",
                height: 80,
                width: 80,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        controller: descriptionTxtController,
                        decoration: const InputDecoration(
                          hintText: "What's your goal?",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      padding: EdgeInsets.all(20),
                    ),
                    Container(
                      child: TextFormField(
                        controller: dateTxtController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "By",
                          icon: Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onTap: () => _selectDate(context),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      padding: EdgeInsets.all(20),
                    ),
                    Container(
                      child: DropdownButton(
                        //value: PlannerService.sharedInstance.user.theme.themeId,
                        value: currChosenCategory,
                        items: List.generate(
                            PlannerService.sharedInstance.user.lifeCategories
                                .length, (int index) {
                          return DropdownMenuItem(
                            //value: "pink",
                            value: PlannerService
                                .sharedInstance.user.lifeCategories[index],
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: PlannerService.sharedInstance.user
                                      .lifeCategories[index].color,
                                ),
                                Text(PlannerService.sharedInstance.user
                                    .lifeCategories[index].name),
                              ],
                            ),
                          );
                        }),

                        // onChanged: (String? newValue) {
                        onChanged: (newValue) {
                          setState(() {
                            currChosenCategory = newValue!;
                          });
                        },
                      ),
                      padding: EdgeInsets.all(20),
                    ),
                    // Container(
                    //   child: TextFormField(
                    //     controller: categoryTxtController,
                    //     decoration: InputDecoration(
                    //         hintText: "Category",
                    //         icon: Icon(
                    //           Icons.category_rounded,
                    //           color: Theme.of(context).colorScheme.primary,
                    //         )),
                    //     validator: (String? value) {
                    //       if (value == null || value.isEmpty) {
                    //         return 'Please enter some text';
                    //       }
                    //       return null;
                    //     },
                    //   ),
                    //   padding: EdgeInsets.all(20),
                    // ),
                    Container(
                      child: TextFormField(
                        controller: notesTxtController,
                        decoration: const InputDecoration(
                          hintText: "Notes",
                          fillColor: Colors.white,
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        maxLines: null,
                        minLines: 10,
                      ),
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ],
                ),
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
