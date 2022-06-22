import 'package:flutter/material.dart';
import 'package:muzisyo/models/bildirim.dart';
import 'package:muzisyo/models/kullanici.dart';
import 'package:muzisyo/pages/akis.dart';
import 'package:muzisyo/pages/ara.dart';
import 'package:muzisyo/pages/end_drawer.dart';
import 'package:muzisyo/pages/gonderi_ekle.dart';
import 'package:muzisyo/pages/profil.dart';
import 'package:muzisyo/services/firestore_serv.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class AnaSayfa extends StatefulWidget {
  final String userID;
  const AnaSayfa({Key? key, required this.userID}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int aktifSayfaNo = 0;
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    print(widget.userID);
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GonderiEklemeSayfasi(
                          akisMain: aktifSayfaNo,
                          activeUserID: widget.userID,
                        )));
          },
          elevation: 5.0,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.music_note),
        ),
        drawer: getDrawerWidget(widget.userID),
        endDrawer: getEndDrawerWidget(widget.userID),
        // ignore: deprecated_member_use
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 5.0,
          title: Image.asset(
            'assets/PWW_logo.png',
            fit: BoxFit.fill,
            width: 60.0,
            height: 35.0,
          ),
          centerTitle: true,
          actions: [
            IconButton(
                padding: const EdgeInsets.all(10.0),
                splashRadius: 25.0,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Ara())),
                icon: const Icon(
                  Icons.search,
                  size: 30.0,
                )),
            Builder(
              builder: (context) {
                return IconButton(
                  padding: const EdgeInsets.all(10.0),
                  splashRadius: 25.0,
                  //onPressed: Builder(builder: (context)=> getEndDrawerWidget(widget.userID)),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const Icon(Icons.notifications),
                );
              },
            )
          ],
          /*actions: [
            IconButton(
              padding: const EdgeInsets.all(10.0),
              splashRadius: 25.0,
              //onPressed: Builder(builder: (context)=> getEndDrawerWidget(widget.userID)),
              onPressed: Builder(builder: (context)=> Scaffold.of(context).openEndDrawer()),
              icon: const Icon(Icons.music_note),
            ),
          ],*/
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: aktifSayfaNo,
          selectedItemColor: Colors.black,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Gönderiler"),
            BottomNavigationBarItem(
                icon: Icon(Icons.explore), label: "İlanlar"),
          ],
          onTap: (chosenPage) {
            setState(() {
              aktifSayfaNo = chosenPage;
              pageController!.jumpToPage(chosenPage);
            });
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(2.0),
          child: PageView(
            onPageChanged: (acilanSayfaNo) {
              setState(() {
                aktifSayfaNo = acilanSayfaNo;
              });
            },
            controller: pageController,
            children: [
              callPage(0)!,
              callPage(1)!
              /*Akis(ilanMi: false, userID: widget.userID),
              Akis(ilanMi: true, userID: widget.userID),*/
            ],
          ),
        ));
  }

  getEndDrawerWidget(String activeUserID) {
    return EndDrawerWidgetim(activeUserID: activeUserID);
  }

  getDrawerWidget(String activeUserID) {
    return FutureBuilder<Kullanici>(
        future: getUserr(activeUserID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 5.0,
              ),
            );
          }
          Kullanici aktifKisi = snapshot.data!;
          return Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: RichText(
                    text: TextSpan(
                      text: aktifKisi.userRealName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        shadows: [
                          Shadow(offset: Offset(0.1, 0.1)),
                        ],
                      ),
                      children: [
                        TextSpan(
                          text: "  @${aktifKisi.userName}",
                          style: TextStyle(
                            color: Colors.amber[500],
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(offset: Offset(0.1, 0.1)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  accountEmail: RichText(
                    text: TextSpan(
                      text: aktifKisi.userLocation,
                      style: TextStyle(
                        color: Colors.amber[200],
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(offset: Offset(0.1, 0.1)),
                        ],
                      ),
                      children: [
                        TextSpan(
                          text: " - ${aktifKisi.userGroup}",
                          style: TextStyle(
                            color: Colors.amber[200],
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(offset: Offset(0.1, 0.1)),
                            ],
                          ),
                        ),
                        TextSpan(
                          text: " - ${aktifKisi.userPosition}",
                          style: TextStyle(
                            color: Colors.amber[200],
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(offset: Offset(0.1, 0.1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  currentAccountPicture:
                      Image.network(aktifKisi.userProfilePicture!),
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Profil(
                                  profilSahibiId: activeUserID,
                                )));
                      },
                      child: const Text("Profil"),
                    ),
                    TextButton(
                      onPressed: _cikisYap,
                      child: const Text("Çıkış Yap"),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void _cikisYap() {
    Navigator.pop(context);
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }

  Future<Kullanici> getUserr(String id) async {
    Kullanici aktifKullanici = await FireStoreServisi().kullaniciCek(id: id);
    return aktifKullanici;
  }

  Widget? callPage(int _selectedBar) {
    switch (_selectedBar) {
      case 0:
        return Akis(akisTipi: "gonderiler", activeUserID: widget.userID);
      case 1:
        return Akis(akisTipi: "ilanlar", activeUserID: widget.userID);
    }
  }
}
