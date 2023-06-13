import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_review/launch_review.dart';
import '../main.dart';
import 'otp.dart';
// ignore_for_file: prefer_const_constructors

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var num = "";
  final _formKey = GlobalKey<FormState>();
  var phoneLock = false;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;


  var upgradeLock = 0;
  var noNewUsers = false;

  @override
  void initState() {
    super.initState();
    _saveDeviceToken();
    checkForUpdate();
  }

  checkForUpdate() async {
    var collection1 = FirebaseFirestore.instance.collection('settings');
    var docSnapshot1 = await collection1.doc('settingsData').get();
    if (docSnapshot1.exists) {
      Map<String, dynamic>? data = docSnapshot1.data();
      var value1 = data?['critical_up'];
      var value2 = data?['no_new_user'];
      if (mounted) {
        setState(() {
          upgradeLock = value1;
          noNewUsers = value2;
        });
      }
    }
    if (upgradeLock > currentVersion) {
      _showMyDialogForUpdate();
    }
  }

  Future<void> _showMyDialogForUpdate() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            // title: const Text('AlertDialog Title'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(
                    Icons.upgrade,
                    size: 65,
                    color: Color(0xffFE7177),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "We have a major upgrade.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cabin(
                      textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: ElevatedButton(
                      onPressed: () {
                        LaunchReview.launch();
                        // Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xffFE7177)),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          'Upgrade',
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _saveDeviceToken() async {
    var collection1 = FirebaseFirestore.instance.collection('settings');
    var docSnapshot1 = await collection1.doc('settingsData').get();
    if (docSnapshot1.exists) {
      Map<String, dynamic>? data = docSnapshot1.data();
      var value1 = data?['stop_login'];
      if (mounted) {
        setState(() {
          phoneLock = value1;
        });
      }
    }
  }

  submit(){
    if (!phoneLock) {
      if (_formKey.currentState!.validate()) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => Otp(num: num)),
        );
      }
    } else {
      final snackBar = SnackBar(
        content: Text(
          'Currently, You are ineligible to sign in, Try after sometime.',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 96,
              ),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/images/logo_png.png"),
                )),
              ),
              Spacer(
                flex: 1,
              ),
              Text(
                'Registration',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Text(
                "Add your phone number. we'll send you a verification code so we know you're real",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(
                flex: 1,
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 10 ||
                              value.contains(" ") ||
                              value.contains(",") ||
                              value.contains(".") ||
                              value.contains("-")) {
                            return 'Please enter valid Number';
                          }
                          return null;
                        },
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onChanged: (str) {
                          setState(() {
                            num = str;
                          });
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8)),
                          prefix: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '(+91)',
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async{
                            String? fcmToken = await _fcm.getToken();
                            if(noNewUsers){
                              var collection1 = FirebaseFirestore.instance.collection('user');
                              var docSnapshot1 = await collection1.doc(num).get();
                              if (docSnapshot1.exists) {
                                submit();
                              }else{
                                FirebaseFirestore.instance
                                    .collection('alert_new')
                                    .doc(num.toString())
                                    .set({
                                  'num': num,
                                  'data_time': Timestamp.now(),
                                  'done': false,
                                  'fcm': fcmToken.toString(),
                                }, SetOptions(merge: true));
                                final snackBar = SnackBar(
                                  content: Text(
                                    'Currently we are facing technical issues. We will notify you once we are back.',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  action: SnackBarAction(
                                    label: 'Ok',
                                    onPressed: () {
                                      // Some code to undo the change.
                                    },
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }else{
                              submit();
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xffFE7977)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Text(
                              'Send',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(
                flex: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
