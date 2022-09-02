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
      TaskSnapshot snapshot = await storage
          .ref("profile_pictures/" +
              PlannerService.sharedInstance.user!.id.toString())
          .putFile(file);

      String url = await snapshot.ref.getDownloadURL();
      return url;
    } on firebase_core.FirebaseException catch (e) {
      //print(e);
      return "error";
    }
    //return null;
  }

  Future<String?> uploadPicture(String filePath, String storagePath) async {
    File file = File(filePath);
    //print("this is tthe pictures storage patth");
    //print(storagePath);
    try {
      TaskSnapshot snapshot = await storage.ref(storagePath).putFile(file);

      String url = await snapshot.ref.getDownloadURL();
      //print("printing url after trying to upload image to firebase");
      //print(url);
      return url;
    } on firebase_core.FirebaseException catch (e) {
      //print(e);
      return "error";
    }
    //return null;
  }

  Future<String?> uploadStory(String path, String filename) async {
    //print(filename);
    File file = File(path);
    try {
      TaskSnapshot snapshot =
          await storage.ref("stories/" + (filename)).putFile(file);

      String url = await snapshot.ref.getDownloadURL();
      //print("file successful " + url);
      return url;
    } on firebase_core.FirebaseException catch (e) {
      //print("error occurred while trying to upload file");
      //print(e);
      return "error";
    }
    //return null;
  }

  Future<String?> deleteFile(String video) async {
    //File file = File(path);
    ////print("thiis is the path to delete");
    // String path = "stories/" +
    //     PlannerService.sharedInstance.user!.id.toString() +
    //     "/" +
    //     (id).toString();
    // //print(path);
    try {
      await storage.refFromURL(video).delete();
      //print("success deletiing video");

      //String url = await snapshot.ref.getDownloadURL();
      ////print("file successful " + url);
      return "success";
    } on firebase_core.FirebaseException catch (e) {
      //print("error occurred while trying to delete file");
      //print(e);
      return "error";
    }
    //return null;
  }
}
