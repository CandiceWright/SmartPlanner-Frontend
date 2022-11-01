import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Calendar/today_page.dart';
import 'package:practice_planner/views/Calendar/today_schedule_page.dart';
import 'package:practice_planner/views/Inwards/inwards_page.dart';
import 'package:practice_planner/views/Subscription/subscription_page.dart';
import 'package:practice_planner/views/Subscription/subscription_page_no_free_trial.dart';
import '../services/planner_service.dart';
import '/views/Goals/goals_page.dart';
import '/views/Home/home_page.dart';
import '/views/Calendar/calendar_page.dart';
// import '/views/Backlog/backlog_page.dart';
//import '/views/Calendar/updated_calendar_page.dart';
import '/views/Backlog/updated_backlog_page.dart';
import 'package:http/http.dart' as http;

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
    BacklogPage(),
    TodayPage(),
    CalendarPage(),

    //CalendarPage(),
    GoalsPage(),
    //DictionaryPage(),
    //InwardsPage(),
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
      if (PlannerService.sharedInstance.user!.isPremiumUser!) {
        //check to see if purchase is  still valid, if not, show an error
        var receipt = PlannerService.sharedInstance.user!.receipt;

        print("I am in nav wrapper and user has a receipt to verify");
        //check to make sure their subscription is valid before you let them into planit
        //validate receipt
        String receiptStatus =
            await PlannerService.subscriptionProvider.verifyPurchase(receipt);

        if (receiptStatus == "expired") {
          //either receipt is expired or need to be restored

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text(
                    'Looks like your subscription has expired. Resubscribe to access your planit.'),
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
                          return SubscriptionPageNoTrial(
                              fromPage: 'login', products: productDetails);
                        },
                      ));
                    },
                  ),
                  TextButton(
                    child: Text(
                      "Use Basic",
                      style: TextStyle(color: Colors.grey),
                    ),
                    onPressed: () {
                      //show a dialogag asking if theyre sure
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Are you sure?'),
                              content: Text(
                                  "If you choose to use the basic version, you will not have access to premium features or any of your content associated with such features."),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Yes, use Basic',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  onPressed: () async {
                                    PlannerService.sharedInstance.user!
                                        .isPremiumUser = false;
                                    //update isPremium on server
                                    var body = {
                                      'user': PlannerService
                                          .sharedInstance.user!.id,
                                      'isPremium': PlannerService
                                          .sharedInstance.user!.isPremiumUser,
                                    };
                                    String bodyF = jsonEncode(body);
                                    //print(bodyF);

                                    var url = Uri.parse(PlannerService
                                            .sharedInstance.serverUrl +
                                        '/user/premium');
                                    var response = await http.patch(url,
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                        body: bodyF);
                                    //print('Response status: ${response.statusCode}');
                                    //print('Response body: ${response.body}');

                                    if (response.statusCode == 200) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return const NavigationWrapper();
                                        },
                                        settings: const RouteSettings(
                                          name: 'navigaionPage',
                                        ),
                                      ));
                                    } else {
                                      //500 error, show an alert
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
                                          });
                                    }
                                  },
                                ),
                                TextButton(
                                  child: Text('Resubscribe to Premium'),
                                  onPressed: () async {
                                    //Navigator.of(context).pop();

                                    //get subscription products
                                    List<ProductDetails> productDetails =
                                        await PlannerService
                                            .subscriptionProvider
                                            .fetchSubscriptions();

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) {
                                        return SubscriptionPageNoTrial(
                                            fromPage: 'login',
                                            products: productDetails);
                                      },
                                    ));
                                  },
                                )
                              ],
                            );
                          });
                    },
                  )
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
                      "we weren't able to confirm your subscription. Try to resubscribe. If you have already paid, you will not be charged again."),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Resubscribe'),
                      onPressed: () async {
                        //get subscription products
                        List<ProductDetails> productDetails =
                            await PlannerService.subscriptionProvider
                                .fetchSubscriptions();

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return SubscriptionPageNoTrial(
                                fromPage: 'login', products: productDetails);
                          },
                        ));
                        //Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text(
                        "Use Basic",
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        //show a dialogag asking if theyre sure
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text(
                                    "If you choose to use the basic version, you will not have access to premium features or any of your content associated with such features"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'Yes, use Basic',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    onPressed: () async {
                                      PlannerService.sharedInstance.user!
                                          .isPremiumUser = false;
                                      //update isPremium on server
                                      var body = {
                                        'user': PlannerService
                                            .sharedInstance.user!.id,
                                        'isPremium': PlannerService
                                            .sharedInstance.user!.isPremiumUser,
                                      };
                                      String bodyF = jsonEncode(body);
                                      //print(bodyF);

                                      var url = Uri.parse(PlannerService
                                              .sharedInstance.serverUrl +
                                          '/user/premium');
                                      var response = await http.patch(url,
                                          headers: {
                                            "Content-Type": "application/json"
                                          },
                                          body: bodyF);
                                      //print('Response status: ${response.statusCode}');
                                      //print('Response body: ${response.body}');

                                      if (response.statusCode == 200) {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) {
                                            return const NavigationWrapper();
                                          },
                                          settings: const RouteSettings(
                                            name: 'navigaionPage',
                                          ),
                                        ));
                                      } else {
                                        //500 error, show an alert
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
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  )
                                                ],
                                              );
                                            });
                                      }
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Resubscribe to Premium'),
                                    onPressed: () async {
                                      //Navigator.of(context).pop();

                                      //get subscription products
                                      List<ProductDetails> productDetails =
                                          await PlannerService
                                              .subscriptionProvider
                                              .fetchSubscriptions();

                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return SubscriptionPageNoTrial(
                                              fromPage: 'login',
                                              products: productDetails);
                                        },
                                      ));
                                    },
                                  )
                                ],
                              );
                            });
                      },
                    )
                  ],
                );
              });
        } else {
          //receipt is valid so i dont need to do anything

        }
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
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_outlined),
            label: 'Goals',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.book_outlined),
          //   label: 'The Cover',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
      //home: Text('hello world'),
    );
  }
}
