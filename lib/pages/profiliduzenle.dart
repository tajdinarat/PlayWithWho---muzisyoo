import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muzisyo/models/kullanicim.dart';
import 'package:muzisyo/services/firestore_serv.dart';
import 'package:muzisyo/services/storage_serv.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanicim profil;

  const ProfiliDuzenle({Key? key, required this.profil}) : super(key: key);

  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  bool _yukleniyor = false;
  String? _kullaniciAdi;
  String? _hakkinda;
  File? _secilmisFoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.check,
                color: Colors.black,
              ),
              onPressed: _kaydet),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _yukleniyor
              ? const LinearProgressIndicator()
              : const SizedBox(
                  height: 0.0,
                ),
          _profilFoto(),
          _kullaniciBilgileri()
        ],
      ),
    );
  }

  _kaydet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _yukleniyor = true;
      });

      _formKey.currentState!.save();

      String profilFotoUrl;
      if (_secilmisFoto == null) {
        profilFotoUrl = widget.profil.userProfilePicture.toString();
      } else {
        profilFotoUrl = await StorageServisi().profilResmiYukle(_secilmisFoto!);
      }

      String? aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      FireStoreServisi().kullaniciGuncelle(
          kullaniciId: aktifKullaniciId,
          kullaniciAdi: _kullaniciAdi,
          hakkinda: _hakkinda,
          fotoUrl: profilFotoUrl);

      setState(() {
        _yukleniyor = false;
      });

      Navigator.pop(context);
    }
  }

  biBakFotoVarMi(File? pfphoto) {
    if (pfphoto == null) {
      return Image.network(widget.profil.userProfilePicture!).image;
    } else {
      return Image.file(pfphoto).image;
    }
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Center(
        child: InkWell(
          onTap: fotoSec,
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 50.0,
            backgroundImage: biBakFotoVarMi(_secilmisFoto),
          ),
        ),
      ),
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

  _galeridenSec() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      _secilmisFoto = File(image!.path);
    });
  }

  _kullaniciSilme() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Gerçekten hesabınızı silmek istiyor musunuz ?"),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  String? aktifKullaniciId =
                      Provider.of<YetkilendirmeServisi>(context, listen: false)
                          .aktifKullaniciId;

                  FireStoreServisi()
                      .kullaniciSil(kullaniciId: aktifKullaniciId);

                  setState(() {
                    _yukleniyor = false;
                  });

                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Provider.of<YetkilendirmeServisi>(context, listen: false)
                      .cikisYap();
                },
                child: const Text("Evet, istiyorum."),
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

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              initialValue: widget.profil.userName,
              decoration: InputDecoration(labelText: "Kullanıcı Adı"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length <= 3
                    ? "Kullanıcı adı en az 4 karakter olmalı"
                    : null;
              },
              onSaved: (girilenDeger) {
                _kullaniciAdi = girilenDeger;
              },
            ),
            TextFormField(
              initialValue: widget.profil.userInfo,
              decoration: InputDecoration(labelText: "Hakkında"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length > 100
                    ? "100 Karakterden fazla olmamalı"
                    : null;
              },
              onSaved: (girilenDeger) {
                _hakkinda = girilenDeger;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    onPressed: _kullaniciSilme,
                    child: Text(
                      "Beni yok et !",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.grey,
                      backgroundColor: Colors.white,
                      shadowColor: Colors.black,
                      elevation: 5,
                      onSurface: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
