class Habit {
  String description = "";
  Map<String, bool> habitTrackerMap = {
    "Sunday": false,
    "Mon": false,
    "Tues": false,
    "Wed": false,
    "Thurs": false,
    "Friday": false,
    "Saturday": false,
  };

  Habit(this.description);
}
