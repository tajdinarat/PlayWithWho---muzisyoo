import 'package:firebase_auth/firebase_auth.dart';
import 'package:muzisyo/models/kullanicim.dart';

class YetkilendirmeServisi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? aktifKullaniciId;

  Kullanicim? _kullaniciOlustur(User? kullanicim) {
    return kullanicim == null ? null : Kullanicim.firebasedenUret(kullanicim);
  }

  Stream<Kullanicim?> get durumTakipcisi {
    return _firebaseAuth.authStateChanges().map(_kullaniciOlustur);
  }

  Future<Kullanicim?> mailIleKayit(String eposta, String sifre) async {
    var girisKarti = await _firebaseAuth.createUserWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciOlustur(girisKarti.user);
  }

  Future<Kullanicim?> mailIleGiris(String eposta, String sifre) async {
    var girisKarti = await _firebaseAuth.signInWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciOlustur(girisKarti.user);
  }

  Future<void> sifremiSifirla(String eposta) async {
    await _firebaseAuth.sendPasswordResetEmail(email: eposta);
  }

  Future<void> kullaniciyiYokEtme() async {
    Future deleteUser(String email, String password) async {
      try {
        User user = await _firebaseAuth.currentUser!;
        AuthCredential credentials =
            EmailAuthProvider.credential(email: email, password: password);
        print(user);
        UserCredential result =
            await user.reauthenticateWithCredential(credentials);
        await result.user!.delete();
        return true;
      } catch (e) {
        print(e.toString());
        return null;
      }
    }
  }

  Future<void> cikisYap() {
    return _firebaseAuth.signOut();
  }
}
