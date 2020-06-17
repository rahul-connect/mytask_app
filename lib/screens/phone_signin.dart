import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mytaskapp/config/config.dart';


class PhoneSignInScreen extends StatefulWidget {
  @override
  _PhoneSignInScreenState createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  PhoneNumber _phoneNumber;

  String _message;
  String _verificationId;

  bool isSMSsent = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  final TextEditingController _smsController = TextEditingController();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Phone Sign In")
      ),
      body: SingleChildScrollView(
        child:AnimatedContainer(
          duration: Duration(milliseconds:500),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal:20,vertical:200),
          child: Column(
            children:[
              InternationalPhoneNumberInput(
                onInputChanged: (phoneNumber){
                 _phoneNumber = phoneNumber;
                },
                inputBorder: OutlineInputBorder(),
                initialCountry2LetterCode: 'IN'
            
              ),
            
            isSMSsent?Container(
              margin: EdgeInsets.all(10),
              child: TextField(
                controller: _smsController,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText:"OTP here",
                ),
                maxLength: 6,
                keyboardType: TextInputType.number,

              ),
            ):Container(),

             !isSMSsent? InkWell(
                onTap: (){
                  setState(() {
                    isSMSsent=true;
                  });
                  _verifyPhoneNumber();
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
                        "Send OTP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
              ):InkWell(
                onTap: (){
                  _signInwithPhoneNumber();
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
                        "Verify OTP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
              ),
            ]
          ),
        )
      ),

      
    );
  }
  _verifyPhoneNumber()async{
    setState(() {
      _message = "";
    });

    final PhoneVerificationCompleted vertificationCompleted = (AuthCredential phoneAuthCredential){
      _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _message = "Received phone auth credential : $phoneAuthCredential";
      });
    };

    final PhoneVerificationFailed verificationFailed = (AuthException authException){
      setState(() {
        _message = "Phone verification failed. Code : ${authException.code}. Message:${authException.message}";
      });
    };

    final PhoneCodeSent codeSent = (String verificationId,[int forceResedningToken])async{
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAuthRetrievalTimeout = (String verificationId){
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(phoneNumber: _phoneNumber.phoneNumber, timeout: const Duration(seconds:120), verificationCompleted: vertificationCompleted, verificationFailed: verificationFailed, codeSent: codeSent, codeAutoRetrievalTimeout: codeAuthRetrievalTimeout);
  }

    void _signInwithPhoneNumber() async{
      final AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: _verificationId, smsCode: _smsController.text);

      final FirebaseUser currentUSer = (await _auth.signInWithCredential(credential)).user;

      final FirebaseUser user = await _auth.currentUser();
      
      if(user != null){
        _db.collection("users").document(user.uid).setData({
          "phonenumber":user.phoneNumber,
          "lastseen":DateTime.now(),
          "signin_method":user.providerId,
        });
      }

    }
  

  
}