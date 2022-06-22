import 'package:flutter/material.dart';
import 'package:muzisyo/models/kullanici.dart';
import 'package:muzisyo/models/kullanicim.dart';
import 'package:muzisyo/pages/ana_sayfa.dart';
import 'package:muzisyo/pages/girissayfasi.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class Yonlendirme extends StatelessWidget {
  const Yonlendirme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    return StreamBuilder(
        stream: YetkilendirmeServisi().durumTakipcisi,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData) {
            Kullanicim aktifKullanici = snapshot.data;
            _yetkilendirmeServisi.aktifKullaniciId = aktifKullanici.userId;
            print(aktifKullanici.userId);

            return AnaSayfa(userID: aktifKullanici.userId!);
          } else {
            return const GirisSayfasi();
          }
        });
  }
}
