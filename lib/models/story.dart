import 'dart:io';

class Story {
  int id;
  String videoAwsPath; //url
  String localPath;
  String thumbnail;
  String localThumbnailPath;
  DateTime date = DateTime.now();

  Story(this.id, this.videoAwsPath, this.localPath, this.thumbnail,
      this.localThumbnailPath, this.date);
}
