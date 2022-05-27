import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/backlog_item.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:practice_planner/views/Calendar/tomorrow_planning_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:date_format/date_format.dart';
import '/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'calendar_page.dart';

class NewEventPage extends StatefulWidget {
  const NewEventPage(
      {Key? key,
      required this.updateEvents,
      required this.fromPage,
      this.event,
      this.backlogMapRef})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateEvents;
  final String fromPage;
  final Event? event;
  final BacklogMapRef? backlogMapRef;

  @override
  State<NewEventPage> createState() => _NewGoalPageState();
}

class _NewGoalPageState extends State<NewEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime selectedStartDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay(hour: 00, minute: 00);
  //DateTime selectedEndDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  TimeOfDay selectedEndTime = TimeOfDay(hour: 00, minute: 00);
  var startDateTxtController = TextEditingController();
  var endDateTxtController = TextEditingController();
  var descriptionTxtController = TextEditingController();
  var notesTxtController = TextEditingController();
  //var categoryTxtController = TextEditingController();
  var locationTxtController = TextEditingController();
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();
  var currChosenCategory =
      PlannerService.sharedInstance.user!.lifeCategories[0];

  bool doneBtnDisabled = true;

  @override
  void initState() {
    super.initState();
    startDateTxtController.addListener(setDoneBtnState);
    endDateTxtController.addListener(setDoneBtnState);
    startTimeController.addListener(setDoneBtnState);
    endTimeController.addListener(setDoneBtnState);
    descriptionTxtController.addListener(setDoneBtnState);
    if (widget.fromPage == "tomorrow") {
      DateTime tomorrow = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
      startDateTxtController.text = DateFormat.yMMMd().format(tomorrow);
      endDateTxtController.text = DateFormat.yMMMd().format(tomorrow);
      selectedStartDate = tomorrow;
      selectedEndDate = tomorrow;
    }

    setDoneBtnState();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    //lastDate: selectedEndDate);
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
        startDateTxtController.text =
            DateFormat.yMMMd().format(selectedStartDate);
        if (selectedStartDate.compareTo(selectedEndDate) > 0) {
          //startTime is after
          selectedEndDate = selectedStartDate;
          endDateTxtController.text =
              DateFormat.yMMMd().format(selectedEndDate);
        }
        //print(DateFormat.yMMMd().format(selectedDate));
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEndDate,
        //firstDate: DateTime(2015, 8),
        firstDate: selectedStartDate,
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
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        //initialTime: selectedEndTime,
        initialTime: selectedStartTime);
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

  _backToTomorrowPage() {
    //Navigator.popUntil(context, (route) => route.isFirst);
    //Navigator.popUntil(context, ModalRoute.withName('/tomorrow'));
    Navigator.of(context).popUntil((route) {
      return route.settings.name == 'TomorrowPage';
    });
  }

  void createEvent() async {
    final List<Event> events = <Event>[];
    //I'm nott sure why I added he code below so I commented out for now
    // if (CalendarPage.selectedEvent != null) {
    //   CalendarPage.events.appointments!.removeAt(CalendarPage
    //       .events.appointments!
    //       .indexOf(CalendarPage.selectedEvent));
    //   CalendarPage.events.notifyListeners(CalendarDataSourceAction.remove,
    //       <Event>[]..add(CalendarPage.selectedEvent!));
    // }
    var startDateTime = DateTime(
        selectedStartDate.year,
        selectedStartDate.month,
        selectedStartDate.day,
        selectedStartTime.hour,
        selectedStartTime.minute);
    var endDateTime = DateTime(selectedEndDate.year, selectedEndDate.month,
        selectedEndDate.day, selectedEndTime.hour, selectedEndTime.minute);

    if (startDateTime.compareTo(endDateTime) > 0) {
      //startDate is after end date which can't happen
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Fix Dates"),
              content: Text("Start date must be before end date."),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok'))
              ],
            );
          });
    } else {
      //first send request to create new event on server
      var eventTitle = descriptionTxtController.text;
      var eventNotes = notesTxtController.text;
      var eventLocation = locationTxtController.text;
      var body = {
        'userId': PlannerService.sharedInstance.user!.id,
        'description': eventTitle,
        'type': "goal",
        'start': startDateTime.toString(),
        'end': endDateTime.toString(),
        'notes': eventNotes,
        'category': currChosenCategory.id,
        'location': eventLocation,
        'isAllDay': true
      };
      String bodyF = jsonEncode(body);
      print(bodyF);

      var url = Uri.parse('http://10.71.8.85:7343/calendar');
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var decodedBody = json.decode(response.body);
        print(decodedBody);
        var id = decodedBody["insertId"];
        var newEvent = Event(
          id: id,
          description: eventTitle,
          type: "calendar",
          start: startDateTime,
          end: endDateTime,
          //background: const Color(0xFFFF80b1),
          background: currChosenCategory.color,
          isAllDay: false,
          notes: eventNotes,
          category: currChosenCategory,
          location: eventLocation,
        );

        events.add(newEvent);

        CalendarPage.events.appointments!.add(events[0]);

        CalendarPage.events
            .notifyListeners(CalendarDataSourceAction.add, events);
        PlannerService.sharedInstance.user!.scheduledEvents =
            CalendarPage.events.appointments! as List<Event>;

        CalendarPage.selectedEvent = null;

        _backToEventsPage();
      } else {
        //500 error, show an alert

      }
    }
  }

  void setDoneBtnState() {
    print(descriptionTxtController.text);
    if (startDateTxtController.text != "" &&
        endDateTxtController.text != "" &&
        startTimeController.text != "" &&
        endTimeController.text != "" &&
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
            title: const Text(
              "New Event",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            //leading: BackButton(color: Colors.black),
            actions: [
              TextButton(
                onPressed: doneBtnDisabled ? null : createEvent,
                child: const Text(
                  "Done",

                  ///style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Card(
            child: Container(
              child: ListView(
                children: [
                  // Image.asset(
                  //   "assets/images/calendar_icon.png",
                  //   height: 80,
                  //   width: 80,
                  // ),
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  onTap: () => {
                                    if (widget.fromPage != "tomorrow" &&
                                        widget.fromPage !=
                                            "schedule_backlog_item")
                                      {_selectStartDate(context)}
                                  },
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  onTap: () => {
                                    if (widget.fromPage != "tomorrow")
                                      {_selectEndDate(context)}
                                  },
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                        Container(
                          child: TextFormField(
                            controller: locationTxtController,
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
                          child: DropdownButton(
                            //value: PlannerService.sharedInstance.user.theme.themeId,
                            value: currChosenCategory,
                            items: List.generate(
                                PlannerService.sharedInstance.user!
                                    .lifeCategories.length, (int index) {
                              return DropdownMenuItem(
                                //value: "pink",
                                value: PlannerService
                                    .sharedInstance.user!.lifeCategories[index],
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: PlannerService.sharedInstance.user!
                                          .lifeCategories[index].color,
                                    ),
                                    Text(PlannerService.sharedInstance.user!
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
            margin: EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        )
      ],
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     // Here we take the value from the MyHomePage object that was created by
    //     // the App.build method, and use it to set our appbar title.
    //     title: Text("New Event"),
    //     centerTitle: true,
    //     leading: BackButton(color: Colors.black),
    //     actions: [
    //       TextButton(
    //         onPressed: doneBtnDisabled ? null : createEvent,
    //         child: Text("Done"),
    //       ),
    //     ],
    //   ),
    //   body: Card(
    //     child: Container(
    //       child: ListView(
    //         children: [
    //           // Image.asset(
    //           //   "assets/images/calendar_icon.png",
    //           //   height: 80,
    //           //   width: 80,
    //           // ),
    //           Form(
    //             key: _formKey,
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 Container(
    //                   child: TextFormField(
    //                     controller: descriptionTxtController,
    //                     decoration: const InputDecoration(
    //                       hintText: "What's the event?",
    //                     ),
    //                     validator: (String? value) {
    //                       if (value == null || value.isEmpty) {
    //                         return 'Please enter some text';
    //                       }
    //                       return null;
    //                     },
    //                   ),
    //                   padding: EdgeInsets.all(20),
    //                 ),
    //                 Row(
    //                   children: [
    //                     Flexible(
    //                       child: Padding(
    //                         child: TextFormField(
    //                           controller: startDateTxtController,
    //                           readOnly: true,
    //                           decoration: InputDecoration(
    //                             hintText: "Start Date",
    //                             icon: Icon(
    //                               Icons.calendar_today,
    //                               color: Theme.of(context).colorScheme.primary,
    //                             ),
    //                           ),
    //                           onTap: () => {
    //                             if (widget.fromPage != "tomorrow" &&
    //                                 widget.fromPage != "schedule_backlog_item")
    //                               {_selectStartDate(context)}
    //                           },
    //                           validator: (String? value) {
    //                             if (value == null || value.isEmpty) {
    //                               return 'Please enter some text';
    //                             }
    //                             return null;
    //                           },
    //                         ),
    //                         padding: EdgeInsets.all(20),
    //                       ),
    //                     ),
    //                     Flexible(
    //                       child: Padding(
    //                         child: TextFormField(
    //                           controller: startTimeController,
    //                           readOnly: true,
    //                           decoration: InputDecoration(
    //                             hintText: "Time",
    //                             icon: Icon(
    //                               Icons.timer,
    //                               color: Theme.of(context).colorScheme.primary,
    //                             ),
    //                           ),
    //                           onTap: () => _selectStartTime(context),
    //                           validator: (String? value) {
    //                             if (value == null || value.isEmpty) {
    //                               return 'Please enter some text';
    //                             }
    //                             return null;
    //                           },
    //                         ),
    //                         padding: EdgeInsets.all(20),
    //                       ),
    //                     )
    //                   ],
    //                 ),
    //                 Row(
    //                   children: [
    //                     Flexible(
    //                       child: Padding(
    //                         child: TextFormField(
    //                           controller: endDateTxtController,
    //                           readOnly: true,
    //                           decoration: InputDecoration(
    //                             hintText: "End Date",
    //                             icon: Icon(
    //                               Icons.calendar_today,
    //                               color: Theme.of(context).colorScheme.primary,
    //                             ),
    //                           ),
    //                           onTap: () => {
    //                             if (widget.fromPage != "tomorrow")
    //                               {_selectEndDate(context)}
    //                           },
    //                           validator: (String? value) {
    //                             if (value == null || value.isEmpty) {
    //                               return 'Please enter some text';
    //                             }
    //                             return null;
    //                           },
    //                         ),
    //                         padding: EdgeInsets.all(20),
    //                       ),
    //                     ),
    //                     Flexible(
    //                       child: Padding(
    //                         child: TextFormField(
    //                           controller: endTimeController,
    //                           readOnly: true,
    //                           decoration: InputDecoration(
    //                             hintText: "Time",
    //                             icon: Icon(
    //                               Icons.timer,
    //                               color: Theme.of(context).colorScheme.primary,
    //                             ),
    //                           ),
    //                           onTap: () => _selectEndTime(context),
    //                           validator: (String? value) {
    //                             if (value == null || value.isEmpty) {
    //                               return 'Please enter some text';
    //                             }
    //                             return null;
    //                           },
    //                         ),
    //                         padding: EdgeInsets.all(20),
    //                       ),
    //                     )
    //                   ],
    //                 ),
    //                 Container(
    //                   child: TextFormField(
    //                     controller: locationTxtController,
    //                     decoration: InputDecoration(
    //                       hintText: "Location",
    //                       icon: Icon(
    //                         Icons.location_pin,
    //                         color: Theme.of(context).colorScheme.primary,
    //                       ),
    //                     ),
    //                     validator: (String? value) {
    //                       if (value == null || value.isEmpty) {
    //                         return 'Please enter some text';
    //                       }
    //                       return null;
    //                     },
    //                   ),
    //                   padding: EdgeInsets.all(20),
    //                 ),
    //                 Container(
    //                   child: DropdownButton(
    //                     //value: PlannerService.sharedInstance.user.theme.themeId,
    //                     value: currChosenCategory,
    //                     items: List.generate(
    //                         PlannerService.sharedInstance.user.lifeCategories
    //                             .length, (int index) {
    //                       return DropdownMenuItem(
    //                         //value: "pink",
    //                         value: PlannerService
    //                             .sharedInstance.user.lifeCategories[index],
    //                         child: Row(
    //                           children: [
    //                             Icon(
    //                               Icons.circle,
    //                               color: PlannerService.sharedInstance.user
    //                                   .lifeCategories[index].color,
    //                             ),
    //                             Text(PlannerService.sharedInstance.user
    //                                 .lifeCategories[index].name),
    //                           ],
    //                         ),
    //                       );
    //                     }),

    //                     // onChanged: (String? newValue) {
    //                     onChanged: (LifeCategory? newValue) {
    //                       setState(() {
    //                         currChosenCategory = newValue!;
    //                       });
    //                     },
    //                   ),
    //                   padding: EdgeInsets.all(20),
    //                 ),
    //                 Container(
    //                   child: TextFormField(
    //                     controller: notesTxtController,
    //                     decoration: const InputDecoration(
    //                       hintText: "Notes",
    //                       fillColor: Colors.white,
    //                     ),
    //                     validator: (String? value) {
    //                       if (value == null || value.isEmpty) {
    //                         return 'Please enter some text';
    //                       }
    //                       return null;
    //                     },
    //                     maxLines: null,
    //                     minLines: 10,
    //                   ),
    //                   padding: EdgeInsets.all(20),
    //                   margin: EdgeInsets.only(top: 10),
    //                   decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(8.0),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           )
    //         ],
    //       ),
    //       margin: EdgeInsets.all(15),
    //     ),
    //     margin: EdgeInsets.only(top: 15, bottom: 40, left: 15, right: 15),
    //     elevation: 5,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(10.0),
    //     ),
    //   ),
    // );
  }
}
