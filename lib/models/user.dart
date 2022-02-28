import 'package:flutter/foundation.dart';

import 'goal.dart';
import 'backlog_item.dart';

class User {
  var name = "";
  var email = "";
  var goals = [];
  var backlogItems = <BacklogItem>[];
  var backlog = new Map();

  User(this.name, this.email) {
    //Goals
    //List<Goal> userGoals = [];
    Goal goal1 = Goal("100,000 planner subscriptions", DateTime(2022, 3, 11));
    Goal goal2 =
        Goal("At least 1,000,000 in my bank accounts", DateTime(2022, 8, 2));
    goals.add(goal1);
    goals.add(goal2);

    //List<BacklogItem> backlogItems = [];
    BacklogItem bli1 = BacklogItem("Complete backlog feature.",
        DateTime(2022, 3, 1), false, "Planner Business");
    BacklogItem bli2 = BacklogItem(
        "Complete Homepage.", DateTime(2022, 3, 3), false, "Planner Business");
    BacklogItem bli3 = BacklogItem("Complete Calendar Feature.",
        DateTime(2022, 3, 6), false, "Planner Business");
    BacklogItem bli4 = BacklogItem("Complete assistant feature.",
        DateTime(2022, 3, 11), false, "Planner Business");
    BacklogItem bli5 = BacklogItem("Complete Server and connect to front end.",
        DateTime(2022, 3, 16), false, "Planner Business");
    BacklogItem bli6 =
        BacklogItem("Get nails done.", DateTime(2022, 3, 3), false, "Personal");
    BacklogItem bli7 =
        BacklogItem("Wash Clothes.", DateTime(2022, 3, 3), false, "Personal");

    backlogItems.add(bli1);
    backlogItems.add(bli2);
    backlogItems.add(bli3);
    backlogItems.add(bli4);
    backlogItems.add(bli5);
    backlogItems.add(bli6);
    backlogItems.add(bli7);

    print(backlogItems);

    buildBacklogMap();
  }

  void buildBacklogMap() {
    print("I am building backlog");
    //var backlog = new Map();
    for (int i = 0; i < backlogItems.length; i++) {
      print("I am in for loop");
      print(backlogItems[i].category);
      if (backlog.containsKey(backlogItems[i].category)) {
        backlog[backlogItems[i].category].add(backlogItems[i]);
      } else {
        backlog[backlogItems[i].category] = [backlogItems[i]];
      }
    }
    print(backlog);
    //return backlog;
  }
}
