import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/views/Calendar/today_schedule_page.dart';
import 'package:practice_planner/views/Inwards/inwards_page.dart';
import '/views/Goals/goals_page.dart';
import '/views/Home/home_page.dart';
import '/views/Calendar/calendar_page.dart';
// import '/views/Backlog/backlog_page.dart';
//import '/views/Calendar/updated_calendar_page.dart';
import '/views/Backlog/updated_backlog_page.dart';

import 'Dictionary/dictionary.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({Key? key}) : super(key: key);

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

//The widget can be recreated, but the state is attached to the user interface
class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    //CalendarPage(),
    TodaySchedulePage(),
    GoalsPage(),

    //DictionaryPage(),
    InwardsPage(),
    BacklogPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //MaterialApp is a flutter class which has a constructor

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_outlined),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'The Cover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Backlog',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
      //home: Text('hello world'),
    );
  }
}
