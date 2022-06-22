import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:muzisyo/services/yetkilendirmeservisi.dart';
import 'package:muzisyo/yonlendirme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<YetkilendirmeServisi>(
      create: (_) => YetkilendirmeServisi(),
      child: MaterialApp(
        title: 'PlayWithWho',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.orange[900],
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
        ),
        home: const Yonlendirme(),
      ),
    );
  }
}
