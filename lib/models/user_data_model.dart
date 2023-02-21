import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

///User model class with attributes which define what a user is
class User{
  String? uid;
  String? displayName;
  Timestamp dateCreated = Timestamp.now();
  int? avatar;
  String? email;

  ///A constructor for setting attribute values when creating a user object
   User ({
    required this.uid,
    required this.displayName,
    required this.dateCreated,
    this.avatar,
    this.email,
  });

  ///Receives a map which matches class attributes
  User.fromMap(Map<String, dynamic> data) {
    uid = data['uid'];
    displayName = data['displayName'];
    dateCreated = data['dateCreated'];
    avatar = data['avatar'];
    email = data['email'];
  }
}