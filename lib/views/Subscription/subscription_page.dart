import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import '../Login/enter_planit_video_page.dart';
import '/views/Login/login.dart';
import '/views/Login/signup.dart';

class SubscriptionPage extends StatefulWidget {
  final String fromPage;
  const SubscriptionPage({Key? key, required this.fromPage}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _SubscriptionPageState extends State<SubscriptionPage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var subscriptionProvider = SubscriptionsProvider();

  String selectedSubscription = "";
  bool doneBtnDisabled = true;
  bool monthlySelected = false;
  bool yearlySelected = false;
  List<ProductDetails> products = [];

  @override
  void dispose() {}

  @override
  initState() {
    subscriptionProvider.purchaseError.addListener(purchaseError);
    subscriptionProvider.purchasePending.addListener(purchasePending);
    subscriptionProvider.purchaseRestored
        .addListener(purchaseRestoredorComplete);
    subscriptionProvider.purchaseSuccess
        .addListener(purchaseRestoredorComplete);

    getSubscitpions();
    super.initState();
  }

  getSubscitpions() async {
    products = await subscriptionProvider.fetchSubscriptions();
  }

  purchaseError() {
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

  purchasePending() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('One Sec, Subscribing...'),
            content: CircularProgressIndicator(
              //color: ,
              value: null,
              semanticsLabel: 'Linear progress indicator',
            ),
          );
        });
  }

  purchaseRestoredorComplete() {
    if (widget.fromPage == "login") {
      if (PlannerService.sharedInstance.user!.hasPlanitVideo) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return const EnterPlannerVideoPage(
              fromPage: "login",
            );
          },
        ));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return const NavigationWrapper();
          },
          settings: const RouteSettings(
            name: 'navigaionPage',
          ),
        ));
      }
    } else {
      //signup
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return const EnterPlannerVideoPage(
            fromPage: "signup",
          );
        },
      ));
    }
  }

  // checkPurchaseStatus() {
  //   print("there was an update in subscription provider");
  //   if (subscriptionProvider.purchaseError == true) {
  //     print("purchase produced an error");
  //     //show error
  //     showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: Text(
  //                 'Oops! Looks like something went wrong. Please try again.'),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: Text('OK'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               )
  //             ],
  //           );
  //         });
  //   } else if (subscriptionProvider.purchaseSuccess == true) {
  //     print("purchase was successful");
  //     //go to next page
  //     if (widget.fromPage == "login") {
  //       if (PlannerService.sharedInstance.user!.hasPlanitVideo) {
  //         Navigator.of(context).push(MaterialPageRoute(
  //           builder: (context) {
  //             return const EnterPlannerVideoPage(
  //               fromPage: "login",
  //             );
  //           },
  //         ));
  //       } else {
  //         Navigator.of(context).push(MaterialPageRoute(
  //           builder: (context) {
  //             return const NavigationWrapper();
  //           },
  //           settings: const RouteSettings(
  //             name: 'navigaionPage',
  //           ),
  //         ));
  //       }
  //     } else {
  //       //signup
  //       Navigator.of(context).push(MaterialPageRoute(
  //         builder: (context) {
  //           return const EnterPlannerVideoPage(
  //             fromPage: "signup",
  //           );
  //         },
  //       ));
  //     }
  //   }
  // }

  void setDoneBtnState() {
    if (selectedSubscription != "") {
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

  void subscribe() async {
    if (selectedSubscription == "monthly") {
      //find the product detail for monthly
      ProductDetails pd = products
          .firstWhere((element) => element.id == "monthly_subscription");
      subscriptionProvider.purchaseProduct(pd);
    } else {
      ProductDetails pd =
          products.firstWhere((element) => element.id == "yearly_subscription");
      subscriptionProvider.purchaseProduct(pd);
    }
  }

  @override
  Widget build(BuildContext context) {
    //MaterialApp is a flutter class which has a constructor

    return Stack(
      children: [
        Image.asset(
          "assets/images/black_stars_background.jpeg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.

            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: Column(
            children: [
              Padding(
                child: Image.asset(
                  "assets/images/welcome_graphic_brownpink.png",
                ),
                padding: EdgeInsets.all(10),
              ),
              const Text("Choose your subscription plan."),
              const Text("Try it FREE for 7 days. You can cancel at any time."),
              //Don't want to keep your Planit after the free trial? No problem, cancel any time before the 7 day trial ends and you'll pay nothing.
              Row(
                children: [
                  Card(
                    child: Column(children: [
                      const Text("Monthly"),
                      const Text('1.99/month'),
                      const Text("Full Access to all Planit features"),
                      Checkbox(
                          value: monthlySelected,
                          onChanged: (value) {
                            print("monthly subscription chosen");
                            setState(() {
                              monthlySelected = true;
                              yearlySelected = false;
                              selectedSubscription = "monthly";
                              setDoneBtnState();
                            });
                          })
                    ]),
                  ),
                  Card(
                    child: Column(children: [
                      const Text("Yearly"),
                      const Text('19.99/year'),
                      const Text("Full Access to all Planit features"),
                      Checkbox(
                          value: yearlySelected,
                          onChanged: (value) {
                            print("yearly subscription chosen");
                            setState(() {
                              yearlySelected = true;
                              monthlySelected = false;
                              selectedSubscription = "yearly";
                              setDoneBtnState();
                            });
                          })
                    ]),
                  )
                ],
              )
            ],
          ),
          persistentFooterButtons: [
            Container(
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      onPressed: doneBtnDisabled ? null : subscribe,
                      child: Text(
                        "Subscribe & Go to my Planit",
                        style: TextStyle(fontSize: 18),
                      ),
                      // style: ButtonStyle(
                      //   backgroundColor: MaterialStateProperty.all<Color>(
                      //       const Color(0xffd4ac62)),
                      // ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xffef41a8)),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Color(0xff7ddcfa),
                              //color: Color(0xffef41a8)
                              //color: Color(0xffd4ac62),
                            ),
                          ))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
