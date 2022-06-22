import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muzisyo/services/firestore_serv.dart';
import 'package:muzisyo/services/storage_serv.dart';

// ignore: must_be_immutable
class GonderiEklemeSayfasi extends StatefulWidget {
  int akisMain;
  String activeUserID;
  // ignore: use_key_in_widget_constructors
  GonderiEklemeSayfasi({required this.akisMain, required this.activeUserID});

  @override
  _GonderiEklemeSayfasiState createState() => _GonderiEklemeSayfasiState();
}

class _GonderiEklemeSayfasiState extends State<GonderiEklemeSayfasi> {
  File? dosya;
  bool yuklenmekte = false;
  bool ilanMi = false;
  TextEditingController textKumandasi = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.akisMain == 0) {
      ilanMi = false;
    } else if (widget.akisMain == 1) {
      ilanMi = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 5.0,
        title: const Text("Ekleme"),
        leading: IconButton(
          splashRadius: 15.0,
          onPressed: () {
            dosya = null;
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: dosya == null ? fileIsNotUploaded() : fileIsUploaded(),
    );
  }

  Column fileIsUploaded() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              yuklenmekte
                  ? const LinearProgressIndicator()
                  : const SizedBox(height: 0.0),
              AspectRatio(
                aspectRatio: 16.0 / 9.0,
                child: Image.file(dosya!, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: textKumandasi,
                  minLines: 1,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: "Açıklama:",
                      contentPadding: EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                      )),
                ),
              ),
              TextButton(
                  onPressed: () => gonderiYarat(),
                  child: const Text(
                    "PAYLAŞ",
                    style: TextStyle(fontSize: 18),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  void gonderiYarat() async {
    if (!yuklenmekte) {
      setState(() {
        yuklenmekte = true;
      });

      String yuklenenResimUrl = await StorageServisi().gonderiResmiYukle(
        resimDosyasi: dosya!,
        ilanMi: ilanMi,
        userID: widget.activeUserID,
      );

      String postParagraf = textKumandasi.text;
      await FireStoreServisi().gonderiOlustur(
          gonderiResmiURL: yuklenenResimUrl,
          yazarID: widget.activeUserID,
          paragraf: postParagraf,
          ilanMi: ilanMi);

      setState(() {
        yuklenmekte = false;
        textKumandasi.clear();
        dosya = null;
      });
    }
    print("gonderi yaratıldı");
  }

  Widget fileIsNotUploaded() {
    return Center(
      child: IconButton(
          iconSize: 100.0,
          onPressed: () {
            fotoSec();
          },
          icon: const Icon(
            Icons.file_upload,
            size: 40.0,
          )),
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
        dosya = File(image.path);
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
        dosya = File(image.path);
      });
    }
  }
}
