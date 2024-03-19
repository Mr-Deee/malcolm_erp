import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:malcolm_erp/pages/Admin.dart';
import 'package:malcolm_erp/pages/EmployeeTill.dart';
import 'package:malcolm_erp/pages/SignUp.dart';
import 'package:malcolm_erp/pages/homepage.dart';
import 'package:malcolm_erp/pages/login.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/Admin.dart';
import 'models/Users.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.delayed(Duration(seconds: 2)); // Adjust the duration as needed
  // FlutterNativeSplash.remove();
  runApp((MultiProvider(providers: [
    ChangeNotifierProvider<Users>(
      create: (context) => Users(),
    ),
    ChangeNotifierProvider<Admin>(
      create: (context) => Admin(),
    ),
  ], child: MyApp())));
}

final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;
DatabaseReference CatClients = FirebaseDatabase.instance.ref().child("users");
DatabaseReference Products = FirebaseDatabase.instance.ref().child("Products");
DatabaseReference clientRequestRef = FirebaseDatabase.instance.ref().child("ClientRequest");

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

        title: 'MALCOM ERP',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),

        initialRoute:
            FirebaseAuth.instance.currentUser == null ? '/SignIn' : '/Homepage',
            //'/Homepage',
        routes: {
          "/SignUP": (context) => Signup(),
          "/Admin": (context) => Adminpage(),
          "/SignIn": (context) => LoginPage(),
          "/Employee": (context) => employeetill(),
          "/Homepage": (context) => homepage(),
          //    "/addproduct":(context)=>addproduct()
        }
        //home: const MyHomePage(title: 'Flutter Demo Home Page'),

        );
  }
}
