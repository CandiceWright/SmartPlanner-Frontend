//part of event_calendar;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/event_data_source.dart';
import 'package:practice_planner/models/life_category.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'calendar_page.dart';
import '/models/goal.dart';
import '/services/planner_service.dart';
import 'package:date_format/date_format.dart';
import '/models/event.dart';
import 'package:http/http.dart' as http;

//import 'package:calendar_page.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage(
      {Key? key,
      required this.updateEvents,
      //required this.id,
      this.selectedEvent,
      this.dataSource})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Function updateEvents;
  //final int id;
  final Event? selectedEvent;
  final EventDataSource? dataSource;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late var selectedStartDate = CalendarPage.selectedEvent!.start;

  late var selectedStartTime =
      TimeOfDay(hour: selectedStartDate.hour, minute: selectedStartDate.minute);

  late var selectedEndDate = CalendarPage.selectedEvent!.end;

  late var selectedEndTime =
      TimeOfDay(hour: selectedEndDate.hour, minute: selectedEndDate.minute);

  late final startDateTxtController =
      TextEditingController(text: DateFormat.yMMMd().format(selectedStartDate));
  late final endDateTxtController =
      TextEditingController(text: DateFormat.yMMMd().format(selectedEndDate));

  late final descriptionTxtController =
      TextEditingController(text: CalendarPage.selectedEvent!.description);
  late final notesTxtController =
      TextEditingController(text: CalendarPage.selectedEvent!.notes);

  late final startTimeController = TextEditingController(
      text: formatDate(selectedStartDate, [hh, ':', nn, " ", am]).toString());
  late final endTimeController = TextEditingController(
      text: formatDate(selectedEndDate, [hh, ':', nn, " ", am]).toString());
  late final locationTxController =
      TextEditingController(text: CalendarPage.selectedEvent!.location);
  bool doneBtnDisabled = false;
  late LifeCategory currChosenCategory = CalendarPage.selectedEvent!.category;

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
    // final DateTime? picked = await showDatePicker(
    //     context: context,
    //     initialDate: selectedStartDate,
    //     firstDate: DateTime(2015, 8),
    //     lastDate: DateTime(2101));
    // if (picked != null && picked != selectedStartDate)
    //   setState(() {
    //     selectedStartDate = picked;
    //     startDateTxtController.text =
    //         DateFormat.yMMMd().format(selectedStartDate);
    //     //print(DateFormat.yMMMd().format(selectedDate));
    //   });
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
    // final DateTime? picked = await showDatePicker(
    //     context: context,
    //     initialDate: selectedEndDate,
    //     firstDate: DateTime(2015, 8),
    //     lastDate: DateTime(2101));
    // if (picked != null && picked != selectedEndDate)
    //   setState(() {
    //     selectedEndDate = picked;
    //     endDateTxtController.text = DateFormat.yMMMd().format(selectedEndDate);
    //     //print(DateFormat.yMMMd().format(selectedDate));
    //   });
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

  void editEvent() async {
    final List<Event> events = <Event>[];
    var eventTitle = descriptionTxtController.text;
    var eventNotes = notesTxtController.text;
    //var category = categoryTxtController.text;
    var eventLocation = locationTxController.text;

    var startDateTime = DateTime(
        selectedStartDate.year,
        selectedStartDate.month,
        selectedStartDate.day,
        selectedStartTime.hour,
        selectedStartTime.minute);
    var endDateTime = DateTime(selectedEndDate.year, selectedEndDate.month,
        selectedEndDate.day, selectedEndTime.hour, selectedEndTime.minute);
    if (CalendarPage.selectedEvent != null) {
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
        //make call to server

        var body = {
          'eventId': CalendarPage.selectedEvent!.id,
          'description': eventTitle,
          'type': "calendar",
          'start': startDateTime.toString(),
          'end': endDateTime.toString(),
          'notes': eventNotes,
          'category': currChosenCategory.id,
          'location': eventLocation,
          'isAllDay': true
        };
        String bodyF = jsonEncode(body);
        print(bodyF);

        var url = Uri.parse('http://localhost:7343/calendar');
        var response = await http.patch(url,
            headers: {"Content-Type": "application/json"}, body: bodyF);
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          CalendarPage.events.appointments!.removeAt(CalendarPage
              .events.appointments!
              .indexOf(CalendarPage.selectedEvent));
          CalendarPage.events.notifyListeners(CalendarDataSourceAction.remove,
              <Event>[]..add(CalendarPage.selectedEvent!));

          //int id = PlannerService.sharedInstance.user.allEvents.length;
          var newEvent = Event(
            id: CalendarPage.selectedEvent!.id,
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
        title: Text("Edit"),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: doneBtnDisabled ? null : editEvent,
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
                      child: DropdownButton(
                        //value: PlannerService.sharedInstance.user.theme.themeId,
                        value: currChosenCategory,
                        items: List.generate(
                            PlannerService.sharedInstance.user!.lifeCategories
                                .length, (int index) {
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

                        onChanged: (LifeCategory? newValue) {
                          // onChanged: (newValue) {
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
