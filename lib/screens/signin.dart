import 'package:malcolm_erp/Assistant/assistantMethods.dart';
import 'package:malcolm_erp/progressdialog.dart';
import 'package:malcolm_erp/screens/signup.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'dart:math';

import '../main.dart';
import 'homepage.dart';

class signin extends StatefulWidget {
  const signin({super.key});

  @override
  State<signin> createState() => _signinState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
// final GoogleSignIn googleSignIn = GoogleSignIn();
final DatabaseReference _userRef =
    FirebaseDatabase.instance.reference().child('users');
TextEditingController phoneNumberController = TextEditingController();
TextEditingController emailcontroller = TextEditingController();
TextEditingController passwordcontroller = TextEditingController();
// Define googleSignIn here

String? phoneNumber;
String? verificationId;
String? smsCode;

Future<void> verifyPhoneNumber() async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      print('Authentication successful');
    },
    verificationFailed: (FirebaseAuthException e) {
      print('Failed to verify phone number: ${e.message}');
    },
    codeSent: (String? verificationId, int? resendToken) {
      // +233
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // Timeout handling if needed
    },
  );
}

Future<void> writeEmailToDatabase(String userId, String email) async {
  // Write the email to the database under the user's ID
  _userRef.child(userId).set({'email': email});
}

Future<bool> checkIfEmailExistsInDatabase(String email) async {
  DatabaseEvent snapshot =
      await _userRef.orderByChild('email').equalTo(email).once();
  var data = snapshot.snapshot.value;

  return data != null;
}

class _signinState extends State<signin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // requestSmsPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "login",
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text("Login Page"),
        // ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
             Container(
              width: 159.0, // Adjust the width as needed
              height: 120, // Adjust the height as needed
              child: Image.asset(
                'assets/images/logo.png',
              ),),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 18.0),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text("Login to continue using the app",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.grey,
                      ),
                      filled: true,
                      // Set filled to true for a grey background
                      fillColor: Colors.grey[200],
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Colors.grey), // Set the border color to grey
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Colors
                                .grey), // Set the border color to grey when focused
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 1,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: passwordcontroller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.password,
                        color: Colors.grey,
                      ),
                      filled: true,

                      // Set filled to true for a grey background
                      fillColor: Colors.grey[200],
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Colors.grey), // Set the border color to grey
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Colors
                                .grey), // Set the border color to grey when focused
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 12),
                      child: RichText(
                        text: TextSpan(
                          text: 'Forgotten password?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 19
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _showMyDialog();
                              HapticFeedback.lightImpact();
                              Fluttertoast.showToast(
                                msg: 'Forgotten password! button pressed',
                              );
                            },
                        ),
                      ),
                    ),
                  ],
                ),
                // Implement Apple sign-in button here using the `flutter_apple_sign_in` package.
                Padding(
                  padding: const EdgeInsets.only(top: 21.0),
                  child: SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF169F00)),
                      onPressed: () {
                        loginAndAuthenticateUser(context);
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'New User? Sign up',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => signup(),
                                ),
                              );
                              HapticFeedback.lightImpact();
                              // Fluttertoast.showToast(
                              //   msg:
                              //   '',
                              // );
                            },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  // final FirebaseAuth _aut= FirebaseAuth.instance;

  final Random random = Random();


  String? _verificationCode;
  //
  // Future<void> sendMS(String message) async {
  //   List<String> recipients = [phoneNumberController.text];
  //   print("rarrr" + '${recipients}');
  //   print("message" + '${message}');
  //   try {
  //     await sendSMS(
  //       message: message,
  //       recipients: recipients,
  //       sendDirect: true, // Set this to true for immediate sending
  //     );
  //
  //     // Show a toast message to indicate success.
  //     Fluttertoast.showToast(
  //       msg: "Verification code sent!",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //
  //     // Navigate to the verification screen with the verification code.
  //     Navigator.pushNamed(
  //       context,
  //       '/verify',
  //       arguments: _verificationCode.toString(),
  //     );
  //   } catch (error) {
  //     // Show a toast message for the error.
  //     Fluttertoast.showToast(
  //       msg: "Failed to send verification code.",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //   }
  // }
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

    Future signInWithEmailAndPassword(String email, String password) async {
      try {
        UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
            email: emailcontroller.text.trim(), password: passwordcontroller.text.trim());
        User? user = result.user;
        return _firebaseAuth;
      } catch (error) {
        print(error.toString());
        return null;
      }
    }

    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailcontroller.text.trim(),
                password: passwordcontroller.text.trim())
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
              email: emailcontroller.text.trim(), password: passwordcontroller.text.trim());

     if (clients != null) {
       AssistantMethod.getCurrentOnlineUserInfo(context);

        Navigator.of(context).pushNamed("/Homepage");

        displayToast("Logged-in ", context);
      } else {
        displayToast("Error: Cannot be signed in", context);
      }
    } catch (e) {
      // handle error
    }
  }

  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);


  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password?'),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Text('Enter your email to set a new password'),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.grey,
                      ),
                      filled: true,
                      // Set filled to true for a grey background
                      fillColor: Colors.white,
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Colors.grey), // Set the border color to grey
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Colors
                                .grey), // Set the border color to grey when focused
                      ),
                    ),
                  ),
                ),





              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'SEND',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                print('yes');
                FirebaseAuth.instance.signOut();
                resetPassword(context);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'CANCEL',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future resetPassword(BuildContext context) async{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailcontroller.text.trim());

    displayToast("Your Reset Request is sent.Check your email.",context);
  }
//

}
