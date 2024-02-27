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
        apiKey: "AIzaSyBmEiVpraYJvn8chtrCOq4Am5UKJai4FP0",
        authDomain: "food2go-44539.firebaseapp.com",
        projectId: "food2go-44539",
        storageBucket: "food2go-44539.appspot.com",
        messagingSenderId: "844894233705",
        appId: "1:844894233705:web:49791749574c05b7a1eef8",
        measurementId: "G-3LDENK5S0X",
        databaseURL: "https://food2go-44539-default-rtdb.asia-southeast1.firebasedatabase.app"

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
