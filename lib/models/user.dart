import 'goal.dart';

class User {
  var name = "";
  var email = "";
  var goals = [];

  User(this.name, this.email) {
    List<Goal> userGoals = [];
    Goal goal1 = Goal("100,000 planner subscriptions", DateTime(2022, 3, 11));
    Goal goal2 =
        Goal("At least 1,000,000 in my bank accounts", DateTime(2022, 8, 2));
    goals.add(goal1);
    goals.add(goal2);
  }
}
