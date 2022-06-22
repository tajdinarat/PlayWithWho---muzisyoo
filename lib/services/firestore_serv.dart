import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muzisyo/models/bildirim.dart';
import 'package:muzisyo/models/gonderi.dart';
import 'package:muzisyo/models/kullanici.dart';
import 'package:muzisyo/models/kullanicim.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';

class FireStoreServisi {
  final _firestore = FirebaseFirestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur(
      {userId,
      userEmail,
      userName,
      userPhoneNumber,
      userRealName,
      userPosition,
      userProfilePicture,
      userLocation,
      userGroup}) async {
    await _firestore.collection("users").doc(userId).set({
      "userEmail": userEmail,
      "userName": userName,
      "userProfilePicture": userProfilePicture,
      "userInfo": "",
      "userPhoneNumber": userPhoneNumber,
      "userRealName": userRealName,
      "userPosition": userPosition,
      "userSignDate": zaman,
      "userLocation": userLocation,
      "userGroup": userGroup,
    });
  }

  Future<Kullanicim?> kullaniciGetir(id) async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(id).get();
    if (doc.exists) {
      Kullanicim kullanicim = Kullanicim.dokumandanUret(doc);
      return kullanicim;
    }
    return null;
  }

  void kullaniciGuncelle(
      {String? kullaniciId,
      String? kullaniciAdi,
      String fotoUrl = "",
      String? hakkinda}) {
    _firestore.collection("users").doc(kullaniciId).update({
      "userName": kullaniciAdi,
      "userInfo": hakkinda,
      "userProfilePicture": fotoUrl
    });
  }

  Future<List<Kullanicim>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .where("userName", isGreaterThanOrEqualTo: kelime)
        .get();

    List<Kullanicim> kullanicilar =
        snapshot.docs.map((doc) => Kullanicim.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  void takiptenCik({String? aktifKullaniciId, String? profilSahibiId}) {
    _firestore
        .collection("users")
        .doc(profilSahibiId)
        .collection("Followers")
        .doc(aktifKullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    _firestore
        .collection("users")
        .doc(aktifKullaniciId)
        .collection("Following")
        .doc(profilSahibiId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  void takipEt({String? aktifKullaniciId, String? profilSahibiId}) {
    _firestore
        .collection("users")
        .doc(profilSahibiId)
        .collection("Followers")
        .doc(aktifKullaniciId)
        .set({});
    _firestore
        .collection("users")
        .doc(aktifKullaniciId)
        .collection("Following")
        .doc(profilSahibiId)
        .set({});

    takipBildirimEkle(
        takipEdenID: aktifKullaniciId!, takipEdilenID: profilSahibiId!);
  }

  Future<bool> takipKontrol(
      {String? aktifKullaniciId, String? profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("users")
        .doc(aktifKullaniciId)
        .collection("Following")
        .doc(profilSahibiId)
        .get();
    if (doc.exists) {
      return true;
    }
    return false;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .doc(kullaniciId)
        .collection("Followers")
        .get();
    print(snapshot.docs.length);
    return snapshot.docs.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .doc(kullaniciId)
        .collection("Following")
        .get();
    print(kullaniciId + "   123  ");
    print(snapshot.docs.length);
    return snapshot.docs.length;
  }

  Future<void> kullaniciSil({String? kullaniciId}) async {
    YetkilendirmeServisi().kullaniciyiYokEtme();
    List<String> followerList = await followerCek(kullaniciId!);
    _firestore
        .collection("gonderiler")
        .doc(kullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    _firestore
        .collection("ilanlar")
        .doc(kullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    for (var follower in followerList) {
      _firestore
          .collection("users")
          .doc(follower)
          .collection("Following")
          .doc(kullaniciId)
          .get()
          .then((DocumentSnapshot doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      _firestore
          .collection("users")
          .doc(follower)
          .collection("Followers")
          .doc(kullaniciId)
          .get()
          .then((DocumentSnapshot doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
    _firestore
        .collection("users")
        .doc(kullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<void> gonderiSil(
      {required String gonderiId,
      required String gonderiTipi,
      required String yazarID}) async {
    _firestore
        .collection(gonderiTipi)
        .doc(yazarID)
        .collection("userPosts")
        .doc(gonderiId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<Kullanici> kullaniciCek({id}) async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(id).get();
    print("$id");
    return Kullanici.extractInfo(doc);
  }

  Future<List<String>> followerCek(String activeUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(activeUserId)
        .collection('Followers')
        .get();
    List<String> list = snapshot.docs.map((doc) => doc.id).toList();
    return list;
  }

  Future<List<String>> takipEdilenleriCek(String activeUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(activeUserId)
        .collection('Following')
        .get();
    List<String> list = snapshot.docs.map((doc) => doc.id).toList();
    return list;
  }

  Future<List<Gonderi>> gonderileriCek(
      {required String following, required String akisMain}) async {
    QuerySnapshot temp = await _firestore
        .collection(akisMain)
        .doc(following)
        .collection('userPosts')
        .get();
    List<Gonderi> passThis =
        temp.docs.map((e) => Gonderi.extractInfo(e, following)).toList();
    return passThis;
  }

  Future<int> begeniSayisiCek(
      {required String akisMain,
      required String following,
      required String gonderiID}) async {
    var docSnap = await _firestore
        .collection(akisMain)
        .doc(following)
        .collection('userPosts')
        .doc(gonderiID)
        .get();
    int passThis = Gonderi.extractInfo(docSnap, following).postLikeCount;
    return passThis;
  }

  Future<Gonderi> gonderiCekByID(
      {required String following,
      required String akisMain,
      required String gonderiID}) async {
    DocumentSnapshot temp = await _firestore
        .collection(akisMain)
        .doc(following)
        .collection('userPosts')
        .doc(gonderiID)
        .get();
    Gonderi passThis = Gonderi.extractInfo(temp, following);
    return passThis;
  }

  likePost(
      {required Gonderi gonderi,
      required String activeUserID,
      required String akisMain,
      required int yeniLikeCount}) {
    DocumentReference docRef = _firestore
        .collection(akisMain)
        .doc(gonderi.kullaniciID)
        .collection('userPosts')
        .doc(gonderi.id);

    docRef.update({'postLikeCount': yeniLikeCount});
    docRef.collection('likedUsers').doc(activeUserID).set({});

    if (activeUserID != gonderi.kullaniciID) {
      bildirimEkle(
          otherUserID: activeUserID,
          gonderi: gonderi,
          bildirimTipi: "begeni",
          akisMain: akisMain);
    }
  }

  unlikePost(
      {required Gonderi gonderi,
      required String activeUserID,
      required String akisMain,
      required int yeniLikeCount}) {
    DocumentReference docRef = _firestore
        .collection(akisMain)
        .doc(gonderi.kullaniciID)
        .collection('userPosts')
        .doc(gonderi.id);

    docRef.update({'postLikeCount': yeniLikeCount});
    docRef.collection('likedUsers').doc(activeUserID).delete();
  }

  Future<bool> checkIsLiked(
      {required Gonderi gonderi,
      required String activeUserID,
      required String akisMain}) async {
    QuerySnapshot docSnap = await _firestore
        .collection(akisMain)
        .doc(gonderi.kullaniciID)
        .collection('userPosts')
        .doc(gonderi.id)
        .collection('likedUsers')
        .get();
    List<String> lel = docSnap.docs.map((e) => e.id).toList();
    print(
        " liked status is :  ${lel.contains(activeUserID)}<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    bool passThis = lel.contains(activeUserID);
    print("after liked stat : $passThis");
    return passThis;
  }

  Future<void> gonderiOlustur({
    required String gonderiResmiURL,
    required String yazarID,
    required String paragraf,
    required bool ilanMi,
  }) async {
    var tablePath = ilanMi ? "ilanlar" : "gonderiler";
    await _firestore
        .collection(tablePath)
        .doc(yazarID)
        .collection("userPosts")
        .doc()
        .set({
      "postIlan": ilanMi,
      "postLikeCount": 0,
      "postParagraph": paragraf,
      "postPicture": gonderiResmiURL
    });
  }

  Future<void> bildirimEkle({
    required String otherUserID,
    required Gonderi gonderi,
    required String bildirimTipi,
    required String akisMain,
  }) async {
    DateTime currentPhoneDate = DateTime.now();
    Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);
    await _firestore
        .collection('users')
        .doc(gonderi.kullaniciID)
        .collection('Bildirimler')
        .add({
      "otherUserID": otherUserID,
      "gonderiID": gonderi.id,
      "yazarID": gonderi.kullaniciID,
      "bildirimTipi": bildirimTipi,
      "zaman": myTimeStamp,
      "gonderiTipi": akisMain,
    });
  }

  Future<void> takipBildirimEkle({
    required String takipEdenID,
    required String takipEdilenID,
  }) async {
    DateTime currentPhoneDate = DateTime.now();
    Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);
    await _firestore
        .collection('users')
        .doc(takipEdilenID)
        .collection('Bildirimler')
        .add({
      "otherUserID": takipEdenID,
      "gonderiID": "",
      "yazarID": takipEdilenID,
      "bildirimTipi": "takip",
      "zaman": myTimeStamp,
      "gonderiTipi": "users",
    });
  }

  Future<List<Bildirim>> bildirimCek({required String activeUserID}) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(activeUserID)
        .collection('Bildirimler')
        .orderBy('zaman', descending: true)
        .get();
    List<Bildirim> bildirimlerList = [];
    snapshot.docs.forEach((element) {
      Bildirim addThis = Bildirim.extractInfo(element);
      bildirimlerList.add(addThis);
    });
    return bildirimlerList;
  }
}
