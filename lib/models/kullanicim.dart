import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Kullanicim {
  final String? userId;
  final String? userName;
  final String? userProfilePicture;
  final String? userEmail;
  final String? userInfo;
  final String? userPhoneNumber;
  final String? userRealName;
  final String? userPosition;
  final String? userLocation;
  final String? userGroup;

  Kullanicim({
    required this.userId,
    required this.userName,
    required this.userProfilePicture,
    required this.userEmail,
    required this.userInfo,
    required this.userPhoneNumber,
    required this.userRealName,
    required this.userPosition,
    required this.userLocation,
    required this.userGroup,
  });

  factory Kullanicim.firebasedenUret(User kullanicim) {
    return Kullanicim(
      userId: kullanicim.uid,
      userName: kullanicim.displayName,
      userProfilePicture: '',
      userEmail: kullanicim.email,
      userPhoneNumber: kullanicim.phoneNumber,
      userPosition: '',
      userRealName: '',
      userInfo: '',
      userLocation: '',
      userGroup: '',
    );
  }

  factory Kullanicim.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc;
    return Kullanicim(
        userId: doc.id,
        userName: docData['userName'],
        userEmail: docData['userEmail'],
        userProfilePicture: docData['userProfilePicture'],
        userPhoneNumber: docData['userPhoneNumber'],
        userInfo: docData['userInfo'],
        userRealName: docData['userRealName'],
        userPosition: docData['userPosition'],
        userLocation: docData['userLocation'],
        userGroup: docData['userGroup']);
  }
}
