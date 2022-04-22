import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:practice_planner/models/life_category.dart';
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
  var goals = <Event>[];
  var accomplishedGoals = [];
  var backlogItems = <BacklogItem>[];
  //var backlogMap = <String, List<BacklogItem>>{};
  //var otherCategory = LifeCategory("Other", const Color(0xFFFF80b1));
  Map<String, List<BacklogItem>> backlogMap = {"Other": []};
  var todayTasks = [];
  var habits = <Habit>[];
  bool didStartTomorrowPlanning;
  var allEvents = <Event>[];
  var allEventsMap = <int, Event>{};
  var lifeCategories = <LifeCategory>[];
  Map<String, Color> LifeCategoriesColorMap = {
    // "Other": const Color(0xFFFF80b1)
  };

  User(
      {required this.name,
      required this.username,
      required this.password,
      required this.email,
      required this.theme,
      required this.themeId,
      this.profileImage,
      required this.didStartTomorrowPlanning,
      required this.lifeCategories}) {
    buildBacklogMap();
    buildHabitList();
    //buildEventList();
  }

  void buildBacklogMap() {
    print("I am building backlog");
    for (int i = 0; i < backlogItems.length; i++) {
      if (backlogMap.containsKey(backlogItems[i].category)) {
        backlogMap[backlogItems[i].category]!.add(backlogItems[i]);
      } else {
        backlogMap[backlogItems[i].category.name] = [backlogItems[i]];
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
    backlogMap.forEach((key, value) {
      for (int i = 0; i < value.length; i++) {
        print(value[i].completeBy);
        if (DateFormat.yMMMd().format(value[i].completeBy!) ==
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
        //id: 0,
        description: 'Conference',
        type: "Meeting",
        start: startTime,
        end: endTime,
        category: LifeCategory("All", const Color(0xFFFF80b1)),
        background: const Color(0xFFFF80b1),
        isAllDay: false));

    final DateTime startTime2 =
        DateTime(today.year, today.month, today.day + 1, 13, 0, 0);
    final DateTime endTime2 = startTime2.add(const Duration(hours: 2));
    allEvents.add(Event(
        //id: 1,
        description: 'Conference',
        type: "Calendar",
        start: startTime2,
        end: endTime2,
        background: const Color(0xFFFF80b1),
        category: LifeCategory("All", const Color(0xFFFF80b1)),
        isAllDay: false));
  }
}
