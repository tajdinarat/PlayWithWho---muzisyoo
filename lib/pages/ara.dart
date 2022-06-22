import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:muzisyo/models/kullanicim.dart';
import 'package:muzisyo/pages/profil.dart';
import 'package:muzisyo/services/firestore_serv.dart';

class Ara extends StatefulWidget {
  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaController = TextEditingController();
  Future<List<Kullanicim>>? _aramaSonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.deepOrange,
      title: TextFormField(
        onFieldSubmitted: (girilenDeger) {
          setState(() {
            _aramaSonucu = FireStoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _aramaController,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              size: 30.0,
              color: Colors.white,
            ),
            suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () {
                  _aramaController.clear();
                  setState(() {
                    _aramaSonucu = null;
                  });
                }),
            border: InputBorder.none,
            fillColor: Colors.deepOrange,
            filled: true,
            hintText: "Kullanıcı Ara...",
            contentPadding: EdgeInsets.only(top: 16.0)),
      ),
    );
  }

  aramaYok() {
    return Center(child: Text("Kullanıcı Ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanicim>>(
        future: _aramaSonucu,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.length == 0) {
            return Center(child: Text("Bu arama için sonuç bulunamadı!"));
          }

          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Kullanicim kullanici = snapshot.data![index];
                return kullaniciSatiri(kullanici);
              });
        });
  }

  kullaniciSatiri(Kullanicim kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profil(
                      profilSahibiId: kullanici.userId,
                    )));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.userProfilePicture!),
        ),
        title: Text(
          kullanici.userName!,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
