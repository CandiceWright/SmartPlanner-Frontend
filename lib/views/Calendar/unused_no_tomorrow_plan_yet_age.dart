import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/views/Calendar/new_event_page.dart';
import 'package:practice_planner/views/Calendar/unused_tomorrow_planning_page.dart';
import '/services/planner_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'monthly_calendar_page.dart';
import 'edit_event_page.dart';
import '../../models/event.dart';
import '../../models/event_data_source.dart';

class NoTomorrowPlanYetPage extends StatefulWidget {
  const NoTomorrowPlanYetPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<NoTomorrowPlanYetPage> createState() => _NoTomorrowPlanYetPageState();
}

class _NoTomorrowPlanYetPageState extends State<NoTomorrowPlanYetPage> {
  //bool _value = false;
  //var backlog = PlannerService.sharedInstance.user.backlog;

  @override
  void initState() {
    super.initState();
    //print(PlannerService.sharedInstance.user.backlog);
  }

  void planTomorrow() {
    PlannerService.sharedInstance.user!.didStartTomorrowPlanning = true;
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const TomorrowPlanningPage();
      },
      settings: const RouteSettings(
        name: 'TomorrowPage',
      ),
    ));
    // Navigator.push(context,
    //     CupertinoPageRoute(builder: (context) => const TomorrowPlanningPage()));
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
            const Text("Tomorrow"),
            // Text(
            //   DateFormat.yMMMd().format(DateTime.now()),
            //   style: Theme.of(context).textTheme.subtitle1,
            // ),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
      ),
      body: Column(
        children: [
          const Text("How was your day today?"),
          //add an image here. Something happy. Maybe the journal has a similar character concept to that blob
          Padding(
            padding: EdgeInsets.all(12),
            child: const Text(
                "Before starting to plan tomorrow, remember to focus on today first! Make planning for tomorrow one of the last things to wrap up your day. And before planning for tomorrow, be sure to update your life backlog and mark any items you're done with as complete!"),
          ),
          ElevatedButton(
              onPressed: planTomorrow, child: const Text("Let's Plan Tomorrow"))
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
