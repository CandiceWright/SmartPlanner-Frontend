import 'dart:convert';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:practice_planner/models/goal.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:practice_planner/services/subscription_provider.dart';
import 'package:practice_planner/views/Login/enter_planit_video_page.dart';
import 'package:practice_planner/views/Login/forgot_password_page.dart';
import 'package:practice_planner/views/Login/password_resetpin_page.dart';
import 'package:practice_planner/views/Login/restore_purchase_page.dart';
import 'package:practice_planner/views/Login/signup.dart';
import 'package:practice_planner/views/Subscription/subscription_page.dart';
import '../../models/backlog_item.dart';
import '../../models/definition.dart';
import '../../models/habit.dart';
import '../../models/life_category.dart';
import '../../models/story.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '/views/navigation_wrapper.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _LoginPageState extends State<LoginPage> {
  var emailTextController = TextEditingController();
  var passwordTextController = TextEditingController();
  bool shouldShowRestoredDialog = false;
  bool isloggingIn = false;
  //var subscriptionProvider = SubscriptionsProvider();
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  //var questionIndex = 0;
  @override
  initState() {
    // PlannerService.subscriptionProvider.purchaseError
    //     .addListener(purchaseError);
    // PlannerService.subscriptionProvider.purchasePending
    //     .addListener(purchasePending);
    PlannerService.subscriptionProvider.purchaseRestored
        .addListener(purchaseRestored);
    PlannerService.subscriptionProvider.receipt.addListener(saveReceipt);

    // subscriptionProvider.purchaseSuccess
    //     .addListener(purchaseRestoredorComplete);
    // PlannerService.subscriptionProvider.purchaseExpired
    //     .addListener(purchaseExpired);
    super.initState();
  }

  @override
  void dispose() {
    PlannerService.subscriptionProvider.purchaseError
        .removeListener(purchaseError);
    PlannerService.subscriptionProvider.purchasePending
        .removeListener(purchasePending);
    PlannerService.subscriptionProvider.purchaseRestored
        .removeListener(purchaseRestored);
    PlannerService.subscriptionProvider.purchaseExpired
        .removeListener(purchaseExpired);
    PlannerService.subscriptionProvider.receipt.removeListener(saveReceipt);

    super.dispose();
  }

  purchaseExpired() {
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
                onPressed: () async {
                  PlannerService.subscriptionProvider.purchasePending
                      .removeListener(purchasePending);
                  PlannerService.subscriptionProvider.purchaseRestored
                      .removeListener(purchaseRestored);
                  PlannerService.subscriptionProvider.receipt
                      .removeListener(saveReceipt);

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
                  //     return SubscriptionPage(
                  //       fromPage: 'login',
                  //       products: productDetails,
                  //     );
                  //   },
                  // ));
                },
              ),
            ],
          );
        });
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
    const CircularProgressIndicator(
      //color: ,
      value: null,
      semanticsLabel: 'Linear progress indicator',
    );
  }

  purchaseRestored() {
    // if (PlannerService.subscriptionProvider.purchaseRestored.value) {
    //   //print("purchase restored");
    // }

    //PlannerService.subscriptionProvider.purchaseRestored.value = false;
    if (shouldShowRestoredDialog) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                  "We've attempted to restore your purchase. You can try logging in."),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    //Navigator.of(context).pop();
                    shouldShowRestoredDialog = false;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                )
              ],
            );
          });
    }
  }

  saveReceipt() async {
    if (PlannerService.subscriptionProvider.receipt.value != "") {
      //print("Saving receipt");
      var receipt = PlannerService.subscriptionProvider.receipt.value;
      //print(receipt);
      var body = {
        'receipt': receipt,
        'userId': PlannerService.sharedInstance.user!.id
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
        //PlannerService.sharedInstance.user!.receipt = receipt;
        //I am done with these values so now I can reset thee values
        PlannerService.subscriptionProvider.purchaseSuccess.value = false;
        PlannerService.subscriptionProvider.purchaseRestored.value = false;
        PlannerService.subscriptionProvider.receipt.value = "";
        PlannerService.sharedInstance.user!.receipt = receipt;
        // if (shouldShowRestoredDialog) {
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (context) {
        //     return AlertDialog(
        //       title: const Text(
        //           "We've attempted to restore your purchase. You can try logging in."),
        //       actions: <Widget>[
        //         TextButton(
        //           child: Text('OK'),
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //             shouldShowRestoredDialog = false;

        //             // Navigator.pushAndRemoveUntil(
        //             //   context,
        //             //   MaterialPageRoute(
        //             //     builder: (BuildContext context) => LoginPage(),
        //             //   ),
        //             //   (route) => false,
        //             // );
        //           },
        //         )
        //       ],
        //     );
        //   },
        // );
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

  // checkPurchaseStatus() {
  //   //print("there was an update in subscription provider");
  //   if (subscriptionProvider.purchaseError == true) {
  //     //print("purchase produced an error");
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
  //   } else if (subscriptionProvider.purchaseSuccess == true ||
  //       subscriptionProvider.purchaseRestored == true) {
  //     //print("purchase was successful or restored");
  //     //go to next page

  //     showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: Text(
  //                 'Great! Your subscription was restored. Try logging in now.'),
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
  //   }
  // }

  void login() async {
    //validate login and if successful, go to home of app
    var email = emailTextController.text;
    var password = passwordTextController.text;
    var body = {'email': email, 'password': password};
    String bodyF = jsonEncode(body);
    //print(bodyF);

    var url = Uri.parse(PlannerService.sharedInstance.serverUrl + '/login');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: bodyF);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body == "no user exists") {
        //show an error alert for no account
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Oops! No user with that email. Try again.'),
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
      } else if (response.body == "wrong password") {
        //show alert for wrong password
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Inncorrect password. Try again.'),
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
      } else {
        //correct password.
        setState(() {
          isloggingIn = true;
        });
        var decodedBody = json.decode(response.body);
        //print(decodedBody);
        var userId = decodedBody["userId"];
        var receipt =
            decodedBody["receipt"] == null ? "" : decodedBody["receipt"];
        var planitName = decodedBody["planitName"];
        var themeId = decodedBody["theme"];
        var spaceTheme = decodedBody["spaceTheme"];
        var didStartPlanningTomorrowInt =
            decodedBody["didStartPlanningTomorrow"];
        var profileImage = decodedBody["profileImage"];
        var inwardVideoUrl = decodedBody["inwardVideoUrl"] == null
            ? ""
            : decodedBody["inwardVideoUrl"];
        var coverVideoLocalPath = decodedBody["coverVideoLocalPath"] == null
            ? ""
            : decodedBody["coverVideoLocalPath"];
        //print("printing inward video url");
        //print(decodedBody["inwardVideoUrl"]);
        bool didStartPlanning;
        if (didStartPlanningTomorrowInt == 0) {
          didStartPlanning = false;
        } else {
          didStartPlanning = true;
        }

        //get all information then check receipt validity

        var lifeCategories = <LifeCategory>[];
        Map<int, LifeCategory>? lifeCategoriesMap = {};
        Map<String, Color>? lifeCategoriesColorMap =
            {}; //eventually get rid of this and just use the life categories map
        var goals = <Event>[];
        var accomplishedGoals = <Event>[];
        var scheduledEvents = <Event>[];
        Map<int, Event> scheduledEventsMap = {};
        var habits = <Habit>[];
        var dictionaryArr = <Definition>[];
        var dictionaryMap = <String, Definition>{};
        var backlogItems = <BacklogItem>[];
        Map<String, List<BacklogItem>> backlogMap = {};
        var stories = <Story>[];

        //get all life categories
        //print("getting all life categories");
        var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
            '/categories/' +
            userId.toString());
        var response2 = await http.get(url);
        //print('Response status: ${response2.statusCode}');
        //print('Response body: ${response2.body}');

        if (response2.statusCode == 200) {
          var decodedBody = json.decode(response2.body);
          //print(decodedBody);
          //lifeCategories = decodedBody;
          for (int i = 0; i < decodedBody.length; i++) {
            LifeCategory lc = LifeCategory(
                decodedBody[i]["categoryId"],
                decodedBody[i]["name"],
                Color(int.parse(decodedBody[i]["color"])));
            lifeCategories.add(lc);
            lifeCategoriesMap[decodedBody[i]["categoryId"]] = lc;
            lifeCategoriesColorMap[decodedBody[i]["name"]] =
                Color(int.parse(decodedBody[i]["color"]));
            List<BacklogItem> arr = [];
            backlogMap.addAll({lc.name: arr});
          }

          //get all goals
          //print("getting all goals");
          var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
              '/goals/' +
              userId.toString());
          var response3 = await http
              .get(url, headers: {"Content-Type": "application/json"});
          //print('Response status: ${response3.statusCode}');
          //print('Response body: ${response3.body}');
          if (response3.statusCode == 200) {
            var decodedBody = json.decode(response3.body);
            //print(decodedBody);
            for (int i = 0; i < decodedBody.length; i++) {
              var isAccomplished = decodedBody[i]["isAccomplished"];
              var goal = Event(
                  id: decodedBody[i]["goalId"],
                  description: decodedBody[i]["description"],
                  start: DateTime.parse(decodedBody[i]["start"]),
                  end: DateTime.parse(decodedBody[i]["end"]),
                  background:
                      lifeCategoriesMap[decodedBody[i]["category"]]!.color,
                  category: lifeCategoriesMap[decodedBody[i]["category"]]!,
                  type: "goal",
                  notes: decodedBody[i]["notes"],
                  imageUrl: decodedBody[i]["imgUrl"]);
              goal.localImgPath = decodedBody[i]["localImgPath"];
              if (isAccomplished == 1) {
                goal.isAccomplished = true;
                accomplishedGoals.add(goal);
              } else {
                goal.isAccomplished = false;
                goals.add(goal);
              }
            }

            //get all calendar events
            //print("getting all calendar events");
            var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                '/calendar/' +
                userId.toString());
            var response4 = await http.get(url);
            //print('Response status: ${response4.statusCode}');
            //print('Response body: ${response4.body}');

            if (response4.statusCode == 200) {
              var decodedBody = json.decode(response4.body);
              //print(decodedBody);
              for (int i = 0; i < decodedBody.length; i++) {
                var event = Event(
                    id: decodedBody[i]["eventId"],
                    description: decodedBody[i]["description"],
                    start: DateTime.parse(decodedBody[i]["start"]),
                    end: DateTime.parse(decodedBody[i]["end"]),
                    isAccomplished:
                        decodedBody[i]["isAccomplished"] == 1 ? true : false,
                    background:
                        lifeCategoriesMap[decodedBody[i]["category"]]!.color,
                    category: lifeCategoriesMap[decodedBody[i]["category"]]!,
                    type: "calendar",
                    notes: decodedBody[i]["notes"],
                    location: decodedBody[i]["location"],
                    backlogMapRef: decodedBody[i]["backlogItemRef"]);
                scheduledEvents.add(event);
                scheduledEventsMap[event.id!] = event;
              }

              //get all habits
              //print("getting all habits");
              var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                  '/habits/' +
                  userId.toString());
              var response5 = await http.get(url);
              //print('Response status: ${response5.statusCode}');
              //print('Response body: ${response5.body}');

              if (response5.statusCode == 200) {
                var decodedBody = json.decode(response5.body);
                //print(decodedBody);
                for (int i = 0; i < decodedBody.length; i++) {
                  bool sun = decodedBody[i]["sun"] == 1 ? true : false;
                  bool mon = decodedBody[i]["mon"] == 1 ? true : false;
                  bool tues = decodedBody[i]["tues"] == 1 ? true : false;
                  bool wed = decodedBody[i]["wed"] == 1 ? true : false;
                  bool thurs = decodedBody[i]["thurs"] == 1 ? true : false;
                  bool fri = decodedBody[i]["fri"] == 1 ? true : false;
                  bool sat = decodedBody[i]["sat"] == 1 ? true : false;
                  Map<String, bool> habitTrackerMap = {
                    "Sunday": sun,
                    "Mon": mon,
                    "Tues": tues,
                    "Wed": wed,
                    "Thurs": thurs,
                    "Friday": fri,
                    "Saturday": sat,
                  };
                  var habit = Habit(
                      id: decodedBody[i]["habitId"],
                      description: decodedBody[i]["description"]);
                  habit.habitTrackerMap = habitTrackerMap;
                  habits.add(habit);
                }

                //you will need to get all backlog items next and all dictionary items
                //get all backlog items
                //print("getting all backlog");
                var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                    '/backlog/' +
                    userId.toString());
                var response6 = await http.get(url);
                //print('Response status: ${response6.statusCode}');
                //print('Response body: ${response6.body}');

                if (response6.statusCode == 200) {
                  //print("got all backlog");
                  var decodedBody = json.decode(response6.body);
                  //print(decodedBody);
                  for (int i = 0; i < decodedBody.length; i++) {
                    var isComplete;
                    if (decodedBody[i]["isComplete"] == 1) {
                      isComplete = true;
                    } else {
                      isComplete = false;
                    }
                    var backlogItem = BacklogItem(
                        id: decodedBody[i]["taskId"],
                        description: decodedBody[i]["description"],
                        completeBy: decodedBody[i]["completeBy"] == "none"
                            ? null
                            : DateTime.parse(decodedBody[i]["completeBy"]),
                        scheduledDate: decodedBody[i]["scheduledDate"] == null
                            ? null
                            : DateTime.parse(decodedBody[i]["scheduledDate"]),
                        calendarItemRef:
                            scheduledEventsMap[decodedBody[i]["calendarItem"]],
                        notes: decodedBody[i]["notes"],
                        location: decodedBody[i]["location"],
                        isComplete: isComplete,
                        category:
                            lifeCategoriesMap[decodedBody[i]["category"]]!);
                    backlogItems.add(backlogItem);
                    //backlogMap[backlogItem.category.name]!.add(backlogItem);

                    if (backlogMap.containsKey(backlogItem.category.name)) {
                      backlogMap[backlogItem.category.name]!.add(backlogItem);
                    } else {
                      var arr = [backlogItem];
                      backlogMap.addAll({backlogItem.category.name: arr});
                    }
                  }

                  //get all dictionary items
                  var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                      '/dictionary/' +
                      userId.toString());
                  var response7 = await http.get(url);
                  //print('Response status: ${response7.statusCode}');
                  //print('Response body: ${response7.body}');

                  if (response7.statusCode == 200) {
                    var decodedBody = json.decode(response7.body);
                    //print(decodedBody);
                    for (int i = 0; i < decodedBody.length; i++) {
                      var definition = Definition(decodedBody[i]["defId"],
                          decodedBody[i]["name"], decodedBody[i]["def"]);
                      dictionaryArr.add(definition);
                      dictionaryMap.addAll({definition.name: definition});
                    }

                    //get all stories
                    var url = Uri.parse(
                        PlannerService.sharedInstance.serverUrl +
                            '/user/' +
                            userId.toString() +
                            '/stories');

                    String bodyF = jsonEncode(body);
                    var response8 = await http.get(url);

                    //print(
                    // "server came back with a response after saving story");
                    //print('Response status: ${response8.statusCode}');
                    //print('Response body: ${response8.body}');

                    if (response8.statusCode == 200) {
                      var decodedBody = json.decode(response8.body);
                      //print(decodedBody);
                      for (int i = 0; i < decodedBody.length; i++) {
                        var story = Story(
                            decodedBody[i]["storyId"],
                            decodedBody[i]["videoUrl"],
                            decodedBody[i]["videoLocalPath"],
                            decodedBody[i]["thumbnail"],
                            decodedBody[i]["localthumbnailPath"],
                            DateTime.parse(decodedBody[i]["date"]));
                        stories.add(story);
                        //PlannerService.sharedInstance.user!.stories.add(story);
                      }

                      DynamicTheme.of(context)!.setTheme(themeId);
                      var user = User(
                          id: userId,
                          receipt: receipt,
                          planitName: planitName,
                          email: email,
                          //profileImage: "assets/images/profile_pic_icon.png",
                          profileImage: profileImage,
                          themeId: themeId,
                          spaceImage: spaceTheme,
                          //theme: PinkTheme(),
                          didStartTomorrowPlanning: didStartPlanning,
                          lifeCategories: lifeCategories);
                      PlannerService.sharedInstance.user = user;
                      PlannerService.sharedInstance.user!.planitVideo =
                          inwardVideoUrl;
                      PlannerService.sharedInstance.user!.planitVideoLocalPath =
                          coverVideoLocalPath;
                      PlannerService.sharedInstance.user!.hasPlanitVideo =
                          PlannerService.sharedInstance.user!.planitVideo == ""
                              ? false
                              : true;
                      PlannerService.sharedInstance.user!.lifeCategories =
                          lifeCategories;
                      PlannerService.sharedInstance.user!.lifeCategoriesMap =
                          lifeCategoriesMap;
                      PlannerService.sharedInstance.user!
                          .LifeCategoriesColorMap = lifeCategoriesColorMap;
                      PlannerService.sharedInstance.user!.accomplishedGoals =
                          accomplishedGoals;
                      PlannerService.sharedInstance.user!.goals = goals;
                      PlannerService.sharedInstance.user!.scheduledEvents =
                          scheduledEvents;
                      PlannerService.sharedInstance.user!.habits = habits;
                      PlannerService.sharedInstance.user!.backlogItems =
                          backlogItems;
                      PlannerService.sharedInstance.user!.backlogMap =
                          backlogMap;
                      PlannerService.sharedInstance.user!.dictionaryArr =
                          dictionaryArr;
                      PlannerService.sharedInstance.user!.dictionaryMap =
                          dictionaryMap;

                      PlannerService.sharedInstance.user!.stories = stories;

                      final directory =
                          await getApplicationDocumentsDirectory();
                      String localDirPath = directory.path;
                      String profilePicPath = '$localDirPath/profilepic';

                      PlannerService.sharedInstance.user!.localProfileImage =
                          profilePicPath;

                      //check to make sure their subscription is valid before you let them into planit
                      //validate receipt
                      String receiptStatus = await PlannerService
                          .subscriptionProvider
                          .verifyPurchase(receipt);

                      if (receiptStatus == "expired") {
                        //either receipt is expired or need to be restored
                        setState(() {
                          isloggingIn = false;
                        });
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
                                    PlannerService
                                        .subscriptionProvider.purchaseError
                                        .removeListener(purchaseError);
                                    PlannerService
                                        .subscriptionProvider.purchasePending
                                        .removeListener(purchasePending);
                                    PlannerService
                                        .subscriptionProvider.purchaseRestored
                                        .removeListener(purchaseRestored);
                                    PlannerService
                                        .subscriptionProvider.purchaseExpired
                                        .removeListener(purchaseExpired);
                                    PlannerService.subscriptionProvider.receipt
                                        .removeListener(saveReceipt);

                                    //get subscription products
                                    List<ProductDetails> productDetails =
                                        await PlannerService
                                            .subscriptionProvider
                                            .fetchSubscriptions();

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) {
                                        return SubscriptionPage(
                                            fromPage: 'login',
                                            products: productDetails);
                                      },
                                    ));

                                    // Navigator.of(context)
                                    //     .push(MaterialPageRoute(
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
                                    "we weren't able to confirm your subscription. Please try to resubscribe. If you have already paid, you will not be charged again."),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () async {
                                      PlannerService
                                          .subscriptionProvider.purchaseError
                                          .removeListener(purchaseError);
                                      PlannerService
                                          .subscriptionProvider.purchasePending
                                          .removeListener(purchasePending);
                                      PlannerService
                                          .subscriptionProvider.purchaseRestored
                                          .removeListener(purchaseRestored);
                                      PlannerService
                                          .subscriptionProvider.purchaseExpired
                                          .removeListener(purchaseExpired);
                                      PlannerService
                                          .subscriptionProvider.receipt
                                          .removeListener(saveReceipt);

                                      //get subscription products
                                      List<ProductDetails> productDetails =
                                          await PlannerService
                                              .subscriptionProvider
                                              .fetchSubscriptions();

                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) {
                                          return SubscriptionPage(
                                              fromPage: 'login',
                                              products: productDetails);
                                        },
                                      ));
                                      //Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      } else {
                        //Receipt is valid so Get all user information
                        PlannerService.subscriptionProvider.purchaseError
                            .removeListener(purchaseError);
                        PlannerService.subscriptionProvider.purchasePending
                            .removeListener(purchasePending);
                        PlannerService.subscriptionProvider.purchaseRestored
                            .removeListener(purchaseRestored);
                        PlannerService.subscriptionProvider.purchaseExpired
                            .removeListener(purchaseExpired);
                        PlannerService.subscriptionProvider.receipt
                            .removeListener(saveReceipt);
                        if (PlannerService
                            .sharedInstance.user!.hasPlanitVideo) {
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
                  } else {
                    //show and alert error
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
                  //show an alert with error
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
                //show an error
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
              //show an alert with error
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
        } else {
          //show alert that user already exists with that email
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
    } else {
      //404 error, show an alert
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

    // PlannerService.sharedInstance.user!.LifeCategoriesColorMap["Other"] =
    //     Theme.of(context).colorScheme.primary;
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) {
    //     return const NavigationWrapper();
    //   },
    //   settings: const RouteSettings(
    //     name: 'navigaionPage',
    //   ),
    // ));
  }

  void forgotPassword() {
    PlannerService.subscriptionProvider.purchaseError
        .removeListener(purchaseError);
    PlannerService.subscriptionProvider.purchasePending
        .removeListener(purchasePending);
    PlannerService.subscriptionProvider.purchaseRestored
        .removeListener(purchaseRestored);
    PlannerService.subscriptionProvider.purchaseExpired
        .removeListener(purchaseExpired);
    PlannerService.subscriptionProvider.receipt.removeListener(saveReceipt);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ForgotPasswordPage();
      },
    ));
  }

  void signup() {
    //print("I am in signup function");
    PlannerService.subscriptionProvider.purchaseError
        .removeListener(purchaseError);
    PlannerService.subscriptionProvider.purchasePending
        .removeListener(purchasePending);
    PlannerService.subscriptionProvider.purchaseRestored
        .removeListener(purchaseRestored);
    PlannerService.subscriptionProvider.purchaseExpired
        .removeListener(purchaseExpired);
    PlannerService.subscriptionProvider.receipt.removeListener(saveReceipt);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SignupPage();
      },
    ));
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
        isloggingIn
            ? Container(
                child: const CircularProgressIndicator(),
                alignment: Alignment.center,
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  // Here we take the value from the MyHomePage object that was created by
                  // the App.build method, and use it to set our appbar title.
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        child: Image.asset(
                          "assets/images/planit_logo.png",
                        ),
                        padding: EdgeInsets.all(10),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: emailTextController,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          icon: Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        controller: passwordTextController,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                            hintText: "Password",
                            icon: Icon(
                              Icons.password,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                // body: ListView(
                //   children: [
                //     Padding(
                //       child: Image.asset(
                //         "assets/images/planit_logo.png",
                //       ),
                //       padding: EdgeInsets.all(10),
                //     ),
                //     Container(
                //       margin: EdgeInsets.all(15),
                //       child: Column(
                //         children: [
                //           Padding(
                //             padding: EdgeInsets.all(5),
                //             child: TextFormField(
                //               controller: emailTextController,
                //               enableSuggestions: false,
                //               autocorrect: false,
                //               decoration: const InputDecoration(
                //                 hintText: "Email",
                //                 icon: Icon(
                //                   Icons.email,
                //                   color: Colors.white,
                //                 ),
                //                 border: OutlineInputBorder(),
                //                 filled: true,
                //                 fillColor: Colors.white,
                //               ),
                //               validator: (String? value) {
                //                 if (value == null || value.isEmpty) {
                //                   return 'Please enter email';
                //                 }
                //                 return null;
                //               },
                //             ),
                //           ),
                //           Padding(
                //             padding: EdgeInsets.all(5),
                //             child: TextFormField(
                //               controller: passwordTextController,
                //               obscureText: true,
                //               enableSuggestions: false,
                //               autocorrect: false,
                //               decoration: const InputDecoration(
                //                   hintText: "Password",
                //                   icon: Icon(
                //                     Icons.password,
                //                     color: Colors.white,
                //                   ),
                //                   border: OutlineInputBorder(),
                //                   filled: true,
                //                   fillColor: Colors.white),
                //               validator: (String? value) {
                //                 if (value == null || value.isEmpty) {
                //                   return 'Please enter password';
                //                 }
                //                 return null;
                //               },
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                persistentFooterButtons: [
                  Container(
                    child: Column(
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          child: ElevatedButton(
                            onPressed: login,
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xffef41a8)),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                                onPressed: forgotPassword,
                                child: Text(
                                  "Get Help!",
                                  style: TextStyle(
                                    color: Color(0xff7ddcfa),
                                  ),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account yet?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                                onPressed: signup,
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Color(0xff7ddcfa),
                                  ),
                                ))
                          ],
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return const RestorePurchasePage();
                                },
                              ));
                            },
                            child: Text(
                              "Restore Purchase",
                              style: TextStyle(
                                color: Color(0xff7ddcfa),
                              ),
                            ))
                      ],
                    ),
                  )
                ],
              ),
      ],
    );
  }
}
