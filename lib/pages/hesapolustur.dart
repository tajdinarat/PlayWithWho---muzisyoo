import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muzisyo/models/kullanicim.dart';
import 'package:muzisyo/pages/girissayfasi.dart';
import 'package:muzisyo/services/firestore_serv.dart';
import 'package:muzisyo/services/storage_serv.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';

class HesapOlustur extends StatefulWidget {
  const HesapOlustur({Key? key}) : super(key: key);

  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String? email, telefon, adSoyad, kullaniciAdi, sifre, konum, grup, profilFoto;
  final db = FirebaseFirestore.instance;
  File? _secilmisFoto;

  String dropdownvalue = 'Kategorinizi Seçiniz:';

  // List of items in our dropdown menu
  var items = [
    'Kategorinizi Seçiniz:',
    'Mekan',
    'Vokalist',
    'Gitarist',
    'Bas Gitarist',
    'Baterist',
    'Vurmalı Çalgı',
    'Yaylı Çalgı',
    'Üflemeli Çalgı',
    'Tuşlu Çalgı',
    'DJ',
  ];

  biBakFotoVarMi(File? pfphoto) {
    if (pfphoto == null) {
      return Image.asset("assets/soruisareti.jpg").image;
    } else {
      return Image.file(pfphoto).image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("Üye Ol"),
      ),
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.jpg"),
                  fit: BoxFit.cover)),
          child: Stack(
            children: <Widget>[
              _uyelikElemanlari(),
              _yuklemeAnimasyonu(),
            ],
          )),
    );
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor) {
      return Center();
    } else {
      return const SizedBox(
        height: 0.0,
      );
    }
  }

  Widget _uyelikElemanlari() {
    return ListView(
      children: <Widget>[
        yukleniyor
            ? const LinearProgressIndicator()
            : const SizedBox(
                height: 0.0,
              ),
        const SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 70.0),
          child: Form(
            key: _formAnahtari,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 10.0,
                ),
                InkWell(
                  onTap: fotoSec,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 50.0,
                    backgroundImage: biBakFotoVarMi(_secilmisFoto),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  autocorrect: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      fillColor: Colors.white.withOpacity(0.6),
                      filled: true,
                      hintText: "Email adresinizi giriniz",
                      labelText: "Email:",
                      errorStyle:
                          const TextStyle(color: Colors.black, fontSize: 12.0),
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Colors.grey[900],
                      )),
                  validator: (girilenDeger) {
                    if (girilenDeger!.isEmpty) {
                      return "Email alanı boş bırakılamaz.";
                    } else if (!girilenDeger.contains("@")) {
                      return "Girilen değer mail formatında olmalıdır.";
                    }
                    return null;
                  },
                  onSaved: (girilenDeger) {
                    email = girilenDeger;
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  autocorrect: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      fillColor: Colors.white.withOpacity(0.6),
                      filled: true,
                      hintText: "Telefon numaranızı giriniz",
                      labelText: "Telefon Numarası:",
                      errorStyle:
                          const TextStyle(color: Colors.black, fontSize: 12.0),
                      prefixIcon: Icon(Icons.call, color: Colors.grey[900])),
                  validator: (girilenDeger) {
                    if (girilenDeger!.isEmpty) {
                      return "Telefon numarası alanı boş bırakılamaz.";
                    } else if (!girilenDeger.contains(RegExp(r'[0-9]'))) {
                      return "Girilen değer telefon numarası formatında olmalıdır.";
                    }
                    return null;
                  },
                  onSaved: (girilenDeger) {
                    telefon = girilenDeger;
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  autocorrect: true,
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      fillColor: Colors.white.withOpacity(0.6),
                      filled: true,
                      hintText: "Adınızı ve soyadınızı giriniz",
                      labelText: "Ad, Soyad:",
                      errorStyle:
                          const TextStyle(color: Colors.black, fontSize: 12.0),
                      prefixIcon: Icon(Icons.person_pin_rounded,
                          color: Colors.grey[900])),
                  validator: (girilenDeger) {
                    if (girilenDeger!.isEmpty) {
                      return "Ad, Soyad alanı boş bırakılamaz";
                    }
                    return null;
                  },
                  onSaved: (girilenDeger) {
                    adSoyad = girilenDeger;
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  autocorrect: true,
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      fillColor: Colors.white.withOpacity(0.6),
                      filled: true,
                      hintText: "Kullanıcı adınızı giriniz",
                      labelText: "Kullanıcı Adı:",
                      errorStyle:
                          const TextStyle(color: Colors.black, fontSize: 12.0),
                      prefixIcon: Icon(Icons.person, color: Colors.grey[900])),
                  validator: (girilenDeger) {
                    if (girilenDeger!.isEmpty) {
                      return "Kullanıcı adı alanı boş bırakılamaz";
                    } else if (girilenDeger.trim().length < 4 ||
                        girilenDeger.trim().length > 10) {
                      return "En az 4 en fazla 10 karakter giriniz.";
                    }
                    return null;
                  },
                  onSaved: (girilenDeger) {
                    kullaniciAdi = girilenDeger;
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      labelText: "Şifre:",
                      fillColor: Colors.white.withOpacity(0.6),
                      filled: true,
                      hintText: "Şifrenizi giriniz",
                      errorStyle:
                          const TextStyle(color: Colors.black, fontSize: 12.0),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[900])),
                  validator: (girilenDeger) {
                    if (girilenDeger!.isEmpty) {
                      return "Şifre alanı boş bırakılamaz";
                    } else if (girilenDeger.trim().length < 4) {
                      return "Şifre 4 karakterden az olamaz!";
                    }
                    return null;
                  },
                  onSaved: (girilenDeger) {
                    sifre = girilenDeger;
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      labelText: "Yaşadığınız Şehir:",
                      fillColor: Colors.white.withOpacity(0.6),
                      filled: true,
                      hintText: "Şehir adını giriniz:",
                      errorStyle:
                          const TextStyle(color: Colors.black, fontSize: 12.0),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[900])),
                  validator: (girilenDeger) {
                    if (girilenDeger!.isEmpty) {
                      return "Şehir kısmı boş bırakılamaz!";
                    }
                    return null;
                  },
                  onSaved: (girilenDeger) {
                    konum = girilenDeger;
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      labelText: "Sanatçı isminiz(Grup/Tekil):",
                      fillColor: Colors.white.withOpacity(0.6),
                      filled: true,
                      hintText: "Sanatçı isminizi giriniz:",
                      errorStyle:
                          const TextStyle(color: Colors.black, fontSize: 12.0),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[900])),
                  validator: (girilenDeger) {
                    if (girilenDeger!.isEmpty) {
                      return "Sanatçı ismi boş bırakılamaz!";
                    }
                    return null;
                  },
                  onSaved: (girilenDeger) {
                    grup = girilenDeger;
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                          0.6), //background color of dropdown button
                      border: Border.all(color: Colors.black38, width: 3),
                      //border of dropdown button
                      borderRadius: BorderRadius.circular(
                          50), //border raiuds of dropdown button
                      boxShadow: const <BoxShadow>[
                        //apply shadow on Dropdown button
                        //blur radius of shadow
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: DropdownButton(
                      // Initial Value
                      value: dropdownvalue,
                      dropdownColor: Colors.white, //dropdown background color
                      underline: Container(), //remove underline
                      isExpanded: true,

                      // Down Arrow Icon
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                          validator:
                          (dropdownvalue) {
                            if (dropdownvalue == "Kategorinizi Seçiniz:") {
                              return "Lütfen bir kategori seçiniz";
                            }
                            return null;
                          };
                          onSaved:
                          (dropdownvalue) {
                            dropdownvalue = dropdownvalue;
                          };
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      child: Text(
                        "Mevcut hesaba giriş yap =>",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15.0),
                      ),
                      onTap: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GirisSayfasi()))
                      },
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
                      onPressed: _uyeOl,
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
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  fotoSec() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Fotoğraf yükle."),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  fotoCek();
                },
                child: const Text("Fotoğraf Çek."),
              ),
              SimpleDialogOption(
                onPressed: () {
                  galeridenCek();
                },
                child: const Text("Galeriden Seç."),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("İptal."),
              ),
            ],
          );
        });
  }

  fotoCek() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) {
      _showToast(context);
    } else {
      setState(() {
        _secilmisFoto = File(image.path);
      });
    }
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Fotoğraf tespit edilemedi!'),
        action: SnackBarAction(
          label: 'Tamam',
          onPressed: () {
            scaffold.hideCurrentSnackBar;
          },
        ),
      ),
    );
  }

  galeridenCek() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      _showToast(context);
    } else {
      setState(() {
        _secilmisFoto = File(image.path);
      });
    }
  }

  Future<void> _uyeOl() async {
    if (_formAnahtari.currentState!.validate()) {
      profilFoto = await StorageServisi().profilResmiYukle(_secilmisFoto!);
      _formAnahtari.currentState!.save();

      setState(() {
        yukleniyor = true;
      });

      try {
        Kullanicim? kullanici =
            await YetkilendirmeServisi().mailIleKayit(email!, sifre!);
        if (kullanici != null) {
          FireStoreServisi().kullaniciOlustur(
            userId: kullanici.userId,
            userEmail: email,
            userName: kullaniciAdi,
            userPhoneNumber: telefon,
            userRealName: adSoyad,
            userPosition: dropdownvalue,
            userGroup: grup,
            userLocation: konum,
            userProfilePicture: profilFoto,
          );
        }
        Navigator.pop(context);
      } catch (error) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: error);
      }
    }
  }

  uyariGoster({hataKodu}) {
    if (hataKodu.code == "invalid-email") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("UYARI! Girdiğiniz mail adresi geçersizdir.")));
    } else if (hataKodu.code == "email-already-in-use") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("UYARI! Girdiğiniz mail kayıtlıdır.")));
    } else if (hataKodu.code == "weak-password") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("UYARI! Daha zor bir şifre tercih edin.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("UYARI! Tanımlanamayan bir hata oluştu $hataKodu")));
    }
  }
}
