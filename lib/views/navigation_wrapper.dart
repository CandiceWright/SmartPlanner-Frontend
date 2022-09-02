import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
    //print("I am disposing navigation wrapper");
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
    if (_isInForeground &&
        !PlannerService.subscriptionProvider.purchaseInProgress) {
      //print("app is in foreground");

      //check to see if purchase is  still valid, if not, show an error
      //print("printing receipt line 69");
      //print(PlannerService.sharedInstance.user!.receipt);
      String receiptStatus = await PlannerService.subscriptionProvider
          .verifyPurchase(PlannerService.sharedInstance.user!.receipt);

      if (receiptStatus == "expired") {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(
                  'Looks like your subscription has expired. Resubscribe to access your planit..'),
              actions: <Widget>[
                TextButton(
                  child: Text('Ok, Resubscribe'),
                  onPressed: () async {
                    //get subscription products
                    List<ProductDetails> productDetails = await PlannerService
                        .subscriptionProvider
                        .fetchSubscriptions();

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return SubscriptionPage(
                          fromPage: 'login',
                          products: productDetails,
                        );
                      },
                    ));
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) {
                    //     return const SubscriptionPage(
                    //       fromPage: 'login',
                    //     );
                    //   },
                    // ));
                  },
                ),
              ],
            );
          },
        );
      } else if (receiptStatus == "error") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                  'Oops! Looks like something went wrong. Please try again.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } else {
        //print("in navigation wrapper the purchase is good");
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
