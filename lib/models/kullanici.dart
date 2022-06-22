import 'package:cloud_firestore/cloud_firestore.dart';

//gönderiler için kullanıcı çeker
class Kullanici {
  final String? id;
  final String? userProfilePicture;
  final String? userRealName;
  final String? userPosition;
  final String? userGroup;
  final String? userLocation;
  final String? userName;

  Kullanici(
      {required this.id,
      required this.userProfilePicture,
      required this.userRealName,
      required this.userPosition,
      required this.userGroup,
      required this.userLocation,
      required this.userName});

  factory Kullanici.extractInfo(DocumentSnapshot document) {
    return Kullanici(
      id: document.id,
      userProfilePicture: document.get('userProfilePicture'),
      userRealName: document.get('userRealName'),
      userPosition: document.get('userPosition'),
      userGroup: document.get('userGroup'),
      userLocation: document.get('userLocation'),
      userName: document.get('userName'),
    );
  }
}
