import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  final _storage = FirebaseStorage.instance.ref();
  late String resimID;
  String? resimId;

  Future<String> profilResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();
    UploadTask yuklemeYoneticisi = _storage
        .child("resimler/profil/profil_$resimId.jpg")
        .putFile(resimDosyasi);
    TaskSnapshot snapshot = await yuklemeYoneticisi;
    String yuklenenResimUrl = await snapshot.ref.getDownloadURL();
    return yuklenenResimUrl;
  }

  Future<String> gonderiResmiYukle(
      {required File resimDosyasi,
      required bool ilanMi,
      required String userID}) async {
    resimID = const Uuid().v4();
    String ilanPath = "";
    if (ilanMi) {
      ilanPath = "ilanlar";
    } else {
      ilanPath = "gonderiler";
    }
    UploadTask fotografYukleyici = _storage
        .child(ilanPath)
        .child(userID)
        .child("pic_$resimID.jpg")
        .putFile(resimDosyasi);
    TaskSnapshot snapshot = await fotografYukleyici;
    String resimURL = await snapshot.ref.getDownloadURL();
    return resimURL;
  }
}
