import 'dart:io';

class Story {
  //int id;
  File video;
  String thumbnail;
  DateTime date = DateTime.now();

  Story(this.video, this.thumbnail, this.date);
}
