class Goal {
  String description = "";
  DateTime date = DateTime.now();
  //this '?' says that the value can be null
  String? category;

  Goal(String description, DateTime date, {String? category}) {
    this.description = description;
    this.date = date;
    this.category = category;
  }
}
