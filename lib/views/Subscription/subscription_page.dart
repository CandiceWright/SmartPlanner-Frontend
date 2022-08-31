import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Login/welcome_page.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import '../Login/enter_planit_video_page.dart';
import '/views/Login/login.dart';
import '/views/Login/signup.dart';
import 'package:http/http.dart' as http;

class SubscriptionPage extends StatefulWidget {
  final String fromPage;
  final List<ProductDetails> products;
  const SubscriptionPage(
      {Key? key, required this.fromPage, required this.products})
      : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _SubscriptionPageState extends State<SubscriptionPage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  //var subscriptionProvider = SubscriptionsProvider();

  String selectedSubscription = "";
  bool doneBtnDisabled = true;
  bool monthlySelected = false;
  bool yearlySelected = false;
  //List<ProductDetails> products = [];

  @override
  void dispose() {
    PlannerService.subscriptionProvider.purchaseError
        .removeListener(purchaseError);
    PlannerService.subscriptionProvider.purchasePending
        .removeListener(purchasePending);
    // PlannerService.subscriptionProvider.purchaseRestored
    //     .removeListener(purchaseRestoredorComplete);
    PlannerService.subscriptionProvider.purchaseSuccess
        .removeListener(purchaseRestoredorComplete);
    PlannerService.subscriptionProvider.receipt.removeListener(saveReceipt);
    super.dispose();
  }

  @override
  initState() {
    PlannerService.subscriptionProvider.purchaseError
        .addListener(purchaseError);
    PlannerService.subscriptionProvider.purchasePending
        .addListener(purchasePending);
    // PlannerService.subscriptionProvider.purchaseRestored
    //     .addListener(purchaseRestoredorComplete);
    PlannerService.subscriptionProvider.receipt.addListener(saveReceipt);
    PlannerService.subscriptionProvider.purchaseSuccess
        .addListener(purchaseRestoredorComplete);

    //getSubscitpions();
    super.initState();
  }

  // getSubscitpions() async {
  //   products = await PlannerService.subscriptionProvider.fetchSubscriptions();
  // }

