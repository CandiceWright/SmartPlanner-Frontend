import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class FirebaseStorage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String?> uploadProfilePic(String path, String fileName) async {
    File file = File(path);
    try {
      await storage
          .ref("profile_pictures/" +
              PlannerService.sharedInstance.user!.id.toString())
          .putFile(file)
          .then((value) {
        value.ref.getDownloadURL().then((url) {
          print(url);
          return url;
          //save url to db
          //if url saves successfully to db,
          PlannerService.sharedInstance.user!.profileImage = path;
        });
      });
    } on firebase_core.FirebaseException catch (e) {
      print(e);
      return "error";
    }
    return null;
  }

  Future<void> downloadFile(String path, String fileName) async {
    File file = File(path);
    try {
      await storage
          .ref("profile_pictures/" +
              PlannerService.sharedInstance.user!.id.toString())
          .putFile(file)
          .then((value) {
        value.ref.getDownloadURL().then((url) {
          print(url);
          //save url to db
          //if url saves successfully to db,
          PlannerService.sharedInstance.user!.profileImage = path;
        });
      });
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }
}
