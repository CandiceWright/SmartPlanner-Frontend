import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:date_format/date_format.dart';
import '/models/event.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({Key? key, required this.updateEvents, required this.id})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateEvents;
  final int id;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late var selectedStartDate =
      PlannerService.sharedInstance.user.allEvents[widget.id].start;
  //DateTime selectedStartDate = DateTime.now();
  late var selectedStartTime =
      TimeOfDay(hour: selectedStartDate.hour, minute: selectedStartDate.minute);
  //TimeOfDay selectedStartTime = TimeOfDay(hour: 00, minute: 00);
  late var selectedEndDate =
      PlannerService.sharedInstance.user.allEvents[widget.id].end;
  //DateTime selectedEndDate = DateTime.now();
  late var selectedEndTime =
      TimeOfDay(hour: selectedEndDate.hour, minute: selectedEndDate.minute);
  //TimeOfDay selectedEndTime = TimeOfDay(hour: 00, minute: 00);
  late final startDateTxtController = TextEditingController(
      text: DateFormat.yMMMd().format(
          PlannerService.sharedInstance.user.allEvents[widget.id].start));
  late final endDateTxtController = TextEditingController(
      text: DateFormat.yMMMd()
          .format(PlannerService.sharedInstance.user.allEvents[widget.id].end));
  late final descriptionTxtController = TextEditingController(
      text: PlannerService.sharedInstance.user.allEvents[widget.id].eventName);
  late final notesTxtController = TextEditingController(
      text: PlannerService.sharedInstance.user.allEvents[widget.id].notes);
  late final categoryTxtController = TextEditingController(
      text: PlannerService.sharedInstance.user.allEvents[widget.id].category);
  late final startTimeController = TextEditingController(
      text: formatDate(
          PlannerService.sharedInstance.user.allEvents[widget.id].start,
          [hh, ':', nn, " ", am]).toString());
  late final endTimeController = TextEditingController(
      text: formatDate(
          PlannerService.sharedInstance.user.allEvents[widget.id].end,
          [hh, ':', nn, " ", am]).toString());
  late final locationTxController = TextEditingController(
      text: PlannerService.sharedInstance.user.allEvents[widget.id].location);
  bool doneBtnDisabled = false;

  @override
  void initState() {
    super.initState();
    startDateTxtController.addListener(setDoneBtnState);
    endDateTxtController.addListener(setDoneBtnState);
    descriptionTxtController.addListener(setDoneBtnState);
    setDoneBtnState();
    print("I am printing selected end datte");
    print(selectedEndDate);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedStartDate)
      setState(() {
        selectedStartDate = picked;
        startDateTxtController.text =
            DateFormat.yMMMd().format(selectedStartDate);
        //print(DateFormat.yMMMd().format(selectedDate));
      });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEndDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedEndDate)
      setState(() {
        selectedEndDate = picked;
        endDateTxtController.text = DateFormat.yMMMd().format(selectedEndDate);
        //print(DateFormat.yMMMd().format(selectedDate));
      });
  }

  Future<Null> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );
    if (picked != null) {
      setState(() {
        selectedStartTime = picked;
        String _hour = selectedStartTime.hour.toString();
        String _minute = selectedStartTime.minute.toString();
        String _time = _hour + ' : ' + _minute;
        startTimeController.text = _time;
        startTimeController.text = formatDate(
            DateTime(
                2019, 08, 1, selectedStartTime.hour, selectedStartTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
    }
  }

  Future<Null> _selectEndTime(BuildContext context) async {
    print(selectedEndTime);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );
    if (picked != null) {
      setState(() {
        selectedEndTime = picked;
        String _hour = selectedEndTime.hour.toString();
        String _minute = selectedEndTime.minute.toString();
        String _time = _hour + ' : ' + _minute;
        endTimeController.text = _time;
        endTimeController.text = formatDate(
            DateTime(2019, 08, 1, selectedEndTime.hour, selectedEndTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
    }
  }

  void createEvent() {
    PlannerService.sharedInstance.user.allEvents[widget.id].eventName =
        descriptionTxtController.text;
    PlannerService.sharedInstance.user.allEvents[widget.id].location =
        locationTxController.text;
    PlannerService.sharedInstance.user.allEvents[widget.id].notes =
        notesTxtController.text;
    PlannerService.sharedInstance.user.allEvents[widget.id].category =
        categoryTxtController.text;
    var startDateTime = DateTime(
        selectedStartDate.year,
        selectedStartDate.month,
        selectedStartDate.day,
        selectedStartTime.hour,
        selectedStartTime.minute,
        0);
    print("printing start selected");
    print(startDateTime);
    var endDateTime = DateTime(selectedEndDate.year, selectedEndDate.month,
        selectedEndDate.day, selectedEndTime.hour, selectedEndTime.minute, 0);
    print("printing end selected");
    print(endDateTime);
    PlannerService.sharedInstance.user.allEvents[widget.id].start =
        startDateTime;
    PlannerService.sharedInstance.user.allEvents[widget.id].end = endDateTime;

    widget.updateEvents();
    _backToEventsPage();
  }

  void setDoneBtnState() {
    print(descriptionTxtController.text);
    if (startDateTxtController.text != "" &&
        descriptionTxtController.text != "") {
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

  void _backToEventsPage() {
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
        title: Text("Edit Event"),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: doneBtnDisabled ? null : createEvent,
            child: Text("Done"),
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
                "assets/images/calendar_icon.png",
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
                          hintText: "What's the event?",
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
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            child: TextFormField(
                              controller: startDateTxtController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "Start Date",
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              onTap: () => _selectStartDate(context),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            padding: EdgeInsets.all(20),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            child: TextFormField(
                              controller: startTimeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "Time",
                                icon: Icon(
                                  Icons.timer,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              onTap: () => _selectStartTime(context),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            padding: EdgeInsets.all(20),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            child: TextFormField(
                              controller: endDateTxtController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "End Date",
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              onTap: () => _selectEndDate(context),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            padding: EdgeInsets.all(20),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            child: TextFormField(
                              controller: endTimeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "Time",
                                icon: Icon(
                                  Icons.timer,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              onTap: () => _selectEndTime(context),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            padding: EdgeInsets.all(20),
                          ),
                        )
                      ],
                    ),

                    // Container(
                    //   child: TextFormField(
                    //     controller: toDateTxtController,
                    //     readOnly: true,
                    //     decoration: const InputDecoration(
                    //       hintText: "To",
                    //       icon: Icon(
                    //         Icons.calendar_today,
                    //         color: Colors.pink,
                    //       ),
                    //     ),
                    //     onTap: () => _selectToDate(context),
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
                        controller: locationTxController,
                        decoration: InputDecoration(
                          hintText: "Location",
                          icon: Icon(
                            Icons.location_pin,
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
                      padding: EdgeInsets.all(20),
                    ),
                    Container(
                      child: TextFormField(
                        controller: categoryTxtController,
                        decoration: InputDecoration(
                            hintText: "Category",
                            icon: Icon(
                              Icons.category_rounded,
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
        //color: PlannerService.sharedInstance.user.theme.accentColor,
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
