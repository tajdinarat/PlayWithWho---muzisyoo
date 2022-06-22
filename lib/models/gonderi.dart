import 'package:cloud_firestore/cloud_firestore.dart';

class Gonderi {
  final String id;
  final String kullaniciID;
  final String postPicture;
  final String postParagraph;
  int postLikeCount;
  final bool postIlan;

  Gonderi(
      {required this.id,
      required this.kullaniciID,
      required this.postPicture,
      required this.postParagraph,
      required this.postLikeCount,
      required this.postIlan});

  factory Gonderi.extractInfo(DocumentSnapshot document, String ownerID) {
    return Gonderi(
      id: document.id,
      kullaniciID: ownerID,
      postLikeCount: document.get('postLikeCount'),
      postParagraph: document.get('postParagraph'),
      postPicture: document.get('postPicture'),
      postIlan: document.get('postIlan'),
    );
  }
}
