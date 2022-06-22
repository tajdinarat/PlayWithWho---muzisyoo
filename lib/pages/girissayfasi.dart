import 'package:flutter/material.dart';
import 'package:muzisyo/pages/hesapolustur.dart';
import 'package:muzisyo/pages/sifremiunuttum.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({Key? key}) : super(key: key);

  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  bool yukleniyor = false;
  String? email, sifre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("assets/background.jpg"),
        fit: BoxFit.cover,
      )),
      child: Stack(
        children: <Widget>[
          _sayfaElemanlari(),
          _yuklemeAnimasyonu(),
        ],
      ),
    ));
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SizedBox(
        height: 0.0,
      );
    }
  }

  Widget _sayfaElemanlari() {
    return Form(
      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 100.0),
        children: <Widget>[
          Image.asset(
            "assets/logo1.png",
            width: 120,
            height: 120,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 90.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hoşgeldiniz",
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )
              ],
            ),
          ),
          SizedBox(
            height: 40.0,
          ),
          TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                labelText: "Email:",
                fillColor: Colors.white.withOpacity(0.6),
                filled: true,
                hintText: "Email adresinizi giriniz",
                errorStyle: TextStyle(color: Colors.black, fontSize: 16.0),
                prefixIcon: Icon(Icons.person)),
            validator: (girilenDeger) {
              if (girilenDeger!.isEmpty) {
                return "Email alanı boş bırakılamaz";
              }
              return null;
            },
            onSaved: (girilenDeger) => email = girilenDeger,
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
                labelText: "Şifre:",
                fillColor: Colors.white.withOpacity(0.6),
                filled: true,
                hintText: "Şifrenizi giriniz",
                errorStyle: TextStyle(color: Colors.black, fontSize: 16.0),
                prefixIcon: Icon(Icons.lock)),
            validator: (girilenDeger) {
              if (girilenDeger!.isEmpty) {
                return "Şifre alanı boş bırakılamaz";
              } else if (girilenDeger.trim().length < 4) {
                return "Şifre 4 karakterden az olamaz!";
              }
              return null;
            },
            onSaved: (girilenDeger) => sifre = girilenDeger,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: Text(
                  "Şifrenizi mi Unuttunuz?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                ),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SifremiUnuttum())),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: _girisYap,
                child: Text(
                  "Giriş Yap",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  onSurface: Colors.grey,
                  shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HesapOlustur()));
                },
                child: Text(
                  "Üye Ol",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  onSurface: Colors.grey,
                  shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  Future<void> _girisYap() async {
    if (_formAnahtari.currentState!.validate()) {
      _formAnahtari.currentState!.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        await YetkilendirmeServisi().mailIleGiris(email!, sifre!);
      } catch (error) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: error);
      }
    }
  }

  uyariGoster({hataKodu}) {
    if (hataKodu.code == "user-not-found") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("UYARI! Böyle bir kullanıcı bulunmuyor")));
    } else if (hataKodu.code == "invalid-email") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("UYARI! Girdiğiniz mail adresi geçersizdir.")));
    } else if (hataKodu.code == "wrong-password") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("UYARI! Girilen şifre hatalı.")));
    } else if (hataKodu.code == "wrong-password") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("UYARI! Kullanıcı engellenmiş")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("UYARI! Tanımlanamayan bir hata oluştu $hataKodu")));
    }
  }
  /*uyariGoster() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("UYARI! Lütfen doğru değerleri girdiğinizden emin olun.")));
  }*/
}
