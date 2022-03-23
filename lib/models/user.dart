import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'goal.dart';
import 'backlog_item.dart';
import 'habit.dart';
import 'event.dart';
import 'package:flutter/material.dart';
import '/Themes/custom_theme.dart';

class User {
  var name;
  var username;
  var profileImage;
  var email;
  var password;
  CustomTheme theme;
  int themeId;
  var goals = [];
  var backlogItems = <BacklogItem>[];
  var backlog = new Map();
  var todayTasks = [];
  var habits = <Habit>[];
  bool didStartTomorrowPlanning;
  var allEvents = <Event>[];

  User(
      {required this.name,
      required this.username,
      required this.password,
      required this.email,
      required this.theme,
      required this.themeId,
      this.profileImage,
      required this.didStartTomorrowPlanning}) {
    //Goals
    //List<Goal> userGoals = [];
    Goal goal1 =
        Goal("100,000 planner subscriptions", DateTime(2022, 3, 11), "", "");
    Goal goal2 = Goal(
        "At least 1,000,000 in my bank accounts", DateTime(2022, 8, 2), "", "");
    goals.add(goal1);
    goals.add(goal2);

    //List<BacklogItem> backlogItems = [];
    BacklogItem bli1 = BacklogItem("Complete backlog feature.",
        DateTime(2022, 3, 6), false, "Planner Business");
    BacklogItem bli2 = BacklogItem(
        "Complete Homepage.", DateTime(2022, 3, 9), false, "Planner Business");
    BacklogItem bli3 = BacklogItem("Complete Calendar Feature.",
        DateTime(2022, 3, 6), false, "Planner Business");
    BacklogItem bli4 = BacklogItem("Complete assistant feature.",
        DateTime(2022, 3, 11), false, "Planner Business");
    BacklogItem bli5 = BacklogItem("Complete Server and connect to front end.",
        DateTime(2022, 3, 16), false, "Planner Business");
    BacklogItem bli6 =
        BacklogItem("Get nails done.", DateTime(2022, 3, 3), false, "Personal");
    BacklogItem bli7 =
        BacklogItem("Wash Clothes.", DateTime(2022, 3, 3), false, "Personal");

    backlogItems.add(bli1);
    backlogItems.add(bli2);
    backlogItems.add(bli3);
    backlogItems.add(bli4);
    backlogItems.add(bli5);
    backlogItems.add(bli6);
    backlogItems.add(bli7);

    print(backlogItems);

    buildBacklogMap();
    buildHabitList();
    buildEventList();
  }

  void buildBacklogMap() {
    print("I am building backlog");
    for (int i = 0; i < backlogItems.length; i++) {
      print("I am in for loop");
      print(backlogItems[i].category);
      if (backlogItems[i].category == "") {
        if (backlog.containsKey("Other")) {
          backlog["Other"].add(backlogItems[i]);
        } else {
          backlog["Other"] = [backlogItems[i]];
        }
      } else {
        if (backlog.containsKey(backlogItems[i].category)) {
          backlog[backlogItems[i].category].add(backlogItems[i]);
        } else {
          backlog[backlogItems[i].category] = [backlogItems[i]];
        }
      }
    }
    //print(backlog);
    buildTodayTaskList();
    //return backlog;
  }

  void buildTodayTaskList() {
    print("I am building task list for today");
    print("printing current date");
    print(DateFormat.yMMMd().format(DateTime.now()));
    backlog.forEach((key, value) {
      for (int i = 0; i < value.length; i++) {
        print(value[i].completeBy);
        if (DateFormat.yMMMd().format(value[i].completeBy) ==
            DateFormat.yMMMd().format(DateTime.now())) {
          todayTasks.add(value[i]);
        }
      }
    });
    print(todayTasks.length);
  }

  void buildHabitList() {
    Habit habit1 = Habit("Pray daily");
    Habit habit2 = Habit("Code daily");
    Habit habit3 = Habit("Workout for 30min daily");

    habits.add(habit1);
    habits.add(habit2);
    habits.add(habit3);
  }

  void buildEventList() {
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    allEvents.add(Event(
        id: 0,
        eventName: 'Conference',
        type: "Meeting",
        start: startTime,
        end: endTime,
        background: const Color(0xFFFF80b1),
        isAllDay: false));

    final DateTime startTime2 =
        DateTime(today.year, today.month, today.day + 1, 13, 0, 0);
    final DateTime endTime2 = startTime2.add(const Duration(hours: 2));
    allEvents.add(Event(
        id: 1,
        eventName: 'Conference',
        type: "Calendar",
        start: startTime2,
        end: endTime2,
        background: const Color(0xFFFF80b1),
        isAllDay: false));
  }
}
