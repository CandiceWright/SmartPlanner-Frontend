import '/models/user.dart';
import '/models/goal.dart';

class PlannerService {
  static var sharedInstance = PlannerService();
  var user = User("", "");

  PlannerService() {}

  saveNewGoal(Goal goal) {
    this.user.goals.add(goal);

    /*Also save to database*/
  }

  List<dynamic> getGoals() {
    /*Once you get server set up, this should  fetch goals from server*/
    return user.goals;
  }
}
