import 'package:flutter/material.dart';
import 'package:muzisyo/models/gonderi.dart';
import 'package:muzisyo/models/kullanici.dart';
import 'package:muzisyo/services/firestore_serv.dart';
import '../cards/gonderi_karti.dart';

class Akis extends StatefulWidget {
  final String akisTipi;
  final String activeUserID;
  const Akis({Key? key, required this.akisTipi, required this.activeUserID})
      : super(key: key);

  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  List<Gonderi> _gonderiler = [];

  Future<List<String>> takipEdilenleriGetir() async {
    List<String> following =
        await FireStoreServisi().takipEdilenleriCek(widget.activeUserID);
    return following;
  }

  gonderileriGetir() async {
    var takipedilenler = await takipEdilenleriGetir();
    takipedilenler.add(widget.activeUserID);
    List<Gonderi> gonderiler = [];
    for (var kisi in takipedilenler) {
      var kisigonderiler = await FireStoreServisi()
          .gonderileriCek(following: kisi, akisMain: widget.akisTipi);
      for (var kisigonderi in kisigonderiler) {
        gonderiler.add(kisigonderi);
      }
    }
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  Future<Kullanici> yazariGetir(String yazarID) async {
    Kullanici yazar = await FireStoreServisi().kullaniciCek(id: yazarID);
    return yazar;
  }

  @override
  void initState() {
    super.initState();
    gonderileriGetir();
  }

  @override
  Widget build(BuildContext context) {
    print("gonderiler length : ${_gonderiler.length}<<<<<<<<<<<<<<<<<<<<<<<<");
    return ListView.builder(
      itemCount: _gonderiler.length,
      itemBuilder: (context, pos) {
        Gonderi _gonderi = _gonderiler[pos];
        return FutureBuilder<Kullanici>(
          future: yazariGetir(_gonderi.kullaniciID),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                height: 1.0,
              );
              /*return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 5.0,
                ),
              );*/
            }

            Kullanici yazar = snapshot.data!;
            return GonderiKarti(
                gonderi: _gonderi,
                activeUserID: widget.activeUserID,
                yazar: yazar);
          },
        );
      },
    );
  }
}
