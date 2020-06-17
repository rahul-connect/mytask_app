import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytaskapp/config/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'phone_signin.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Firestore _db = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(bottom: 50),
            child: Column(children: [
              Container(
                margin: EdgeInsets.only(
                  top: 20.0,
                ),
                child: Image(
                  image: AssetImage("assets/task_logo.png"),
                  width: 200,
                  height: 200,
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(top:20),
              //   child: Text("Login",style: TextStyle(
              //     fontSize:30.0,
              //     fontWeight: FontWeight.bold
              //   ),),
              // ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
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
                padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
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
                    _signIn();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(8)),
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                    child: Center(
                        child: Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    )),
                  )),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EmailPassSignUpScreen()));
                  },
                  child: Text(
                    "Sign up with Email",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              SizedBox(height: 10),
              Divider(),
              Wrap(
                children: [
                  FlatButton.icon(
                      icon: FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.red,
                      ),
                      label: Text("Sign in using Google"),
                      onPressed: () {
                        _signInUsingGoogle();
                      }),
                  FlatButton.icon(
                      icon: Icon(
                        Icons.phone,
                        color: Colors.blue,
                      ),
                      label: Text("Sign in using Phone"),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context)=>PhoneSignInScreen()
                        ));
                      }),
                ],
              )
            ])));
  }

  void _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
       _auth.signInWithEmailAndPassword(
          email: email, password: password).then((user){
          
           
          
          }).catchError((e){
             showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(16)
              ),
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
                borderRadius:BorderRadius.circular(16)
              ),
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


  void _signInUsingGoogle()async{
    try{
          final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential =  GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    
    if(user !=null){
      _db.collection("users").document(user.uid).setData({
        "displayName":user.displayName,
        "email":user.email,
        "photoUrl":user.photoUrl,
        "lastseen":DateTime.now(),
        "signin_method":user.providerId,
      });

    }

    }catch(e){
      return   showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(16)
              ),
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
    }

  }
}
