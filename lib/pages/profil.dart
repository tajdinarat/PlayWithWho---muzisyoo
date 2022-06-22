import 'package:flutter/material.dart';
import 'package:muzisyo/cards/kendi_gonderi_karti.dart';
import 'package:muzisyo/models/gonderi.dart';
import 'package:muzisyo/models/kullanici.dart';
import 'package:muzisyo/models/kullanicim.dart';
import 'package:muzisyo/pages/profiliduzenle.dart';
import 'package:muzisyo/services/firestore_serv.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class Profil extends StatefulWidget {
  final String? profilSahibiId;

  const Profil({Key? key, required this.profilSahibiId}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  bool _takipEdildi = false;
  late Kullanicim _profilSahibi;
  String? _aktifKullaniciId;

  _takipKontrol() async {
    bool takipVarMi = await FireStoreServisi().takipKontrol(
        profilSahibiId: widget.profilSahibiId,
        aktifKullaniciId: _aktifKullaniciId);
    setState(() {
      _takipEdildi = takipVarMi;
    });
  }

  _takipciSayisiGetir() async {
    int takipciSayisi =
        await FireStoreServisi().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _takipEdilenSayisiGetir() async {
    int takipEdilenSayisi =
        await FireStoreServisi().takipEdilenSayisi(widget.profilSahibiId);

    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilenSayisi;
      });
    }
  }

  @override
  void initState() {
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _takipKontrol();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        actions: <Widget>[
          widget.profilSahibiId == _aktifKullaniciId
              ? IconButton(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.black,
                  ),
                  onPressed: _cikisYap)
              : SizedBox(
                  height: 0.0,
                )
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Object?>(
          future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, AsyncSnapshot snapshot) {
            print(_aktifKullaniciId);
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            _profilSahibi = snapshot.data;

            return ListView(
              children: [
                _profilDetaylari(_profilSahibi),
                kendiGonderileri(_profilSahibi),
              ],
            );
          }),
    );
  }

  kendiGonderileri(profilSahibiKul) {
    return FutureBuilder<List<Gonderi>>(
      future: kendiGonderileriniGetir(),
      builder: (context, snapshot) {
        //
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              "Gönderi yok.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          );
        }
        //
        List<Gonderi> fatherSaveMeFromDarkness = snapshot.data!;
        List<Widget> lmao = [];
        for (Gonderi item in fatherSaveMeFromDarkness) {
          lmao.add(KendiGonderiKarti(
              gonderi: item,
              activeUserID: _aktifKullaniciId!,
              yazar: profilSahibiKul));
        }
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(children: lmao),
        );
      },
    );
  }

  /*


  */

  Future<List<Gonderi>> kendiGonderileriniGetir() async {
    List<Gonderi> gonderiList = [];
    List<Gonderi> gonderiGonderi = await FireStoreServisi().gonderileriCek(
        following: widget.profilSahibiId!, akisMain: "gonderiler");
    List<Gonderi> gonderiIlan = await FireStoreServisi()
        .gonderileriCek(following: widget.profilSahibiId!, akisMain: "ilanlar");
    for (var item in gonderiIlan) {
      gonderiList.add(item);
    }
    for (var item in gonderiGonderi) {
      gonderiList.add(item);
    }
    return gonderiList;
  }

  Future<Kullanici> getUserr(String id) async {
    Kullanici aktifKullanici = await FireStoreServisi().kullaniciCek(id: id);
    return aktifKullanici;
  }

  Widget _profilDetaylari(Kullanicim profilData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 50.0,
                backgroundImage: profilResmi(profilData).image,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _sosyalSayac(baslik: "Gönderiler", sayi: _gonderiSayisi),
                    _sosyalSayac(baslik: "Takipçi", sayi: _takipci),
                    _sosyalSayac(baslik: "Takip", sayi: _takipEdilen),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                profilData.userRealName.toString() + " ",
                style: const TextStyle(
                    fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              Text(
                "(" + profilData.userName.toString() + ")",
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                profilData.userGroup.toString() + " /",
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
              Text(
                " " + profilData.userPosition.toString(),
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(profilData.userInfo.toString()),
          SizedBox(
            height: 10.0,
          ),
          widget.profilSahibiId == _aktifKullaniciId
              ? _profiliDuzenleButonu()
              : _takipButonu(),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }

  Image profilResmi(Kullanicim profilData) {
    if (profilData.userProfilePicture!.isNotEmpty) {
      return Image.network(profilData.userProfilePicture.toString());
    } else {
      return Image.asset("assets/soruisareti.jpg");
    }
  }

  Widget _takipButonu() {
    return _takipEdildi ? _takiptenCikButonu() : _takipEtButonu();
  }

  Widget _takipEtButonu() {
    return Container(
      width: double.infinity,
      height: 50.0,
      child: TextButton(
        onPressed: () {
          FireStoreServisi().takipEt(
              profilSahibiId: widget.profilSahibiId,
              aktifKullaniciId: _aktifKullaniciId);
          setState(() {
            _takipEdildi = true;
            _takipci = _takipci + 1;
          });
        },
        child: const Text(
          "Takip Et",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(backgroundColor: Colors.deepOrange),
      ),
    );
  }

  Widget _takiptenCikButonu() {
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          FireStoreServisi().takiptenCik(
              profilSahibiId: widget.profilSahibiId,
              aktifKullaniciId: _aktifKullaniciId);
          setState(() {
            _takipEdildi = false;
            _takipci = _takipci - 1;
          });
        },
        child: Text(
          "Takipten Çık",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(backgroundColor: Colors.deepOrange),
      ),
    );
  }

  Widget _profiliDuzenleButonu() {
    return Container(
      width: double.infinity,
      height: 50.0,
      child: TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfiliDuzenle(
                        profil: _profilSahibi,
                      )));
        },
        child: const Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(backgroundColor: Colors.deepOrange),
      ),
    );
  }

  Widget _sosyalSayac({String? baslik, int? sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          sayi.toString(),
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 2.0,
        ),
        Text(
          baslik!,
          style: const TextStyle(
            fontSize: 15.0,
          ),
        ),
      ],
    );
  }

  void _cikisYap() {
    Navigator.pop(context);
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
