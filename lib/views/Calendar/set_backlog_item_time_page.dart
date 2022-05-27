import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/backlog_item.dart';
import 'package:practice_planner/models/backlog_map_ref.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'calendar_page.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;

class SetBacklogItemTimePage extends StatefulWidget {
  const SetBacklogItemTimePage(
      {Key? key,
      required this.backlogItem,
      required this.updateEvents,
      required this.bmRef,
      required this.fromPage})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final BacklogItem backlogItem;
  final Function updateEvents;
  final BacklogMapRef bmRef;
  final String fromPage;

  @override
  State<SetBacklogItemTimePage> createState() => _SetBacklogItemTimePageState();
}

class _SetBacklogItemTimePageState extends State<SetBacklogItemTimePage> {
  //bool _value = false;
  //var backlog = PlannerService.sharedInstance.user.backlog;
  TimeOfDay selectedStartTime = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedEndTime = TimeOfDay(hour: 00, minute: 00);
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();
  bool doneBtnDisabled = true;

  @override
  void initState() {
    super.initState();
    //print(PlannerService.sharedInstance.user.backlog);
    startTimeController.addListener(setDoneBtnState);
    endTimeController.addListener(setDoneBtnState);
  }

  void _saveNewCalendarItem() async {
    final List<Event> events = <Event>[];

    DateTime startDateTime;
    DateTime endDateTime;
    if (widget.fromPage == "tomorrow") {
      startDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 1,
          selectedStartTime.hour,
          selectedStartTime.minute);
      endDateTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, selectedEndTime.hour, selectedEndTime.minute);
      if (startDateTime.compareTo(endDateTime) > 0) {
        //startDate is after end date which can't happen
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Fix Time"),
                content: Text("Start time must be before end time."),
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
        //first create a new event by calling server
        var eventTitle = widget.backlogItem.description;
        var eventNotes = widget.backlogItem.notes;
        var category = widget.backlogItem.category;
        var eventLocation = widget.backlogItem.location;
        var body = {
          'userId': PlannerService.sharedInstance.user!.id,
          'description': eventTitle,
          'type': "calendar",
          'start': startDateTime.toString(),
          'end': endDateTime.toString(),
          'notes': eventNotes,
          'category': category.id,
          'location': eventLocation,
          'isAllDay': false,
          'backlogItemRef': widget.backlogItem.id
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

          //update task with event id and scheduled date (call schedule task server route)
          var body = {
            'taskId': widget.backlogItem.id,
            'calendarRefId': id,
            'scheduledDate': startDateTime.toString(),
          };
          String bodyF = jsonEncode(body);
          print(bodyF);

          var url = Uri.parse('http://10.71.8.85:7343/backlog/schedule');
          var response2 = await http.patch(url,
              headers: {"Content-Type": "application/json"}, body: bodyF);
          print('Response status: ${response2.statusCode}');
          print('Response body: ${response2.body}');

          if (response2.statusCode == 200) {
            var newEvent = Event(
                id: id,
                //id: PlannerService.sharedInstance.user.allEvents.length,
                taskIdRef: widget.backlogItem.id,
                description: eventTitle,
                type: "backlog",
                start: startDateTime,
                end: endDateTime,
                background: widget.backlogItem.category.color,
                isAllDay: false,
                notes: eventNotes,
                category: category,
                location: eventLocation,
                backlogMapRef: widget.bmRef);

            //PlannerService.sharedInstance.user.allEvents.add(newEvent);
            events.add(newEvent);

            CalendarPage.events.appointments!.add(events[0]);

            CalendarPage.events
                .notifyListeners(CalendarDataSourceAction.add, events);
            PlannerService.sharedInstance.user!.scheduledEvents =
                CalendarPage.events.appointments! as List<Event>;

            PlannerService
                .sharedInstance
                .user!
                .backlogMap[widget.bmRef.categoryName]![widget.bmRef.arrayIdx]
                .scheduledDate = startDateTime;
            PlannerService
                .sharedInstance
                .user!
                .backlogMap[widget.bmRef.categoryName]![widget.bmRef.arrayIdx]
                .calendarItemRef = newEvent;

            CalendarPage.selectedEvent = null;
            widget.updateEvents();
            Navigator.of(context).popUntil((route) {
              return route.settings.name == 'TomorrowPage';
            });
          } else {
            //500 error, show an alert

          }
        } else {
          //500 error, show an alert

        }

        //next get that new event id and update task with scheduled date and event id for calendar item
      }
    } else {
      startDateTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, selectedStartTime.hour, selectedStartTime.minute);
      endDateTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, selectedEndTime.hour, selectedEndTime.minute);
      if (startDateTime.compareTo(endDateTime) > 0) {
        //startDate is after end date which can't happen
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Fix Time"),
                content: Text("Start time must be before end time."),
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
        //first create a new event by calling server
        var eventTitle = widget.backlogItem.description;
        var eventNotes = widget.backlogItem.notes;
        var category = widget.backlogItem.category;
        var eventLocation = widget.backlogItem.location;
        var body = {
          'userId': PlannerService.sharedInstance.user!.id,
          'description': eventTitle,
          'type': "calendar",
          'start': startDateTime.toString(),
          'end': endDateTime.toString(),
          'notes': eventNotes,
          'category': category.id,
          'location': eventLocation,
          'isAllDay': false,
          'backlogItemRef': widget.backlogItem.id
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

          //update task with event id and scheduled date (call schedule task server route)
          var body = {
            'taskId': widget.backlogItem.id,
            'calendarRefId': id,
            'scheduledDate': startDateTime.toString(),
          };
          String bodyF = jsonEncode(body);
          print(bodyF);

          var url = Uri.parse('http://10.71.8.85:7343/backlog/schedule');
          var response2 = await http.patch(url,
              headers: {"Content-Type": "application/json"}, body: bodyF);
          print('Response status: ${response2.statusCode}');
          print('Response body: ${response2.body}');

          if (response2.statusCode == 200) {
            var newEvent = Event(
                id: id,
                //id: PlannerService.sharedInstance.user.allEvents.length,
                taskIdRef: widget.backlogItem.id,
                description: eventTitle,
                type: "backlog",
                start: startDateTime,
                end: endDateTime,
                background: widget.backlogItem.category.color,
                isAllDay: false,
                notes: eventNotes,
                category: category,
                location: eventLocation,
                backlogMapRef: widget.bmRef);

            //PlannerService.sharedInstance.user.allEvents.add(newEvent);
            events.add(newEvent);

            CalendarPage.events.appointments!.add(events[0]);

            CalendarPage.events
                .notifyListeners(CalendarDataSourceAction.add, events);
            PlannerService.sharedInstance.user!.scheduledEvents =
                CalendarPage.events.appointments! as List<Event>;

            //update backlog task
            PlannerService
                .sharedInstance
                .user!
                .backlogMap[widget.bmRef.categoryName]![widget.bmRef.arrayIdx]
                .scheduledDate = startDateTime;
            PlannerService
                .sharedInstance
                .user!
                .backlogMap[widget.bmRef.categoryName]![widget.bmRef.arrayIdx]
                .calendarItemRef = newEvent;

            CalendarPage.selectedEvent = null;
            widget.updateEvents();
            Navigator.of(context).popUntil((route) {
              return route.settings.name == 'navigaionPage';
            });
          } else {
            //500 error, show an alert

          }
        } else {
          //500 error, show an alert

        }

        //next get that new event id and update task with scheduled date and event id for calendar item
      }
    }
  }

  void setDoneBtnState() {
    if (startTimeController.text != "" && endTimeController.text != "") {
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

  void openEditEventPage(int id) {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditEventPage(
                  updateEvents: _updateEvents,
                )));
  }

  void _goToMonthlyView() {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const MonthlyCalendarPage()));
  }

  void _updateEvents() {
    setState(() {});
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
        title: Column(
          children: [
            const Text(
              "Select Time",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              widget.backlogItem.description,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle2!.fontSize,
                  color: Colors.white),
            ),
            // Text(
            //   DateFormat.yMMMd().format(DateTime.now()),
            //   style: Theme.of(context).textTheme.subtitle1,
            // ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/images/login_screens_background.png",
                  ),
                  fit: BoxFit.fill)),
        ),
        actions: [
          TextButton(
            onPressed: doneBtnDisabled ? null : _saveNewCalendarItem,
            child: const Text("Ok"),
          ),
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),
      body:
          //Column(
          //children: [
          //Text(widget.backlogItem.description),
          Container(
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Padding(
                    child: TextFormField(
                      controller: startTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Start",
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
                ),
                Flexible(
                  child: Padding(
                    child: TextFormField(
                      controller: endTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "End",
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
            Expanded(
              child: SfCalendar(
                view: CalendarView.day,
                //onTap: calendarTapped,
                initialDisplayDate: widget.fromPage == "tomorrow"
                    ? DateTime(DateTime.now().year, DateTime.now().month,
                        DateTime.now().day + 1)
                    : DateTime(DateTime.now().year, DateTime.now().month,
                        DateTime.now().day),
                dataSource: EventDataSource(
                    PlannerService.sharedInstance.user!.scheduledEvents),
              ),
            )
          ],
        ),
      ),
      // ],
      //),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
