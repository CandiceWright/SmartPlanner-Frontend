import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Login/welcome_page.dart';
import 'package:practice_planner/views/navigation_wrapper.dart';
import '../Login/enter_planit_video_page.dart';
import '/views/Login/login.dart';
import '/views/Login/signup.dart';
import 'package:http/http.dart' as http;

class SubscriptionPageNoTrial extends StatefulWidget {
  final String fromPage;
  final List<ProductDetails> products;
  const SubscriptionPageNoTrial(
      {Key? key, required this.fromPage, required this.products})
      : super(key: key);

  @override
  State<SubscriptionPageNoTrial> createState() =>
      _SubscriptionPageNoTrialState();
}

//The widget can be recreated, but the state is attached to the user interface
class _SubscriptionPageNoTrialState extends State<SubscriptionPageNoTrial> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  //var subscriptionProvider = SubscriptionsProvider();

  String selectedSubscription = "yearly";
  bool doneBtnDisabled = true;
  bool monthlySelected = false;
  bool yearlySelected = false;
  late ProductDetails monthlyProduct;
  late ProductDetails yearlyProduct;

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
    monthlyProduct = widget.products
        .firstWhere((element) => element.id == "monthly_subscription");
    yearlyProduct = widget.products
        .firstWhere((element) => element.id == "yearly_subscription");
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
      //print("i got notification of purchase pending in subscription pagee");
      showDialog(
          context: context,
          //barrierDismissible: false,
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
      //print("Saving receipt on subscription page");
      var receipt = PlannerService.subscriptionProvider.receipt.value;
      //print(receipt);
      var body = {
        'receipt': receipt,
        //'userId': PlannerService.sharedInstance.user!.id
        'email': PlannerService.sharedInstance.user!.email
      };
      var bodyF = jsonEncode(body);
      ////print(bodyF);

      var url =
          Uri.parse(PlannerService.sharedInstance.serverUrl + '/user/receipt');
      var response = await http.patch(url,
          headers: {"Content-Type": "application/json"}, body: bodyF);
      //print('Response status: ${response.statusCode}');
      ////print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        PlannerService.sharedInstance.user!.receipt = receipt;
        //I am done with these values so now I can reset thee values
        PlannerService.subscriptionProvider.purchaseSuccess.value = false;
        PlannerService.subscriptionProvider.purchaseRestored.value = false;
        PlannerService.subscriptionProvider.receipt.value = "";
        PlannerService.sharedInstance.user!.receipt = receipt;
        PlannerService.sharedInstance.user!.isPremiumUser = true;
        //print(widget.fromPage);

        var body = {
          'user': PlannerService.sharedInstance.user!.id,
          'isPremium': PlannerService.sharedInstance.user!.isPremiumUser,
        };
        String bodyF = jsonEncode(body);
        //print(bodyF);

        var url = Uri.parse(
            PlannerService.sharedInstance.serverUrl + '/user/premium');
        var response = await http.patch(url,
            headers: {"Content-Type": "application/json"}, body: bodyF);
        //print('Response status: ${response.statusCode}');
        //print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          //if (widget.fromPage == "login" || widget.fromPage == "signup") {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return const NavigationWrapper();
            },
            settings: const RouteSettings(
              name: 'navigaionPage',
            ),
          ));

          // } else {
          //   Navigator.of(context).pop();
          // }
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
    ////print("purchase was successful");
    if (PlannerService.subscriptionProvider.purchaseSuccess.value ||
        PlannerService.subscriptionProvider.purchaseRestored.value) {
      //print("purchase complete");
    }
  }

  void setDoneBtnState() {
    if (selectedSubscription != "") {
      setState(() {
        //print("button enabled");
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

            title: const Text(
              "Go Premium!",
              style: TextStyle(
                  color: Colors.white,
                  //fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            bottom: const PreferredSize(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Unlock all the features of your Planit.",
                      style: TextStyle(color: Colors.white),
                      //textAlign: TextAlign.center,
                    ),
                  ),
                ),
                preferredSize: Size.fromHeight(10.0)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            //elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                if (!PlannerService.sharedInstance.user!.isPremiumUser!) {
                  if (widget.fromPage == "login" ||
                      widget.fromPage == "signup") {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const NavigationWrapper();
                      },
                      settings: const RouteSettings(
                        name: 'navigaionPage',
                      ),
                    ));
                    //}
                  } else {
                    //in app
                    Navigator.of(context).pop();
                  }
                } else {
                  //premium status needs to be updated to false
                  PlannerService.sharedInstance.user!.isPremiumUser = false;
                  //update isPremium on server
                  var body = {
                    'user': PlannerService.sharedInstance.user!.id,
                    'isPremium':
                        PlannerService.sharedInstance.user!.isPremiumUser,
                  };
                  String bodyF = jsonEncode(body);
                  //print(bodyF);

                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/user/premium');
                  var response = await http.patch(url,
                      headers: {"Content-Type": "application/json"},
                      body: bodyF);
                  //print('Response status: ${response.statusCode}');
                  //print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    if (widget.fromPage == "login" ||
                        widget.fromPage == "signup") {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return const NavigationWrapper();
                        },
                        settings: const RouteSettings(
                          name: 'navigaionPage',
                        ),
                      ));
                      //}
                    } else {
                      //in app
                      Navigator.of(context).pop();
                    }
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
                }
              },
            ),
          ),
          body: ListView(
            children: [
              // const Text(
              //   "Try the app out free for one week!",
              //   style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 15,
              //       fontWeight: FontWeight.bold),
              //   textAlign: TextAlign.center,
              // ),
              // const Padding(
              //   padding: EdgeInsets.all(4),
              //   child: Text(
              //     "A subscription is required to use the app after your free trial ends. Here's why!",
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 12,
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              Padding(
                child: Image.asset(
                  "assets/images/planit_logo_black_small.png",
                  width: 60,
                  height: 60,
                ),
                padding: EdgeInsets.all(10),
              ),
              // const Text(
              //   "Go Premium!",
              //   style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 20,
              //       fontWeight: FontWeight.bold),
              //   textAlign: TextAlign.center,
              // ),
              // const Text(
              //   "Unlock all the features of your Planit.",
              //   style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 20,
              //       fontWeight: FontWeight.bold),
              //   textAlign: TextAlign.center,
              // ),
              const ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Color(0xffb4888d),
                ),
                title: Text(
                  "Optimized Life Organization",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                    "Stay on top of all of your tasks with personalized life categories and a daily task scheduler.",
                    style: TextStyle(color: Colors.grey)),
              ),
              const ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Color(0xffb4888d),
                ),
                title: Text("Anxiety-free Productivity",
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(
                    "Access free-flow mode to get things done without stressing about time. ",
                    style: TextStyle(color: Colors.grey)),
              ),
              const ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Color(0xffb4888d),
                ),
                title: Text("Daily Affirmations",
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(
                    "Create daily video affirmations to stimulate positive thinking and reinforce your goals.",
                    style: TextStyle(color: Colors.grey)),
              ),
              const ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Color(0xffb4888d),
                ),
                title:
                    Text("Visual Goals", style: TextStyle(color: Colors.white)),
                subtitle: Text(
                    "Define your life goals with personalized images.",
                    style: TextStyle(color: Colors.grey)),
              ),
              const Text(
                "Choose your Plan",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              GestureDetector(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(
                        width: 3,
                        color: selectedSubscription == "yearly"
                            ? Color(0xffb4888d)
                            : Colors.white, //<-- SEE HERE
                      ),
                    ),
                    margin: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 5),
                    color: Colors.white,
                    elevation: selectedSubscription == "yearly" ? 15 : 0,
                    child: ListTile(
                      title: Text("Yearly",
                          style: TextStyle(
                              color: selectedSubscription == "yearly"
                                  ? Color(0xffb4888d)
                                  : Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                      trailing: Text(
                        yearlyProduct.price + "/year",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )),
                onTap: () {
                  setState(() {
                    selectedSubscription = "yearly";
                  });
                  //setDoneBtnState();
                },
              ),

              GestureDetector(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(
                        width: 3,
                        color: selectedSubscription == "monthly"
                            ? Color(0xffb4888d)
                            : Colors.white, //<-- SEE HERE
                      ),
                    ),
                    margin: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 5),
                    color: Colors.white,
                    elevation: selectedSubscription == "monthly" ? 15 : 0,
                    child: ListTile(
                      title: Text("Monthly",
                          style: TextStyle(
                              color: selectedSubscription == "monthly"
                                  ? Color(0xffb4888d)
                                  : Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                      trailing: Text(
                        monthlyProduct.price + "/month",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                    // Row(children: [
                    //   Text("Monthly",
                    //       style: TextStyle(
                    //           fontSize: 25, fontWeight: FontWeight.bold)),
                    //   Text(monthlyProduct.price,
                    //       style: TextStyle(
                    //           fontSize: 25, fontWeight: FontWeight.bold))
                    // ]),
                    ),
                onTap: () {
                  print("changing subscription option");
                  setState(() {
                    selectedSubscription = "monthly";
                  });

                  //setDoneBtnState();
                },
              ),

              Container(
                  //height: 400,
                  margin: EdgeInsets.only(bottom: 30, top: 15),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      autoPlayInterval: const Duration(seconds: 2),
                      height: 500,
                      viewportFraction: 0.4,
                      aspectRatio: 2,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                      autoPlay: true,
                    ),
                    items: [
                      Container(
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/images/home.PNG",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/images/stories.PNG",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/images/schedule.PNG",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/images/free_flow.PNG",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      // Container(
                      //   child: Column(children: [
                      //     Expanded(
                      //       child: ClipRRect(
                      //         borderRadius: BorderRadius.all(
                      //           Radius.circular(10),
                      //         ),
                      //         child: Image.asset(
                      //           "assets/images/free_flow_notstarted.PNG",
                      //           fit: BoxFit.fill,
                      //         ),
                      //       ),
                      //     ),
                      //   ]),
                      // ),
                      Container(
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/images/free_flow_inprogress.PNG",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/images/goals.PNG",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/images/backlog.PNG",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/images/profile.PNG",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  )),
            ],
          ),
          persistentFooterButtons: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: selectedSubscription == ""
                      ? null
                      : (selectedSubscription == "monthly"
                          ? subscribeMonthly
                          : subscribeYearly),
                  child: const Text(
                    "Subscribe",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xffb4888d))),
                ))
              ],
            ),
          ],
        ),
      ],
    );
  }
}
