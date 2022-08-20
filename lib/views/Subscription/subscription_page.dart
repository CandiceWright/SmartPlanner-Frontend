import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Login/welcome_page.dart';
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
  //var subscriptionProvider = SubscriptionsProvider();

  String selectedSubscription = "";
  bool doneBtnDisabled = true;
  bool monthlySelected = false;
  bool yearlySelected = false;
  List<ProductDetails> products = [];

  @override
  void dispose() {
    PlannerService.subscriptionProvider.purchaseError
        .removeListener(purchaseError);
    PlannerService.subscriptionProvider.purchasePending
        .removeListener(purchasePending);
    PlannerService.subscriptionProvider.purchaseRestored
        .removeListener(purchaseRestoredorComplete);
    PlannerService.subscriptionProvider.purchaseSuccess
        .removeListener(purchaseRestoredorComplete);
    super.dispose();
  }

  @override
  initState() {
    PlannerService.subscriptionProvider.purchaseError
        .addListener(purchaseError);
    PlannerService.subscriptionProvider.purchasePending
        .addListener(purchasePending);
    PlannerService.subscriptionProvider.purchaseRestored
        .addListener(purchaseRestoredorComplete);
    PlannerService.subscriptionProvider.purchaseSuccess
        .addListener(purchaseRestoredorComplete);

    getSubscitpions();
    super.initState();
  }

  getSubscitpions() async {
    products = await PlannerService.subscriptionProvider.fetchSubscriptions();
  }

  purchaseError() {
    if (PlannerService.subscriptionProvider.purchaseError.value) {
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

  purchaseRestoredorComplete() {
    print("purchase complete");
    if (PlannerService.subscriptionProvider.purchaseRestored.value ||
        PlannerService.subscriptionProvider.purchaseSuccess.value) {
      //I am done with these values so now I can reset thee values
      PlannerService.subscriptionProvider.purchaseSuccess.value = false;
      PlannerService.subscriptionProvider.purchaseRestored.value = false;
      print(widget.fromPage);
      //remove listeners here
      // PlannerService.subscriptionProvider.purchaseError
      //     .removeListener(purchaseError);
      // PlannerService.subscriptionProvider.purchasePending
      //     .removeListener(purchasePending);
      // PlannerService.subscriptionProvider.purchaseRestored
      //     .removeListener(purchaseRestoredorComplete);
      // PlannerService.subscriptionProvider.purchaseSuccess
      //     .removeListener(purchaseRestoredorComplete);
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
    //if (selectedSubscription == "monthly") {
    //find the product detail for monthly
    ProductDetails pd =
        products.firstWhere((element) => element.id == "monthly_subscription");
    PlannerService.subscriptionProvider.purchaseProduct(pd);
    // } else {
    //   ProductDetails pd =
    //       products.firstWhere((element) => element.id == "yearly_subscription");
    //   PlannerService.subscriptionProvider.purchaseProduct(pd);
    // }
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
              Padding(
                child: Image.asset(
                  "assets/images/planit_logo.png",
                ),
                padding: EdgeInsets.all(10),
              ),
              const Text(
                "Free trial 1 week.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(6),
                child: const Text(
                  "\$1.99/month",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              //Don't want to keep your Planit after the free trial? No problem, cancel any time before the 7 day trial ends and you'll pay nothing.
              //Row(
              //children: [
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(10.0),
              //   ),
              //   color: Colors.white,
              //   child: Column(children: [
              //     const Text(
              //       ' \$1.99/month',
              //       style:
              //           TextStyle(color: const Color(0xffef41a8), fontSize: 20),
              //       textAlign: TextAlign.center,
              //     ),
              //     const Text(
              //       "Full Access to all Planit Features",
              //     ),
              //     // Checkbox(
              //     //     value: monthlySelected,
              //     //     onChanged: (value) {
              //     //       print("monthly subscription chosen");
              //     //       setState(() {
              //     //         monthlySelected = true;
              //     //         yearlySelected = false;
              //     //         selectedSubscription = "monthly";
              //     //         setDoneBtnState();
              //     //       });
              //     //     })
              //   ]),
              // ),
              Padding(
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  // onPressed: doneBtnDisabled ? null : subscribe,
                  onPressed: subscribe,

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

              const Text(
                "You will not be charged until your 1 week trial ends.",
                style: TextStyle(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "Cancel at any time.",
                style: TextStyle(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "Full Access to all Planit Features",
              ),

              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(20.0),
              //   ),
              //   color: Colors.white,
              //   child: Column(children: [
              //     const Text(
              //       ' \$19.99/year',
              //       style:
              //           TextStyle(color: const Color(0xffef41a8), fontSize: 20),
              //       textAlign: TextAlign.center,
              //     ),
              //     const Text(
              //       "Full Access to all Planit Features",
              //     ),
              //     Checkbox(
              //         value: yearlySelected,
              //         onChanged: (value) {
              //           print("yearly subscription chosen");
              //           setState(() {
              //             yearlySelected = true;
              //             monthlySelected = false;
              //             selectedSubscription = "yearly";
              //             setDoneBtnState();
              //           });
              //         })
              //   ]),
              // )
              //],
              //)
            ],
          ),
          // persistentFooterButtons: [
          //   Container(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         // FractionallySizedBox(
          //         //   widthFactor: 0.5,
          //         //   child: ElevatedButton(
          //         //     // onPressed: doneBtnDisabled ? null : subscribe,
          //         //     onPressed: subscribe,

          //         //     child: Text(
          //         //       "Subscribe",
          //         //       //style: TextStyle(fontSize: 18),
          //         //     ),
          //         //     // style: ButtonStyle(
          //         //     //   backgroundColor: MaterialStateProperty.all<Color>(
          //         //     //       const Color(0xffd4ac62)),
          //         //     // ),
          //         //     style: ButtonStyle(
          //         //       backgroundColor: MaterialStateProperty.all<Color>(
          //         //           const Color(0xffef41a8)),
          //         //     ),
          //         //   ),
          //         // ),
          //         //Row(
          //         // mainAxisAlignment: MainAxisAlignment.center,
          //         //children: [
          //         TextButton(
          //             onPressed: () {
          //               Navigator.of(context).pushReplacement(MaterialPageRoute(
          //                 builder: (context) {
          //                   return const WelcomePage();
          //                 },
          //               ));
          //             },
          //             child: const Text(
          //               "Cancel",
          //               style: TextStyle(
          //                 color: Color(0xff7ddcfa),
          //                 //color: Color(0xffef41a8)
          //                 //color: Color(0xffd4ac62),
          //               ),
          //             ))
          //         //],
          //         //)
          //       ],
          //     ),
          //   )
          // ],
        ),
      ],
    );
  }
}
