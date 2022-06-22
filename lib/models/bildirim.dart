import 'package:cloud_firestore/cloud_firestore.dart';

class Bildirim {
  final String id;
  final String otherUserID;
  final String gonderiID;
  final String yazarID;
  final String gonderiTipi;
  final String bildirimTipi; //begeni, basvurma, takip
  final Timestamp zaman;

  Bildirim(
      {required this.id,
      required this.otherUserID,
      required this.gonderiID,
      required this.yazarID,
      required this.gonderiTipi,
      required this.bildirimTipi,
      required this.zaman});

  factory Bildirim.extractInfo(DocumentSnapshot document) {
    return Bildirim(
      id: document.id,
      otherUserID: document.get('otherUserID'),
      gonderiID: document.get('gonderiID'),
      yazarID: document.get('yazarID'),
      gonderiTipi: document.get('gonderiTipi'),
      bildirimTipi: document.get('bildirimTipi'),
      zaman: document.get('zaman'),
    );
  }
}
