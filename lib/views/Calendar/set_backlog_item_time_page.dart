import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/backlog_item.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';
import 'package:date_format/date_format.dart';

class SetBacklogItemTimePage extends StatefulWidget {
  const SetBacklogItemTimePage(
      {Key? key, required this.backlogItem, required this.updateTomorrowEvents})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final BacklogItem backlogItem;
  final Function updateTomorrowEvents;

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

  void _openNewCalendarItemPage() {
    //this function needs to change to create new goal
    DateTime start = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day + 1,
        selectedStartTime.hour,
        selectedStartTime.minute);
    DateTime end = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day + 1, selectedEndTime.hour, selectedEndTime.minute);
    var eventTitle = widget.backlogItem.description;
    var eventNotes = widget.backlogItem.notes;
    var category = widget.backlogItem.category;
    var eventLocation = widget.backlogItem.location;
    var newEvent = Event(
        id: PlannerService.sharedInstance.user.allEvents.length,
        eventName: eventTitle,
        type: "Calendar",
        start: start,
        end: end,
        background: const Color(0xFFFF80b1),
        isAllDay: false,
        notes: eventNotes,
        category: category,
        location: eventLocation);

    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: "NewEvent"),
        builder: (context) => NewEventPage(
          updateEvents: widget.updateTomorrowEvents,
          fromPage: "schedule_backlog_item",
          event: newEvent,
        ),
      ),
    );
    // Navigator.push(
    //     context,
    //     CupertinoPageRoute(
    //         builder: (context) => NewEventPage(
    //               updateEvents: _updateEvents,
    //               fromPage: "schedule_backlog_item",
    //               event: newEvent,
    //             )));
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
            builder: (context) =>
                EditEventPage(updateEvents: _updateEvents, id: id)));
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
            const Text("Select Time"),
            Text(
              widget.backlogItem.description,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            // Text(
            //   DateFormat.yMMMd().format(DateTime.now()),
            //   style: Theme.of(context).textTheme.subtitle1,
            // ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: doneBtnDisabled ? null : _openNewCalendarItemPage,
            child: const Text("Next"),
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
                initialDisplayDate: DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day + 1),
                dataSource: EventDataSource(
                    PlannerService.sharedInstance.user.allEvents),
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
