import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:malcolm_erp/screens/homepage.dart';
import 'package:malcolm_erp/screens/signin.dart';
import 'package:malcolm_erp/widgets/pages/SignUp.dart';
import 'package:malcolm_erp/widgets/pages/login.dart';
void main() {
  runApp(const MyApp());
}



final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;
DatabaseReference CatClients = FirebaseDatabase.instance.ref().child("Clients");
DatabaseReference Products = FirebaseDatabase.instance.ref().child("Products");
DatabaseReference clientRequestRef = FirebaseDatabase.instance.ref().child(
    "ClientRequest");

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MALCOM ERP',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),

        initialRoute:
        FirebaseAuth.instance.currentUser == null ? '/SignIn' : '/Homepage',
        routes: {
          "/SignUP": (context) => Signup(),
          // "/OnBoarding": (context) => WelcomePage(),
          "/SignIn": (context) => LoginPage(),
          "/Homepage": (context) => homepage(),
          //    "/addproduct":(context)=>addproduct()
        }
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),

    );
  }


  }

