class Goal {
  String description = "";
  DateTime date = DateTime.now();
  //this '?' says that the value can be null
  String category = "";
  String notes = "";

  Goal(this.description, this.date, this.category, this.notes);
}
