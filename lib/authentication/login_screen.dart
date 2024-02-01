import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_admin_web/main_screen/home_screen.dart';
import 'package:cpton_food2go_admin_web/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String adminEmail = "";
  String adminPassword = "";

  allowAdminToLogin() async
  {
    SnackBar snackBar = SnackBar(
      content: Text(
        "Checking Credentials, Please wait.... " ,
        style: TextStyle(
            fontSize: 36,
            fontFamily: "Poppins",
            color: AppColors().white
        ),
      ),
      backgroundColor: AppColors().red,
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    User? currentAdmin;
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: adminEmail,
        password: adminPassword).then((fAuth){
          currentAdmin = fAuth.user;
    }).catchError((onError)
    {
      final snackBar = SnackBar(
        content: Text(
            "Error Occured: " + onError.toString(),
        style: TextStyle(
            fontSize: 36,
          fontFamily: "Poppins",
          color: AppColors().white
        ),
        ),
        backgroundColor: AppColors().red,
        duration: const Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    if(currentAdmin != null)
    {
      //check if admin record exist
      await FirebaseFirestore.instance.collection("admins")
          .doc(currentAdmin!.uid)
          .get().then((snap)
      {
        if(snap.exists)
          {
            Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreen()));
          }
        else
        {
          SnackBar snackBar = SnackBar(
            content: Text(
              "No record found..." ,
              style: TextStyle(
                  fontSize: 36,
                  fontFamily: "Poppins",
                  color: AppColors().white
              ),
            ),
            backgroundColor: AppColors().red,
            duration: const Duration(seconds: 5),
          );
        }
      });
    }

  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().black,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // flutter run -d edge --web-renderer html
                  //image
                  Image.asset(
                      "images/admin.png"),

                  TextField(
                    onChanged: (value)
                    {
                      adminEmail = value;
                    },
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors().white,
                      fontFamily: "Poppins"
                    ),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors().red,
                          width: 2,
                        )
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors().red,
                            width: 2,
                          )
                      ),
                      hintText: "Email",
                      hintStyle: TextStyle(
                        color: AppColors().white,
                      ),
                      icon: Icon(
                        Icons.email_outlined,
                        color: AppColors().white,
                      )
                    ),
                  ),

                  SizedBox(height: 10,),

                  TextField(
                    onChanged: (value)
                    {
                      adminPassword= value;
                    },
                    obscureText: true,
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors().white,
                        fontFamily: "Poppins"
                    ),
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors().red,
                              width: 2,
                            )
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors().red,
                              width: 2,
                            )
                        ),
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: AppColors().white,
                        ),
                        icon: Icon(
                          Icons.password_outlined,
                          color: AppColors().white,
                        )
                    ),
                  ),
                  SizedBox(height: 30,),

                  ElevatedButton(onPressed: ()
                  {
                    allowAdminToLogin();
                  },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 100, vertical: 20)),
                        backgroundColor: MaterialStateProperty.all<Color>(AppColors().green),
                        foregroundColor: MaterialStateProperty.all<Color>(AppColors().red),
                      ),
                      child: Text("Login",
                      style: TextStyle(
                        color: AppColors().white,
                        fontSize: 16,
                        fontFamily: "Poppins"
                      ),))
                  
                  
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
