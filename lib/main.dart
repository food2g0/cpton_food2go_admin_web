import 'package:cpton_food2go_admin_web/authentication/login_screen.dart';
import 'package:cpton_food2go_admin_web/main_screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
        apiKey: "AIzaSyA2RfYmVcKB8pL9i0MKpLOKE1rfRxB32Po",
        authDomain: "foodtogo-b2974.firebaseapp.com",
        databaseURL: "https://foodtogo-b2974-default-rtdb.firebaseio.com",
        projectId: "foodtogo-b2974",
        storageBucket: "foodtogo-b2974.appspot.com",
        messagingSenderId: "82585542874",
        appId: "1:82585542874:web:6af81168a01948492cc5e3",
        measurementId: "G-P1N4CXEMDB"
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
