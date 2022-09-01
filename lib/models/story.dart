import 'dart:io';

class Story {
  int id;
  String videoAwsPath; //url
  String localPath;
  String thumbnail;
  DateTime date = DateTime.now();

  Story(this.id, this.videoAwsPath, this.localPath, this.thumbnail, this.date);
}
