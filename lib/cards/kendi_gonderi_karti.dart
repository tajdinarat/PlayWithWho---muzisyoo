import 'package:flutter/material.dart';
import 'package:muzisyo/models/gonderi.dart';
import 'package:muzisyo/models/kullanicim.dart';
import 'package:muzisyo/pages/kendi_gonderi_detay.dart';
import 'package:muzisyo/pages/profil.dart';
import 'package:muzisyo/services/firestore_serv.dart';

class KendiGonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanicim yazar;
  final String activeUserID;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  KendiGonderiKarti(
      {required this.gonderi, required this.activeUserID, required this.yazar});

  @override
  _KendiGonderiKartiState createState() => _KendiGonderiKartiState();
}

class _KendiGonderiKartiState extends State<KendiGonderiKarti> {
  late Gonderi _gonderi;
  bool _isLiked = false;
  int _likeCount = 0;
  String _akisMain = "";

  Future<void> ayarla() async {
    if (widget.gonderi.postIlan) {
      _akisMain = "ilanlar";
    } else {
      _akisMain = "gonderiler";
    }

    _gonderi = await FireStoreServisi().gonderiCekByID(
        following: widget.yazar.userId!,
        akisMain: _akisMain,
        gonderiID: widget.gonderi.id);
    _isLiked = await begenilmisMi();
    _likeCount = await begeniGetir();

    /*_isLiked = await FireStoreServisi().checkIsLiked(
        gonderi: _gonderi,
        activeUserID: widget.activeUserID,
        akisMain: _akisMain);

    _likeCount = await FireStoreServisi().begeniSayisiCek(
        following: widget.yazar.id,
        akisMain: _akisMain,
        gonderiID: widget.gonderi.id);*/

    _gonderi.postLikeCount = _likeCount;
  }

  Future<int> begeniGetir() async {
    var passThis = await FireStoreServisi().begeniSayisiCek(
        following: widget.yazar.userId!,
        akisMain: _akisMain,
        gonderiID: widget.gonderi.id);
    return passThis;
  }

  Future<bool> begenilmisMi() async {
    var passThis = await FireStoreServisi().checkIsLiked(
        gonderi: _gonderi,
        activeUserID: widget.activeUserID,
        akisMain: _akisMain);
    return passThis;
  }

  Future<List<dynamic>> begeniyiHallet() async {
    var boolBegeni = await begenilmisMi();
    var sayiBegeni = await begeniGetir();
    var passThis = [];
    passThis[0] = boolBegeni;
    passThis[1] = sayiBegeni;
    return passThis;
  }

  changeLiked() {
    if (_isLiked) {
      setState(() {
        _isLiked = false;
        _likeCount--;
      });
      FireStoreServisi().unlikePost(
          gonderi: _gonderi,
          activeUserID: widget.activeUserID,
          akisMain: _akisMain,
          yeniLikeCount: _likeCount);
    } else {
      setState(() {
        _isLiked = true;
        _likeCount++;
      });
      FireStoreServisi().likePost(
          gonderi: _gonderi,
          activeUserID: widget.activeUserID,
          akisMain: _akisMain,
          yeniLikeCount: _likeCount);
    }
  }

  bitirmesiniBekle() {
    ayarla().then((_) {});
  }

  @override
  void initState() {
    super.initState();
    bitirmesiniBekle();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
                color: Colors.black, offset: Offset(0.0, 3.0), blurRadius: 0.5)
          ],
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.blue[50],
        ),
        height: MediaQuery.of(context).size.height * 0.25,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  kisiselBilgiWidget(widget.yazar),
                  paragrafWidget(widget.gonderi.postParagraph),
                  altBarWidget(),
                ],
              ),
            ),
            gonderiFotoWidget(widget.gonderi),
          ],
        ),
      ),
    );
  }

  // THOSE WIDGETS<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  Widget kisiselBilgiWidget(Kullanicim userr) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Profil(
                    profilSahibiId: widget.yazar.userId,
                  ))),
          child: Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.deepPurple[900],
              image: DecorationImage(
                image: NetworkImage(userr.userProfilePicture!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    userr.userRealName!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: "Segoe UI",
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      userr.userName!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontFamily: "Segoe UI",
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                userr.userPosition!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: "Segoe UI",
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userr.userLocation!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: "Segoe UI",
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget paragrafWidget(String paragraf) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          paragraf,
          textDirection: TextDirection.ltr,
          maxLines: 2,
          style: const TextStyle(
              fontFamily: "Segoe UI",
              fontSize: 13.5,
              overflow: TextOverflow.fade),
        ),
      ),
    );
  }

  Widget altBarWidget() {
    return Expanded(
      flex: 5,
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              splashRadius: 1.0,
              onPressed: () => {
                changeLiked(),
              },
              icon: Icon(Icons.favorite,
                  color: _isLiked ? Colors.red : Colors.grey),
            ),
            Text(
              "$_likeCount beğeni",
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: benimDegilseSilemem(),
            )
          ],
        ),
      ),
    );
  }

  benimDegilseSilemem() {
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.activeUserID}");
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.yazar.userId}");
    if (widget.activeUserID == widget.yazar.userId) {
      return [
        TextButton(
          onPressed: () => paylasimSilme(),
          child: Column(
            children: const [
              Text(
                "Gönderiyi Sil.",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 0,
        ),
      ];
    } else {
      return const [
        SizedBox(
          height: 0,
        ),
        SizedBox(
          height: 0,
        ),
      ];
    }
  }

  paylasimSilme() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Gerçekten paylaşımı silmek istiyor musunuz ?"),
            children: [
              SimpleDialogOption(
                onPressed: () => {
                  gonderiyiYokEt(),
                  Navigator.pop(context),
                },
                child: const Text("Evet, istiyorum."),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  resetPage();
                },
                child: const Text("İptal."),
              ),
            ],
          );
        });
  }

  resetPage() {
    setState(() {
      ayarla();
    });
  }

  gonderiyiYokEt() async {
    await FireStoreServisi().gonderiSil(
        gonderiId: _gonderi.id,
        gonderiTipi: gonderiTipiNe(),
        yazarID: _gonderi.kullaniciID);
  }

  gonderiTipiNe() {
    if (_gonderi.postIlan) {
      return "ilanlar";
    } else {
      return "gonderiler";
    }
  }

  Widget gonderiFotoWidget(Gonderi gonderi) {
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => KendiGonderiDetay(
                        yazar: widget.yazar,
                        gonderi: _gonderi,
                        activeUserID: widget.activeUserID,
                      )));
        },
        child: Hero(
          tag: gonderi.postPicture,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              gonderi.postPicture,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
