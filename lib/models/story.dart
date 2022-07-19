import 'dart:io';

class Story {
  int id;
  String video; //url
  String thumbnail;
  DateTime date = DateTime.now();

  Story(this.id, this.video, this.thumbnail, this.date);
}
