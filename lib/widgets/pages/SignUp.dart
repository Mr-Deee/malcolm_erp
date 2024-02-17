import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../../main.dart';
import '../progressDialog.dart';
import 'homepage.dart';
import 'login.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  User? firebaseUser;
  User? currentfirebaseUser;

  // text editing controllers
  final emailController = TextEditingController();
  final companyNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final locationController = TextEditingController();

  double _sigmaX = 5; // from 0-10
  double _sigmaY = 5; // from 0-10
  double _opacity = 0.2;
  double _width = 350;
  double _height = 300;
  final _formKey = GlobalKey<FormState>();

  // sign user in method
  void signUserIn() {
    if (_formKey.currentState!.validate()) {
      print('valid');
    } else {
      print('not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage("assets/images/backj.jpg"),
    fit: BoxFit.cover,
    ),),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top:28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.black87,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                    ),
                  ],
                ),
              ),

              //
              // Image(
              //   image: AssetImage(
              //     'assets/images/backj.jpg',
              //   ),
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height,
              //   fit: BoxFit.cover,
              // ),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: const Text("Malcom's ERP",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 40,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),




                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: const Text("Sign Up",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Center(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 0, 0, 1)
                                  .withOpacity(_opacity),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30))),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.49,
                          child: Form(
                            key: _formKey,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // const Text(
                                  //     "Look like you don't have an account. Let's create a new account for",
                                  //     // ignore: prefer_const_constructors
                                  //     style: TextStyle(
                                  //         color: Colors.white, fontSize: 20),
                                  //     textAlign: TextAlign.start),
                                  // // ignore: prefer_const_constructors
                                  // const Text(
                                  //   "jane.doe@gmail.com",
                                  //   style: TextStyle(
                                  //       color: Colors.white,
                                  //       fontSize: 20,
                                  //       fontWeight: FontWeight.bold),
                                  //   textAlign: TextAlign.start,
                                  // ),
                                  const SizedBox(height: 30),
                                  MyTextField(
                                    controller: companyNameController,
                                    hintText: 'CompanyName',
                                    obscureText: false,
                                  ),
                                  const SizedBox(height: 10),
                                  MyTextField(
                                    controller: emailController,
                                    hintText: 'Email',
                                    obscureText: false,
                                  ),

                                  const SizedBox(height: 10),
                                  MyPasswordTextField(
                                    controller: passwordController,
                                    hintText: 'Password',
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 10),
                                  MyTextField(
                                    controller: locationController,
                                    hintText: 'Location',
                                    obscureText: false,
                                  ),
                                  const SizedBox(height: 10),

                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [


                                      MyButtonAgree(
                                        text: "Sign Up",
                                        onTap: () {
                                          registerNewUser(context);
                                          registerInfirestore(context);
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             LoginPage()));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Registering,Please wait.....",
          );
        });

    firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) // user created

    {
      //save use into to database

      Map userDataMap = {
        // "time":time,
        "CompanyName": companyNameController.text.trim(),
        "CompanyPhone": phoneNumberController.text.trim(),
        "email": emailController.text.trim(),
        "Password": passwordController.text.trim(),
        "Location":locationController.text.toString()
        // "Gender":Gender,
      };
      CatClients.child(firebaseUser!.uid).set(userDataMap);
      // Admin.child(firebaseUser!.uid).set(userDataMap);

      currentfirebaseUser = firebaseUser;
      registerInfirestore(context);
      displayToast("Congratulation, your account has been created", context);

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false);
    } else {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) {
      //     return login();
      //   }),
      // );      // Navigator.pop(context);
      //error occured - display error
      displayToast("user has not been created", context);
    }
  }

  Future<void> registerInfirestore(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        // 'MobileNumber': _mobileNumber.toString().trim(),
        // 'fullName':_firstName! +  _lastname!,
        'Email': emailController.toString().trim(),
        'Password': passwordController.toString().trim(),
        // 'Gender': Gender,
        // 'Date Of Birth': birthDate,
      });
    } else
      print("shit");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) {
    //     return SignInScreen();
    //   }),
    // );
  }
}
