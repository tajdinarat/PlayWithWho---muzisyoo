import 'package:flutter/material.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class SifremiUnuttum extends StatefulWidget {
  @override
  _SifremiUnuttumState createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Şifremi Sıfırla"),
      ),
      body: ListView(
        children: <Widget>[
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
                key: _formAnahtari,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email adresinizi girin",
                        labelText: "Mail:",
                        errorStyle: TextStyle(fontSize: 16.0),
                        prefixIcon: Icon(Icons.mail),
                      ),
                      validator: (girilenDeger) {
                        if (girilenDeger!.isEmpty) {
                          return "Email alanı boş bırakılamaz!";
                        } else if (!girilenDeger.contains("@")) {
                          return "Girilen değer mail formatında olmalı!";
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => email = girilenDeger,
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    Container(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _sifreyiSifirla,
                        child: Text(
                          "Şifremi Sıfırla",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.deepOrange),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  void _sifreyiSifirla() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    var _formState = _formAnahtari.currentState;

    if (_formState!.validate()) {
      _formState.save();
      setState(() {
        yukleniyor = true;
      });

      try {
        await _yetkilendirmeServisi.sifremiSifirla(email!);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Girilen maile şifre sıfırlama linki gönderilmiştir. Lütfen kontrol ediniz !")));
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu.code == "auth/invalid-email") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("UYARI! Girdiğiniz mail adresi geçersizdir.")));
    } else if (hataKodu.code == "auth/user-not-found") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("UYARI! Bu kullanıcı bulunamıyor.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("UYARI! Tanımlanamayan bir hata oluştu $hataKodu")));
    }
  }
}
