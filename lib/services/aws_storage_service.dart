import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:practice_planner/services/planner_service.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class AWSStorageService {
  Future<Object> getPresignedUrl(String action, String objKey) async {
    // var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
    //     '/signedUrl' +
    //     '/' +
    //     action +
    //     '/' +
    //     folder +
    //     '/' +
    //     filename);
    var url = Uri.parse(PlannerService.sharedInstance.serverUrl +
        '/signedUrl' +
        '/' +
        action +
        '/' +
        objKey);
    var response = await http.get(url);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return "error";
    }
  }
}
