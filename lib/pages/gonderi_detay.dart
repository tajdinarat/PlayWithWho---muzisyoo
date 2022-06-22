import 'package:flutter/material.dart';
import 'package:muzisyo/models/gonderi.dart';
import 'package:muzisyo/models/kullanici.dart';
import 'package:muzisyo/services/firestore_serv.dart';

class GonderiDetay extends StatefulWidget {
  final Kullanici yazar;
  final Gonderi gonderi;
  final String activeUserID;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  GonderiDetay({
    required this.gonderi,
    required this.yazar,
    required this.activeUserID,
  });

  @override
  GonderiDetayState createState() => GonderiDetayState();
}

class GonderiDetayState extends State<GonderiDetay> {
  late Gonderi _gonderi;

  Future<void> ayarla() async {
    _gonderi = widget.gonderi;
  }

  bitirmesiniBekle() {
    ayarla().then((_) => {});
  }

  @override
  void initState() {
    super.initState();
    bitirmesiniBekle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 5.0,
        title: titleOlustur(widget.gonderi.postIlan),
        leading: IconButton(
          splashRadius: 15.0,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              //shrinkWrap: true,
              children: [
                kisiselBilgiWidget(),
                paragrafWidget(),
                gonderiFotoWidget(),
                createBottomLine(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding kisiselBilgiWidget() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(35.0),
            //TAP TO GO TO PROFILE
            onTap: () {},
            child: Container(
              height: 70.0,
              width: 70.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35.0),
                color: Colors.deepPurple[900],
                image: DecorationImage(
                  image: NetworkImage(widget.yazar.userProfilePicture!),
                  fit: BoxFit.fill,
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
                      widget.yazar.userRealName!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Segoe UI",
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        widget.yazar.userName!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: "Segoe UI",
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.yazar.userPosition!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: "Segoe UI",
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.yazar.userLocation!, // CAN ADD USERLOCATION AFTER THIS
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
      ),
    );
  }

  Widget paragrafWidget() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        _gonderi.postParagraph,
        style: const TextStyle(
            fontFamily: "Segoe UI",
            fontSize: 20.0,
            overflow: TextOverflow.fade),
      ),
    );
  }

  Widget gonderiFotoWidget() {
    return Hero(
      tag: _gonderi.postPicture,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Image.network(
          _gonderi.postPicture,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget titleOlustur(bool ilanMi) {
    if (ilanMi) {
      return const Text("İlan");
    } else {
      return const Text("Gönderi");
    }
  }

  Widget createBottomLine() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Row(
        children: [
          hmmLetsSee(),
        ],
      ),
    );
  }

  hmmLetsSee() {
    if (widget.gonderi.postIlan) {
      return TextButton(
          onPressed: () => {ohNoOurTable()}, child: const Text("BAŞVUR"));
    } else {
      return const SizedBox(height: 0);
    }
  }

  Future<void> ohNoOurTable() async {
    await FireStoreServisi().bildirimEkle(
      akisMain: "ilanlar",
      bildirimTipi: "basvuru",
      gonderi: _gonderi,
      otherUserID: widget.activeUserID,
    );
  }
}
