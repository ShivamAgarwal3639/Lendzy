// ignore_for_file: prefer_typing_uninitialized_variables
// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../notification.dart';

class Otp extends StatefulWidget {
  const Otp({Key? key, this.num}) : super(key: key);
  final num;
  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final _formKey = GlobalKey<FormState>();
  @override
  initState() {
    loginOtp();
    startPeriodic();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer!.cancel();
  }

  var str = "";
  var strOtpTimer = 45;
  String? _verificationId;
  Timer? _timer;
  var index = 0;
  var loading = false;

  Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('user');
      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  startPeriodic() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (strOtpTimer != 0) {
          setState(() {
            strOtpTimer = strOtpTimer - 1;
          });
        }
      });
    });
    if (strOtpTimer == 0) {
      _timer!.cancel();
    }
  }

  loginOtp() async {
    setState(() {
      loading = true;
    });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91 ${widget.num}',
        verificationCompleted: (PhoneAuthCredential credential) {
          log("Completed");
        },
        verificationFailed: (FirebaseAuthException e) {
          log("Failed" + e.toString());
        },
        codeSent: (String verificationId, int? resendToken) async {
          _verificationId = verificationId;
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log("TimeOut");
        },
      );
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _showMyDialogForOtpException(msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 65,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  msg,
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
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xffFE7977)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        'Okay',
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
        );
      },
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  codeSent() async {
    setState(() {
      loading = true;
    });
    try {
      AuthCredential _authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: num);
      try {
        _firebaseAuth
            .signInWithCredential(_authCredential)
            .then((UserCredential value) async {
          if (value.user != null) {
            // Handle logged in state
            bool docExists = await checkIfDocExists(widget.num);
            if (!docExists) {
              FirebaseFirestore.instance
                  .collection('user')
                  .doc(widget.num.toString())
                  .set({
                'kyc': false,
                'kyc_date': Timestamp.now(),
                'chat_lock': Timestamp.now(),
                'userid': value.user!.uid.toString(),
                'phone': widget.num,
                'name': "",
                'email': "",
                'used_limit': "0",
                'limit': "0",
                'date': Timestamp.now(),
                'aadhaar': false,
                'pan': false,
                "video": false,
                "upi": "",
                "upi_name": "",
                "support": false,
                'support_time': Timestamp.now(),
                'support_ack': false,
                'waiting_list': false,
                'deactivated': false,
                'search_num': [
                  "",
                  widget.num.substring(0, 1),
                  widget.num.substring(0, 2),
                  widget.num.substring(0, 3),
                  widget.num.substring(0, 4),
                  widget.num.substring(0, 5),
                  widget.num.substring(0, 6),
                  widget.num.substring(0, 7),
                  widget.num.substring(0, 8),
                  widget.num.substring(0, 9),
                  widget.num.substring(0, 10),
                ],
              }, SetOptions(merge: true));
              QuerySnapshot eventsQuery =
                  await FirebaseFirestore.instance.collection("admin").get();
              for (var document in eventsQuery.docs) {
                NotificationHandler.sendNotification(
                    title: "New Register",
                    body: "There is a new registration from ${widget.num}",
                    to: document["fcm_id"]);
              }
            }

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LandingPage()),
                (Route<dynamic> route) => false);
          } else {
            log("Error validating OTP, try again");
          }
        }).catchError((error) {
          if (error.code == 'invalid-verification-code') {
            _showMyDialogForOtpException(
                "Invalid code please enter correct otp or resend otp.");
          } else {
            _showMyDialogForOtpException(
                "Some Error occurred Please try again.");
          }
        });
      } on FirebaseAuthException catch (e) {
        log(e.toString());
      }
    } catch (e) {
      log("1" + e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  var num = "";
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
                'Verification',
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
                "Enter your OTP code number sent to \n+91 ${widget.num}",
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
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 6 ||
                              value.contains(" ") ||
                              value.contains(",") ||
                              value.contains(".") ||
                              value.contains("-")) {
                            return 'Please enter valid OTP';
                          }
                          return null;
                        },
                        maxLength: 6,
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
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!loading) {
                              if (_formKey.currentState!.validate()) {
                                codeSent();
                              }
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
                            child: loading == true
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Verify',
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
                      )
                    ],
                  ),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Text(
                "Didn't you receive any code?",
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
              strOtpTimer == 0
                  ? InkWell(
                      onTap: () {
                        loginOtp();
                        setState(() {
                          strOtpTimer = 45;
                        });
                      },
                      child: Text(
                        "Resend New Code",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffFE7977),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Text(
                      "Resend Code in $strOtpTimer Sec",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black38,
                        ),
                      ),
                      textAlign: TextAlign.center,
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
