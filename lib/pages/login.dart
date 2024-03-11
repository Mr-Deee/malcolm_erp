import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malcolm_erp/Assistant/assistantmethods.dart';
import 'package:malcolm_erp/pages/EmployeeTill.dart';

import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../progressDialog.dart';
import 'SignUp.dart';
import 'homepage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();

  // text editing controllers
  final passwordController = TextEditingController();

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
              image: AssetImage('assets/images/backj.jpg'),
              // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  Text("MALCOLM ERP",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Center(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(0, 0, 0, 1)
                                  .withOpacity(_opacity),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30))),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Form(
                            key: _formKey,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Row(
                                    children: [
                                      Text("Log in",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 30,),
                                  MyTextField(
                                    controller: emailController,
                                    hintText: 'email',
                                    obscureText: false,
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  MyTextField(
                                    controller: passwordController,
                                    hintText: 'Password',
                                    obscureText: true,
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  MyButtonAgree(
                                    text: "Continue",
                                    onTap: () {
                                      loginAndAuthenticateUser(context);
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left:148.0),
                                    child: Text('Forgot Password?',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                        textAlign: TextAlign.start),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          // ignore: prefer_const_literals_to_create_immutables
                                          children: [
                                            Text(
                                              'Don\'t have an account?',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 15),
                                              textAlign: TextAlign.start,
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Signup()));
                                              },
                                              child: const Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
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

  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Logging you ,Please wait.",
          );
        });
     AssistantMethod.getCurrentOnlineUserInfo(context);
    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
      email: emailController.text.toString().trim(),
      password: passwordController.text.toString().trim(),
    )
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      //
      // if (email.text == "merchantdaniel8@gmail.com") {
      //   Navigator.of(context).pushNamed("/admin");
      // } else

      if (firebaseUser != null) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => homepage()),
            (Route<dynamic> route) => false);
        displayToast("Logged-in ", context);
      } else {
        displayToast("Error: Cannot be signed in", context);
      }

      //final User? firebaseUser = userCredential.user;
      // if (firebaseUser != null) {
      //   final DatabaseEvent event = await
      //   //Admin.child(firebaseUser.uid).once();
      //   BoardMembers.child(firebaseUser.uid).once();
      //   // if (event.snapshot.value !=Admin) {
      //   //   Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen,
      //   //           (route) => false);
      //   //   displayToast("Logged-in As Admin", context);
      //   // }
      //   if(event.snapshot.value !=BoardMembers){
      //     Navigator.pushNamedAndRemoveUntil(context, VotersScreen.idScreen,
      //             (route) => false);
      //     displayToast("Logged-in As Board Member",
      //         context);
      //    // await _firebaseAuth.signOut();
      //   }
    } catch (e) {
      // handle error
    }
  }
}
