import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Calendar/today_schedule_page.dart';
import 'package:practice_planner/views/Inwards/inwards_page.dart';
import 'package:practice_planner/views/Subscription/subscription_page.dart';
import '../services/planner_service.dart';
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
class _NavigationWrapperState extends State<NavigationWrapper>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isInForeground = true;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    //CalendarPage(),
    TodaySchedulePage(),
    GoalsPage(),

    //DictionaryPage(),
    BacklogPage(),
    InwardsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    print("I am disposing navigation wrapper");
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
    if (_isInForeground) {
      print("app is in foreground");
      //PlannerService.subscriptionProvider.dispose();
      //PlannerService.subscriptionProvider = SubscriptionsProvider();
      //check to see if purchase is  still valid, if not, show an error
      bool isValid = true;
      for (int i = 0;
          i < PlannerService.subscriptionProvider.purchases.length;
          i++) {
        bool valid = await PlannerService.subscriptionProvider
            .verifyPurchase(PlannerService.subscriptionProvider.purchases[i]);
        if (!valid) {
          isValid = false;
        }
      }

      print(PlannerService.subscriptionProvider.purchaseError.value);
      print(PlannerService.subscriptionProvider.purchaseExpired.value);
      print(PlannerService.subscriptionProvider.purchasePending.value);
      print(PlannerService.subscriptionProvider.purchaseRestored.value);
      print(PlannerService.subscriptionProvider.purchaseSuccess.value);
      if (!isValid &&
          !(PlannerService.subscriptionProvider.purchaseError.value ||
              PlannerService.subscriptionProvider.purchaseExpired.value ||
              PlannerService.subscriptionProvider.purchasePending.value ||
              PlannerService.subscriptionProvider.purchaseRestored.value ||
              PlannerService.subscriptionProvider.purchaseSuccess.value)) {
        //if all are false, that means there is no purchase in progress
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    'Looks like your subscription has expired. Please choose a subscription plan.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return const SubscriptionPage(
                            fromPage: 'login',
                          );
                        },
                      ));
                    },
                  ),
                ],
              );
            });
      }
    }
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
            icon: Icon(Icons.list),
            label: 'Backlog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'The Cover',
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
