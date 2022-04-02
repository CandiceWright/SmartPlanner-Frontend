import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/life_category.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:date_format/date_format.dart';
import '/models/event.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage(
      {Key? key,
      required this.updateBacklog,
      required this.id,
      required this.category})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateBacklog;
  final int id;
  final String category;

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late var selectedDate = PlannerService
      .sharedInstance.user.backlogMap[widget.category]![widget.id].completeBy;
  late var descriptionTxtController = TextEditingController(
      text: PlannerService.sharedInstance.user
          .backlogMap[widget.category]![widget.id].description);
  late var locationTxtController = TextEditingController(
      text: PlannerService.sharedInstance.user
          .backlogMap[widget.category]![widget.id].location);
  late var notesTxtController = TextEditingController(
      text: PlannerService
          .sharedInstance.user.backlogMap[widget.category]![widget.id].notes);
  late var dateTxtController = TextEditingController(
      text: DateFormat.yMMMd().format(PlannerService.sharedInstance.user
          .backlogMap[widget.category]![widget.id].completeBy!));

  bool doneBtnDisabled = true;
  late var currChosenCategory = PlannerService
      .sharedInstance.user.backlogMap[widget.category]![widget.id].category;

  @override
  void initState() {
    super.initState();
    descriptionTxtController.addListener(setDoneBtnState);
    setDoneBtnState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate!,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateTxtController.text = DateFormat.yMMMd().format(selectedDate!);
        //print(DateFormat.yMMMd().format(selectedDate));
      });
    }
  }

  void editBacklogItem() {
    PlannerService.sharedInstance.user.backlogMap[widget.category]![widget.id]
        .description = descriptionTxtController.text;
    PlannerService.sharedInstance.user.backlogMap[widget.category]![widget.id]
        .completeBy = selectedDate;
    PlannerService.sharedInstance.user.backlogMap[widget.category]![widget.id]
        .location = locationTxtController.text;
    PlannerService.sharedInstance.user.backlogMap[widget.category]![widget.id]
        .notes = notesTxtController.text;

    if (currChosenCategory !=
        PlannerService.sharedInstance.user
            .backlogMap[widget.category]![widget.id].category) {
      //category was changed
      var backlogItem = PlannerService
          .sharedInstance.user.backlogMap[widget.category]![widget.id];
      PlannerService.sharedInstance.user.backlogMap[widget.category]!
          .removeAt(widget.id); //delete from old category
      backlogItem.category = currChosenCategory;
      PlannerService.sharedInstance.user.backlogMap[currChosenCategory.name]!
          .add(backlogItem);
    } else {
      PlannerService.sharedInstance.user.backlogMap[widget.category]![widget.id]
          .category = currChosenCategory;
    }

    widget.updateBacklog();
    _backToBacklogPage();
  }

  void _backToBacklogPage() {
    Navigator.pop(context);
  }

  void setDoneBtnState() {
    if (descriptionTxtController.text != "") {
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
        title: Text("Edit Task"),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: doneBtnDisabled ? null : editBacklogItem,
            child: Text("Done"),
          ),
        ],
      ),
      body: Card(
        child: Container(
          child: ListView(
            children: [
              Image.asset(
                "assets/images/backlog_icon.png",
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
                          hintText: "What's the task?",
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
                          hintText: "Complete on or By (Optional)",
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
                        onChanged: (LifeCategory? newValue) {
                          setState(() {
                            currChosenCategory = newValue!;
                          });
                        },
                      ),
                      padding: EdgeInsets.all(20),
                    ),
                    Container(
                      child: TextFormField(
                        controller: locationTxtController,
                        decoration: InputDecoration(
                            hintText: "Location",
                            icon: Icon(
                              Icons.location_pin,
                              //color: Colors.pink,
                              color: Theme.of(context).colorScheme.primary,
                            )),
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
