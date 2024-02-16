
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:malcolm_erp/screens/signin.dart';

import '../main.dart';
import '../progressDialog.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}
TextEditingController _emailcontroller = TextEditingController();
TextEditingController _usernamecontroller = TextEditingController();
TextEditingController _phonecontroller = TextEditingController();
TextEditingController _passwordcontroller = TextEditingController();

class _signupState extends State<signup> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery
        .of(context)
        .size;
    return   Scaffold(
      // appBar: AppBar(
      //   title: Text("Login Page"),
      // ),
      body: Center(
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
                  padding: const EdgeInsets.only(top:10,left: 18.0),
                  child: Text("Sign Up",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold),),
                ),

              ],
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Text("Sign Up to continue using the app",style: TextStyle(fontSize: 12,color: Colors.grey)),
                ),
              ],
            ),


            Column(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                // Padding(
                //   padding: EdgeInsets.only(
                //     top: size.width * .1,
                //     bottom: size.width * .1,
                //   ),
                //   child: SizedBox(
                //     height: 70,
                //     child: Image.asset(
                //       'assets/images/logo.png',
                //       // #Image Url: https://unsplash.com/photos/bOBM8CB4ZC4
                //       fit: BoxFit.fitHeight,
                //     ),
                //   ),
                // ),

                //Username

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        width: size.width /2.2,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.white.withOpacity(.9),
                          ),
                          controller: _usernamecontroller,
                          // onChanged: (value){
                          //   _firstName = value;
                          // },
                          // obscureText: isPassword,
                          // keyboardType: isEmail ? TextInputType.name : TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.account_circle_outlined,
                              color: Colors.white.withOpacity(.8),
                            ),
                            border: InputBorder.none,
                            hintMaxLines: 1,
                            hintText:'UserName',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        width: size.width / 2.2,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.white.withOpacity(.9),
                          ),
                          controller: _phonecontroller,
                          // onChanged: (value){
                          //   _phonecontroller = value as TextEditingController;
                          // },

                          keyboardType:  TextInputType.phone ,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.white.withOpacity(.9),
                            ),
                            border: InputBorder.none,
                            hintMaxLines: 1,
                            hintText: 'Phone Number...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                //email
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        width: size.width / 2.2,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.white.withOpacity(.9),
                          ),
                          controller: _emailcontroller,
                          // onChanged: (value){
                          //   _emailcontroller = value as TextEditingController;
                          // },
                          // obscureText: isPassword,
                          keyboardType:  TextInputType.emailAddress ,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white.withOpacity(.8),
                            ),
                            border: InputBorder.none,
                            hintMaxLines: 1,
                            hintText: 'Email...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    //pass
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        width: size.width / 2.2,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.white.withOpacity(.9),
                          ),
                          controller: _passwordcontroller,
                          obscureText: true,
                          // onChanged: (value){
                          //   _passwordcontroller=value as TextEditingController;
                          // },
                          // keyboardType: isPassword ? TextInputType.name : TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.password,
                              color: Colors.white.withOpacity(.8),
                            ),
                            border: InputBorder.none,
                            hintMaxLines: 1,
                            hintText: 'Password...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Date of Birth
                Column(
                  children: [



                  ],
                ),





                SizedBox(height: size.width * 0.019),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                 // registerInfirestore(context);
                  registerNewUser(context);
                    HapticFeedback.lightImpact();

                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: size.width * .05,
                    ),
                    height: size.width / 8,
                    width: size.width / 1.25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:  Color(0xFFF169F00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sign-up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:9.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already Signed-Up,Login?',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => signin(),
                            ),);
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


          ],
        ),
      ),
    );;
  }
  User ?firebaseUser;
  User? currentfirebaseUser;
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
        email: _emailcontroller.text,
        password: _passwordcontroller.text,)
        .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) // user created

        {
      //save use into to database
      await firebaseUser?.sendEmailVerification();
      Map userDataMap = {

        "email": _emailcontroller.text.trim(),
        "Username":_usernamecontroller.text.trim(),
        "phone": _phonecontroller.text.trim(),
        "Password": _passwordcontroller.text.trim(),
        // 'Date Of Birth': selectedDate!.toLocal().toString().split(' ')[0],
        // "Dob":birthDate,
        // "Gender":Gender,
      };
      clients.child(firebaseUser!.uid).set(userDataMap);
      // Admin.child(firebaseUser!.uid).set(userDataMap);

      currentfirebaseUser = firebaseUser;
      // registerInfirestore(context);
      displayToast("Congratulation, your account has been created", context);
      // displayToast("A verification has been sent to your mail", context);


      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => signin()),
              (Route<dynamic> route) => false);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return signin();
        }),
      );
      // Navigator.pop(context);
      //error occured - display error
      displayToast("user has not been created", context);
    }
  }

  // Future<void> registerInfirestore(BuildContext context) async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if(user!=null) {
  //     FirebaseFirestore.instance.collection('Members').doc(user.uid).set({
  //       'firstName': _firstName,
  //       'lastName': _lastname,
  //       'MobileNumber': _mobileNumber,
  //       'fullName':_firstName! +  _lastname!,
  //       'Email': _email,
  //       'Password':_password,
  //       // 'Gender': Gender,
  //       // 'Date Of Birth': birthDate,
  //     });
  //   }
  //   print("Registered");
  //   // Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(builder: (context) {
  //   //     return SignInScreen();
  //   //   }),
  //   // );
  //
  //
  // }
  displayToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);

// user created

  }
}
