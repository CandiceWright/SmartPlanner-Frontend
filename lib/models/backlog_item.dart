class BacklogItem {
  String description = "";
  DateTime completeBy = DateTime.now();
  //this '?' says that the value can be null
  String? category;
  String? location;
  bool isComplete;

  BacklogItem(this.description, this.completeBy, this.isComplete,
      [this.category, this.location]) {}
}