  purchaseError() {
    if (PlannerService.subscriptionProvider.purchaseError.value) {
      PlannerService.subscriptionProvider.purchaseError.value = false;
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
  }

  purchasePending() {
    if (PlannerService.subscriptionProvider.purchasePending.value) {
      print("i got notification of purchase pending in subscription pagee");
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const AlertDialog(
              title: Text('One Sec...'),
              content: CircularProgressIndicator(
                //color: ,
                value: null,
                semanticsLabel: 'Linear progress indicator',
              ),
            );
          });
    }
  }

  saveReceipt() async {
    if (PlannerService.subscriptionProvider.receipt.value != "") {
      print("Saving receipt on subscription page");
      var receipt = PlannerService.subscriptionProvider.receipt.value;
      print(receipt);
      var body = {
        'receipt': receipt,
        'userId': PlannerService.sharedInstance.user!.id
      };
      var bodyF = jsonEncode(body);
      //print(bodyF);

      var url =
          Uri.parse(PlannerService.sharedInstance.serverUrl + '/user/receipt');
      var response = await http.patch(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);
      print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        PlannerService.sharedInstance.user!.receipt = receipt;
        //I am done with these values so now I can reset thee values
        PlannerService.subscriptionProvider.purchaseSuccess.value = false;
        PlannerService.subscriptionProvider.purchaseRestored.value = false;
        PlannerService.subscriptionProvider.receipt.value = "";
        PlannerService.sharedInstance.user!.receipt = receipt;
        print(widget.fromPage);

        //need to save receipt tto database

        if (widget.fromPage == "login") {
          if (PlannerService.sharedInstance.user!.hasPlanitVideo) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) {
                return const EnterPlannerVideoPage(
                  fromPage: "login",
                );
              },
            ));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
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
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return const EnterPlannerVideoPage(
                fromPage: "signup",
              );
            },
          ));
        }
      } else {
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
    }
  }

  purchaseRestoredorComplete() {
    //print("purchase was successful");
    if (PlannerService.subscriptionProvider.purchaseSuccess.value ||
        PlannerService.subscriptionProvider.purchaseRestored.value) {
      print("purchase complete");
    }

    // if (PlannerService.subscriptionProvider.purchaseRestored.value ||
    //     PlannerService.subscriptionProvider.purchaseSuccess.value) {
    //   //store the receipt in your db
    //   //I am done with these values so now I can reset thee values
    //   PlannerService.subscriptionProvider.purchaseSuccess.value = false;
    //   PlannerService.subscriptionProvider.purchaseRestored.value = false;
    //   print(widget.fromPage);

    //   //need to save receipt tto database

    //   if (widget.fromPage == "login") {
    //     if (PlannerService.sharedInstance.user!.hasPlanitVideo) {
    //       Navigator.of(context).pushReplacement(MaterialPageRoute(
    //         builder: (context) {
    //           return const EnterPlannerVideoPage(
    //             fromPage: "login",
    //           );
    //         },
    //       ));
    //     } else {
    //       Navigator.of(context).pushReplacement(MaterialPageRoute(
    //         builder: (context) {
    //           return const NavigationWrapper();
    //         },
    //         settings: const RouteSettings(
    //           name: 'navigaionPage',
    //         ),
    //       ));
    //     }
    //   } else {
    //     //signup
    //     Navigator.of(context).pushReplacement(MaterialPageRoute(
    //       builder: (context) {
    //         return const EnterPlannerVideoPage(
    //           fromPage: "signup",
    //         );
    //       },
    //     ));
    //   }
    // }
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
    PlannerService.subscriptionProvider.purchaseInProgress = true;
    if (selectedSubscription == "monthly") {
      //find the product detail for monthly
      ProductDetails pd = widget.products
          .firstWhere((element) => element.id == "monthly_subscription");
      PlannerService.subscriptionProvider.purchaseProduct(pd);
    } else {
      ProductDetails pd = widget.products
          .firstWhere((element) => element.id == "yearly_subscription");
      PlannerService.subscriptionProvider.purchaseProduct(pd);
    }
  }

  void subscribeMonthly() async {
    PlannerService.subscriptionProvider.purchaseInProgress = true;
    //find the product detail for monthly
    ProductDetails pd = widget.products
        .firstWhere((element) => element.id == "monthly_subscription");
    PlannerService.subscriptionProvider.purchaseProduct(pd);
  }

  void subscribeYearly() async {
    PlannerService.subscriptionProvider.purchaseInProgress = true;

    ProductDetails pd = widget.products
        .firstWhere((element) => element.id == "yearly_subscription");
    PlannerService.subscriptionProvider.purchaseProduct(pd);
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
            // title: const Text(
            //   "Another Planit",
            //   style: TextStyle(color: Colors.white),
            // ),
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0.0,
            // bottom: const PreferredSize(
            //     child: Align(
            //       alignment: Alignment.center,
            //       child: Padding(
            //         padding: EdgeInsets.only(bottom: 10),
            //         child: Text(
            //           "Choose your subscription plan.",
            //           style: TextStyle(color: Colors.white),
            //           //textAlign: TextAlign.center,
            //         ),
            //       ),
            //     ),
            //     preferredSize: Size.fromHeight(10.0)),
          ),
          body: Column(
            children: [
              // const Padding(
              //   padding: EdgeInsets.all(8),
              //   child: Text(
              //     "Your first week is free. Try it out!",
              //     style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold),
              //     textAlign: TextAlign.center,
              //   ),
              // ),

              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Try it out free, 1 week!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                "After free trial, choose your subscription option below.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              Padding(
                child: Image.asset(
                  "assets/images/planit_logo.png",
                ),
                padding: EdgeInsets.all(10),
              ),

              // const Padding(
              //   padding: EdgeInsets.all(8),
              //   child: Text(
              //     "Try it out free, 1 week!",
              //     style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              // const Text(
              //   "After free trial, choose your subscription below.",
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 14,
              //   ),
              //   textAlign: TextAlign.center,
              // ),

              // Padding(
              //   padding: EdgeInsets.all(8),
              //   child: ElevatedButton(
              //     onPressed: doneBtnDisabled ? null : subscribe,
              //     //onPressed: subscribe,

              //     child: Text(
              //       "Subscribe & Go to my Planit",
              //       style: TextStyle(fontSize: 18),
              //     ),
              //     // style: ButtonStyle(
              //     //   backgroundColor: MaterialStateProperty.all<Color>(
              //     //       const Color(0xffd4ac62)),
              //     // ),
              //     style: ButtonStyle(
              //       backgroundColor: MaterialStateProperty.all<Color>(
              //           const Color(0xffef41a8)),
              //     ),
              //   ),
              // ),

              Padding(
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  //onPressed: doneBtnDisabled ? null : subscribeMonthly,
                  onPressed: subscribeMonthly,

                  child: Text(
                    "Monthly \$1.99",
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
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "or",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  //onPressed: doneBtnDisabled ? null : subscribeYearly,
                  onPressed: subscribeYearly,

                  child: Text(
                    "Yearly \$19.99",
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
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "We're confident you'll love your planit, but If you're not satisfied, cancel anytime before your trial ends and you won't be charged.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
