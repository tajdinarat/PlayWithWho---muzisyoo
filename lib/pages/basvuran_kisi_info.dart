import 'package:flutter/material.dart';
import 'package:muzisyo/models/kullanicim.dart';
import 'package:muzisyo/services/firestore_serv.dart';

class BasvuranKisiInfoSayfasi extends StatefulWidget {
  final String basvuranKisiID;

  BasvuranKisiInfoSayfasi({required this.basvuranKisiID});

  @override
  _BasvuranKisiInfoSayfasiState createState() =>
      _BasvuranKisiInfoSayfasiState();
}

class _BasvuranKisiInfoSayfasiState extends State<BasvuranKisiInfoSayfasi> {
  String _basvuranID = "";
  @override
  void initState() {
    _basvuranID = widget.basvuranKisiID;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 5.0,
        title: const Text("Ilanınıza Başvuran Kişi"),
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
      body: Center(
        child: FutureBuilder<Kullanicim?>(
          future: kullanicimGetirr(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            Kullanicim kullanici = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 70.0,
                  foregroundImage: Image.network(
                    kullanici.userProfilePicture!,
                    fit: BoxFit.contain,
                  ).image,
                ),
                Text("Kullanıcı Adı : " + kullanici.userName!),
                Text("Kullanıcı Ad Soyad : " + kullanici.userRealName!),
                Text("Kullanıcı Kategori : " + kullanici.userPosition!),
                Text("Kullanıcı E-mail : " + kullanici.userEmail!),
                Text("Kullanıcı Telefon No. : " + kullanici.userPhoneNumber!),
              ],
            );
          },
        ),
      ),
      /*body: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 70.0,
              child: Image.network(src),
            ),
          ],
        ),
      ),*/
    );
  }

  Future<Kullanicim?> kullanicimGetirr() async {
    Kullanicim? myMan = await FireStoreServisi().kullaniciGetir(_basvuranID);
    return myMan;
  }
}
