import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytaskapp/config/config.dart';

class EmailPassSignUpScreen extends StatefulWidget {
  @override
  _EmailPassSignUpScreenState createState() => _EmailPassSignUpScreenState();
}

class _EmailPassSignUpScreenState extends State<EmailPassSignUpScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up"), centerTitle: true),
      body: SingleChildScrollView(
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: Image(
                    image: AssetImage("assets/task_logo.png"),
                    width: 250,
                    height: 250,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Email",
                      hintText: "Enter email here...",
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.only(top: 10.0),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password",
                      hintText: "Enter password here...",
                    ),
                    obscureText: true,
                  ),
                ),
                InkWell(
                    onTap: () {
                      _signUp();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      margin:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                      child: Center(
                          child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      )),
                    )),
              ]))),
    );
  }

  void _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) {
            _db.collection("users").document(user.user.uid).setData({
              "email":user.user.email,
              "lastseen": DateTime.now(),
              "signin_method":user.user.providerId,
            });

          })
          .catchError((e) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text("Error"),
                content: Text(e.toString()),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text("OK"))
                ],
              );
            });
      });
    } else {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text("Error"),
              content: Text("Please provide valid email and password..."),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text("OK"))
              ],
            );
          });
    }
  }
}
