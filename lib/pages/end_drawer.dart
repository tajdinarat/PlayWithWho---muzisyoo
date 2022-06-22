import 'package:flutter/material.dart';
import 'package:muzisyo/models/bildirim.dart';
import 'package:muzisyo/models/gonderi.dart';
import 'package:muzisyo/models/kullanici.dart';
import 'package:muzisyo/pages/basvuran_kisi_info.dart';
import 'package:muzisyo/pages/gonderi_detay.dart';
import 'package:muzisyo/pages/profil.dart';
import 'package:muzisyo/services/firestore_serv.dart';

class EndDrawerWidgetim extends StatefulWidget {
  final String activeUserID;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  EndDrawerWidgetim({required this.activeUserID});

  @override
  _EndDrawerWidgetimState createState() => _EndDrawerWidgetimState();
}

class _EndDrawerWidgetimState extends State<EndDrawerWidgetim> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Bildirim>>(
      future: bildirimCekmeOlayi(widget.activeUserID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              strokeWidth: 5.0,
            ),
          );
        }

        return Drawer(
          child: Column(
            children: [
              //başlık
              FutureBuilder<Widget>(
                future: drawerCocuklariOlustur(snapshot.data!),
                builder: (context, snapshott) {
                  if (!snapshott.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return snapshott.data!;
                },
              ),
              //drawerCocuklariOlustur(snapshot.data!),
              Center(
                child: IconButton(
                    onPressed: () => {Navigator.pop(context)},
                    icon: const Icon(Icons.expand_more_outlined)),
              )
            ],
          ),
        );
      },
    );
  }

  Future<Widget> drawerCocuklariOlustur(List<Bildirim> listBildirim) async {
    List<Widget> listTiles = [];
    for (Bildirim item in listBildirim) {
      Kullanici yapanKisi = await getUserr(item.otherUserID);
      String bildirimMesaji = whatsNotifMessage(item.bildirimTipi);

      listTiles.add(InkWell(
        onTap: () => doAsNotifSaid(bildirim: item),
        child: ListTile(
          contentPadding: const EdgeInsets.all(5.0),
          leading: CircleAvatar(
            foregroundImage: Image.network(
              yapanKisi.userProfilePicture!,
              fit: BoxFit.contain,
            ).image,
          ),
          title: RichText(
              text: TextSpan(
            text: yapanKisi.userRealName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(
                text: " $bildirimMesaji",
                style: const TextStyle(fontWeight: FontWeight.normal),
              )
            ],
          )),
          subtitle: calcTimeDiff(item.zaman.toDate()),
          trailing: FutureBuilder<Widget>(
            future: trailingTipKontrol(bildirim: item),
            builder: (context, snapshottt) {
              if (!snapshottt.hasData) {
                return const Icon(Icons.details_rounded);
              }
              return snapshottt.data!;
            },
          ),
        ),
      ));
    }
    if (listTiles.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.92,
        child: const Center(
          child: Text(
            "Bildirim yok.",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    } else {
      return ListView(
        shrinkWrap: true,
        children: listTiles,
      );
    }
  }

  Widget calcTimeDiff(DateTime firstTime) {
    String timeType = "saniye";
    DateTime secondTime = DateTime.now();
    int timeDiff = secondTime.difference(firstTime).inSeconds;
    double result = timeDiff.toDouble();
    if (timeDiff > 60) {
      result = timeDiff / 60;
      timeType = "dakika";
    }
    if (timeDiff > 3600) {
      result = timeDiff / 3600;
      timeType = "saat";
    }
    if (timeDiff > 86400) {
      result = timeDiff / 86400;
      timeType = "gün";
    }
    return Text(" ${result.floor()} $timeType önce");
  }

  Future<Kullanici> getUserr(String id) async {
    Kullanici aktifKullanici = await FireStoreServisi().kullaniciCek(id: id);
    return aktifKullanici;
  }

  Future<List<Bildirim>> bildirimCekmeOlayi(String activeUserID) async {
    var passThis =
        await FireStoreServisi().bildirimCek(activeUserID: activeUserID);
    return passThis;
  }

  Future<Widget> trailingTipKontrol({required Bildirim bildirim}) async {
    if (bildirim.bildirimTipi == "takip") {
      return const Icon(Icons.person_add_alt);
    } else {
      var postPic = await gonderiFotoGetir(
          akis: bildirim.gonderiTipi,
          yazar: bildirim.yazarID,
          gonderiID: bildirim.gonderiID);
      return Image.network(
        postPic,
        height: 50.0,
        width: 50.0,
        fit: BoxFit.cover,
      );
    }
  }

  Future<String> gonderiFotoGetir({
    required String akis,
    required String yazar,
    required String gonderiID,
  }) async {
    var temp = await FireStoreServisi()
        .gonderiCekByID(following: yazar, akisMain: akis, gonderiID: gonderiID);
    return temp.postPicture;
  }

  String whatsNotifMessage(String tip) {
    if (tip == "begeni") {
      return "gonderini beğendi.";
    } else if (tip == "basvuru") {
      return "ilanına başvurdu.";
    } else if (tip == "takip") {
      return "seni takip etti.";
    }
    return "BİLDİRİMDE HATA OLUŞTU.";
  }

  doAsNotifSaid({required Bildirim bildirim}) async {
    if (bildirim.bildirimTipi == "takip") {
      var thatPerson = await getUserr(bildirim.otherUserID);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Profil(profilSahibiId: bildirim.otherUserID);
      }));
    } else if (bildirim.bildirimTipi == "basvuru") {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return BasvuranKisiInfoSayfasi(basvuranKisiID: bildirim.otherUserID);
        },
      ));
    } else {
      var activeUser = await getUserr(widget.activeUserID);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FutureBuilder<Gonderi>(
                    future: gonderiGetir(
                        id: bildirim.gonderiID,
                        yazar: widget.activeUserID,
                        akisMain: bildirim.gonderiTipi),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }
                      return GonderiDetay(
                        yazar: activeUser,
                        gonderi: snapshot.data!,
                        activeUserID: widget.activeUserID,
                      );
                    },
                  )));
    }
  }

  Future<Gonderi> gonderiGetir(
      {required String id,
      required String yazar,
      required String akisMain}) async {
    var passThis = await FireStoreServisi()
        .gonderiCekByID(following: yazar, akisMain: akisMain, gonderiID: id);
    return passThis;
  }
}
