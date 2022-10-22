import 'dart:convert';

import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:localstorage/localstorage.dart';

import '../../models/backlog_item.dart';
import '../../models/backlog_map_ref.dart';
import '../../models/event.dart';
import '../../models/habit.dart';
import '../../models/life_category.dart';
import '../../models/story.dart';
import '../../models/user.dart';
import '../../services/planner_service.dart';
import '../Subscription/subscription_page_no_free_trial.dart';
import '../navigation_wrapper.dart';
import '/views/Login/login.dart';
import '/views/Login/signup.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

//The widget can be recreated, but the state is attached to the user interface
class _WelcomePageState extends State<WelcomePage> {
  //<MyApp> tells flutter that this state belongs to MyApp Widget
  var questionIndex = 0;
  final LocalStorage storage = LocalStorage('planner_app');
  bool isloggingIn = false;
  double loadPercentage = 0.0;

  @override
  void dispose() {}

  @override
  initState() {
    super.initState();
    //check if user is already logged in, if they are, then just log in
    print("I am printing login status in local storage");
    print(storage.getItem('login'));
    if (storage.getItem('login') != null) {
      if (storage.getItem('login')) {
        //already logged in
        goToPlanner();
      }
    }
  }

  void goToPlanner() async {
    setState(() {
      isloggingIn = true;
      loadPercentage = 0.2;
    });
    var userId = storage.getItem('user');
    //first get user details with userId
    var url = Uri.parse(
        PlannerService.sharedInstance.serverUrl + '/user/' + userId.toString());
    var response = await http.get(url);
    var decodedBody = json.decode(response.body);

    if (response.statusCode == 200) {
      var receipt =
          decodedBody["receipt"] == null ? "" : decodedBody["receipt"];
      var planitName = decodedBody["planitName"];
      var themeId = decodedBody["theme"];
      var spaceTheme = decodedBody["spaceTheme"];
      var didStartPlanningTomorrowInt = decodedBody["didStartPlanningTomorrow"];
      var profileImage = decodedBody["profileImage"];
      var inwardVideoUrl = decodedBody["inwardVideoUrl"] == null
          ? ""
          : decodedBody["inwardVideoUrl"];
      var coverVideoLocalPath = decodedBody["coverVideoLocalPath"] == null
          ? ""
          : decodedBody["coverVideoLocalPath"];
      var currentTaskWorkingOn = decodedBody["currentTaskWorkingOn"] == null
          ? null
          : decodedBody["currentTaskWorkingOn"];
      var freeflowsessionends = decodedBody["freeflowsessionends"] == null
          ? null
          : DateTime.parse(decodedBody["freeflowsessionends"]);
      var quote = decodedBody["quote"];
      var email = decodedBody["email"];
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
      Map<int, int> scheduledEventsMap = {}; //id,scheduled events index
      var habits = <Habit>[];

      var backlogItems = <BacklogItem>[];
      Map<String, List<BacklogItem>> backlogMap = {};
      Map<DateTime, List<BacklogMapRef>> scheduledBacklogItemsMap = {};
      var stories = <Story>[];
      BacklogMapRef? currentTask;

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
        setState(() {
          loadPercentage = 0.4;
        });

        //get all goals
        //print("getting all goals");
        var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
            '/goals/' +
            userId.toString());
        var response3 =
            await http.get(url, headers: {"Content-Type": "application/json"});
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
          setState(() {
            loadPercentage = 0.5;
          });

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
                  background: lifeCategoriesMap[decodedBody[i]["category"]] ==
                          null
                      ? const Color.fromARGB(255, 186, 221, 230)
                      : lifeCategoriesMap[decodedBody[i]["category"]]!.color,
                  category:
                      lifeCategoriesMap[decodedBody[i]["category"]] == null
                          ? null
                          : lifeCategoriesMap[decodedBody[i]["category"]]!,
                  type: decodedBody[i]["type"],
                  notes: decodedBody[i]["notes"],
                  location: decodedBody[i]["location"],
                  backlogIdRef: decodedBody[i]["backlogItemRef"],
                  taskIdRef: decodedBody[i]["backlogItemRef"]);
              scheduledEvents.add(event);
              scheduledEventsMap[event.id!] = scheduledEvents.length - 1;
            }
            setState(() {
              loadPercentage = 0.6;
            });

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
              setState(() {
                loadPercentage = 0.7;
              });

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
                      calendarItemRef: decodedBody[i]["calendarItem"] == null ||
                              decodedBody[i]["calendarItem"] == -1
                          ? null
                          : scheduledEvents[scheduledEventsMap[decodedBody[i]
                              ["calendarItem"]]!],
                      notes: decodedBody[i]["notes"],
                      location: decodedBody[i]["location"],
                      isComplete: isComplete,
                      category: lifeCategoriesMap[decodedBody[i]["category"]]!,
                      status: decodedBody[i]["status"]);
                  backlogItems.add(backlogItem);
                  //backlogMap[backlogItem.category.name]!.add(backlogItem);
                  BacklogMapRef bmr;

                  if (backlogMap.containsKey(backlogItem.category.name)) {
                    backlogMap[backlogItem.category.name]!.add(backlogItem);
                    bmr = BacklogMapRef(
                        categoryName: backlogItem.category.name,
                        arrayIdx:
                            backlogMap[backlogItem.category.name]!.length - 1);
                  } else {
                    var arr = [backlogItem];
                    backlogMap.addAll({backlogItem.category.name: arr});
                    bmr = BacklogMapRef(
                        categoryName: backlogItem.category.name, arrayIdx: 0);
                  }
                  if (decodedBody[i]["calendarItem"] != null &&
                      decodedBody[i]["calendarItem"] != -1) {
                    //it is a calendar event
                    scheduledEvents[
                            scheduledEventsMap[decodedBody[i]["calendarItem"]]!]
                        .backlogMapRef = bmr;
                  }

                  if (currentTaskWorkingOn != null) {
                    if (decodedBody[i]["taskId"] == currentTaskWorkingOn) {
                      currentTask = bmr;
                    }
                  }

                  if (backlogItem.scheduledDate != null) {
                    if (scheduledBacklogItemsMap.containsKey(DateTime(
                        backlogItem.scheduledDate!.year,
                        backlogItem.scheduledDate!.month,
                        backlogItem.scheduledDate!.day))) {
                      scheduledBacklogItemsMap[DateTime(
                              backlogItem.scheduledDate!.year,
                              backlogItem.scheduledDate!.month,
                              backlogItem.scheduledDate!.day)]!
                          .add(bmr);
                    } else {
                      var arr = [bmr];
                      scheduledBacklogItemsMap.addAll({
                        DateTime(
                            backlogItem.scheduledDate!.year,
                            backlogItem.scheduledDate!.month,
                            backlogItem.scheduledDate!.day): arr
                      });
                    }
                  }
                }
                setState(() {
                  loadPercentage = 0.8;
                });

                //get all dictionary items (Dictionary not used right now)
                // var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                //     '/dictionary/' +
                //     userId.toString());
                // var response7 = await http.get(url);
                // //print('Response status: ${response7.statusCode}');
                // //print('Response body: ${response7.body}');

                // if (response7.statusCode == 200) {
                //   var decodedBody = json.decode(response7.body);
                //   //print(decodedBody);
                //   for (int i = 0; i < decodedBody.length; i++) {
                //     var definition = Definition(decodedBody[i]["defId"],
                //         decodedBody[i]["name"], decodedBody[i]["def"]);
                //     dictionaryArr.add(definition);
                //     dictionaryMap.addAll({definition.name: definition});
                //   }

                //get all stories
                var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
                    '/user/' +
                    userId.toString() +
                    '/stories');

                // String bodyF = jsonEncode(body);
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
                  setState(() {
                    loadPercentage = 0.9;
                  });

                  DynamicTheme.of(context)!.setTheme(themeId);
                  var user = User(
                      id: userId,
                      receipt: receipt,
                      planitName: planitName,
                      email: email,
                      //profileImage: "assets/images/profile_pic_icon.png",
                      profileImage: profileImage,
                      themeId: themeId,
                      spaceImage: "assets/images/black_stars_background.jpeg",
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
                  PlannerService.sharedInstance.user!.LifeCategoriesColorMap =
                      lifeCategoriesColorMap;
                  PlannerService.sharedInstance.user!.accomplishedGoals =
                      accomplishedGoals;
                  PlannerService.sharedInstance.user!.goals = goals;
                  PlannerService.sharedInstance.user!.scheduledEvents =
                      scheduledEvents;
                  PlannerService.sharedInstance.user!.habits = habits;
                  PlannerService.sharedInstance.user!.backlogItems =
                      backlogItems;
                  PlannerService.sharedInstance.user!.backlogMap = backlogMap;
                  PlannerService.sharedInstance.user!.scheduledBacklogItemsMap =
                      scheduledBacklogItemsMap;
                  if (freeflowsessionends != null) {
                    PlannerService.sharedInstance.user!
                        .currentFreeFlowSessionEnds = freeflowsessionends;
                  }
                  if (currentTask != null) {
                    PlannerService.sharedInstance.user!.currentTaskWorkingOn =
                        currentTask;
                  }
                  if (quote != null || quote != "") {
                    PlannerService.sharedInstance.user!.homeQuote = quote;
                  }

                  PlannerService.sharedInstance.user!.stories = stories;

                  final directory = await getApplicationDocumentsDirectory();
                  String localDirPath = directory.path;
                  String profilePicPath = '$localDirPath/profilepic';

                  PlannerService.sharedInstance.user!.localProfileImage =
                      profilePicPath;

                  storage.setItem('login', true);
                  storage.setItem('user', userId);

                  if (receipt == "") {
                    setState(() {
                      loadPercentage = 1.0;
                    });
                    PlannerService.sharedInstance.user!.isPremiumUser = false;

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const NavigationWrapper();
                      },
                      settings: const RouteSettings(
                        name: 'navigaionPage',
                      ),
                    ));
                  } else {
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
                                  //get subscription products
                                  List<ProductDetails> productDetails =
                                      await PlannerService.subscriptionProvider
                                          .fetchSubscriptions();

                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return SubscriptionPageNoTrial(
                                          fromPage: 'login',
                                          products: productDetails);
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
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              onPressed: () {
                                                PlannerService
                                                    .sharedInstance
                                                    .user!
                                                    .isPremiumUser = false;

                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) {
                                                    return const NavigationWrapper();
                                                  },
                                                  settings: const RouteSettings(
                                                    name: 'navigaionPage',
                                                  ),
                                                ));
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                  'Resubscribe to Premium'),
                                              onPressed: () async {
                                                //Navigator.of(context).pop();

                                                //get subscription products
                                                List<ProductDetails>
                                                    productDetails =
                                                    await PlannerService
                                                        .subscriptionProvider
                                                        .fetchSubscriptions();

                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) {
                                                    return SubscriptionPageNoTrial(
                                                        fromPage: 'login',
                                                        products:
                                                            productDetails);
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
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                onPressed: () {
                                                  PlannerService
                                                      .sharedInstance
                                                      .user!
                                                      .isPremiumUser = false;

                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) {
                                                      return const NavigationWrapper();
                                                    },
                                                    settings:
                                                        const RouteSettings(
                                                      name: 'navigaionPage',
                                                    ),
                                                  ));
                                                },
                                              ),
                                              TextButton(
                                                child: Text(
                                                    'Resubscribe to Premium'),
                                                onPressed: () async {
                                                  //Navigator.of(context).pop();

                                                  //get subscription products
                                                  List<ProductDetails>
                                                      productDetails =
                                                      await PlannerService
                                                          .subscriptionProvider
                                                          .fetchSubscriptions();

                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) {
                                                      return SubscriptionPageNoTrial(
                                                          fromPage: 'login',
                                                          products:
                                                              productDetails);
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
                      //receipt is valid
                      setState(() {
                        loadPercentage = 1.0;
                      });
                      PlannerService.sharedInstance.user!.isPremiumUser = true;

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
                  setState(() {
                    isloggingIn = false;
                  });
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
                setState(() {
                  isloggingIn = false;
                });
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
              setState(() {
                isloggingIn = false;
              });
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
            setState(() {
              isloggingIn = false;
            });
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
        setState(() {
          isloggingIn = false;
        });
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
    } else {
      setState(() {
        isloggingIn = false;
      });
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

  void login() {
    //print("I am in login function");
    //Navigator.of(context).pushNamed('/login');
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const LoginPage();
      },
    ));
    // Navigator.push(
    //     context, CupertinoPageRoute(builder: (context) => NavigationWrapper()));
  }

  void signup() {
    //print("I am in signup function");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const SignupPage();
      },
      // settings: const RouteSettings(
      //   name: 'navigaionPage',
      // ),
    ));
    // Navigator.push(
    //     context, CupertinoPageRoute(builder: (context) => NavigationWrapper()));
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
            ? Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  // Here we take the value from the MyHomePage object that was created by
                  // the App.build method, and use it to set our appbar title.
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                body: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "One Sec, Taking you to your Planit!",
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          value: loadPercentage,
                        ),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                ),
              )
            : Scaffold(
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
                        "assets/images/welcome_graphic.png",
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                  ],
                ),
                persistentFooterButtons: [
                  Container(
                    child: Column(
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          child: ElevatedButton(
                            onPressed: login,
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: const BorderSide(
                                            color: Color(0xffffffff))))),

                            // style: ButtonStyle(
                            //   backgroundColor: MaterialStateProperty.all<Color>(
                            //       const Color(0xffef41a8)),
                            // ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account yet?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                                onPressed: signup,
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      //color: Color(0xff7ddcfa),
                                      color: Color(0xfff188b1)
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
