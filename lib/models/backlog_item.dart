class BacklogItem {
  String description = "";
  DateTime completeBy = DateTime.now();
  bool isComplete;
  //this '?' says that the value can be null
  String category;
  String location;
  String notes;

  BacklogItem(this.description, this.completeBy, this.isComplete,
      [this.category = "Other", this.location = "", this.notes = ""]);
}
