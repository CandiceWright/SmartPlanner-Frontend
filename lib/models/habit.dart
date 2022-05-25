class Habit {
  int? id;
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

  Habit({this.id, required this.description});
}
