import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/backlog_item.dart';
import '/services/planner_service.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({Key? key, required this.updateBacklog}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateBacklog;

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  var dateTxtController = TextEditingController();
  var descriptionTxtController = TextEditingController();
  var categoryTxtController = TextEditingController();
  var locationTxtController = TextEditingController();
  var notesTxtController = TextEditingController();
  bool doneBtnDisabled = true;

  @override
  void initState() {
    super.initState();
    dateTxtController.addListener(setDoneBtnState);
    descriptionTxtController.addListener(setDoneBtnState);
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

  void createBacklogItem() {
    var taskTitle = descriptionTxtController.text;
    // var goalDate = dateTxtController.text;
    var newBacklogItem = BacklogItem(
        taskTitle,
        selectedDate,
        false,
        categoryTxtController.text,
        locationTxtController.text,
        notesTxtController.text);
    if (newBacklogItem.category == "") {
      if (PlannerService.sharedInstance.user.backlog.containsKey("Other")) {
        PlannerService.sharedInstance.user.backlog["Other"].add(newBacklogItem);
      } else {
        PlannerService.sharedInstance.user.backlog["Other"] = [newBacklogItem];
      }
    } else {
      PlannerService.sharedInstance.user.backlog[newBacklogItem.category]
          .add(newBacklogItem);
    }
    widget.updateBacklog();
    _backToBacklogPage();
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

  void _backToBacklogPage() {
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
        title: Text("New Task"),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: doneBtnDisabled ? null : createBacklogItem,
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
                        decoration: const InputDecoration(
                          hintText: "Complete on or By (Optional)",
                          icon: Icon(
                            Icons.calendar_today,
                            color: Colors.pink,
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
                      child: TextFormField(
                        controller: categoryTxtController,
                        decoration: const InputDecoration(
                            hintText: "Life Category",
                            icon: Icon(
                              Icons.category_rounded,
                              color: Colors.pink,
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
                        controller: locationTxtController,
                        decoration: const InputDecoration(
                            hintText: "Location",
                            icon: Icon(
                              Icons.location_pin,
                              color: Colors.pink,
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
        color: Colors.pink.shade50,
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
