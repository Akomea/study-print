import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  String? uid;
  String? displayName;
  Timestamp? dateCreated = Timestamp.now();
  String? avatar;
  String? email;
  List<Map<String, dynamic>>? courses;
  List<Map<String, dynamic>>? completedCourses;
  List<dynamic>? interests;
  int? studentLevel;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.dateCreated,
    this.avatar,
    this.email,
    this.courses,
    this.completedCourses,
  });

  UserModel.fromMap(Map<String, dynamic> data) {
    uid = data['uid'];
    displayName = data['displayName'];
    dateCreated = data['dateCreated'];
    avatar = data['avatar'];
    email = data['email'];
    courses = (data['courses'] as List?)
        ?.map((course) => course as Map<String, dynamic>)
        .toList() ?? [];
    completedCourses = (data['completedCourses'] as List?)
        ?.map((course) => course as Map<String, dynamic>)
        .toList() ?? [];
    interests = data['interests'];
    studentLevel = data['studentLevel'];
  }

}
