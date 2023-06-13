import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';
// ignore_for_file: prefer_const_constructors

class PermissionHandler extends StatefulWidget {
  const PermissionHandler({Key? key}) : super(key: key);

  @override
  _PermissionHandlerState createState() => _PermissionHandlerState();
}

class _PermissionHandlerState extends State<PermissionHandler> {
  var value1 = false;
  var value2 = false;
  var value3 = false;
  var value4 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();
  }

  getPermission() async {
    var s1 = await Permission.location.isGranted;
    var s2 = await Permission.contacts.isGranted;
    var s3 = await Permission.sms.isGranted;
    var s4 = await Permission.camera.isGranted;
    if (mounted) {
      setState(() {
        value1 = s1;
        value2 = s2;
        value3 = s3;
        value4 = s4;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Container(
          width: 32 * 3.00293255,
          height: 32,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/logo_png.png')),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 4, right: 8),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Column(
              children: [
                Spacer(
                  flex: 3,
                ),
                Text(
                  "Permissions",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Spacer(
                  flex: 3,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/smartphone.gif')),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleText("Location"),
                              descText(
                                  "We require your location while we undergo KYC."),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                            ),
                            CupertinoSwitch(
                                value: value1,
                                activeColor: Color(0xff33CCCC),
                                onChanged: (bool value) async {
                                  if (!await Permission.location.isGranted) {
                                    var status = await Permission.location.request();
                                    if (status.isGranted) {
                                      if (mounted){
                                        setState(() {
                                          value1 = value;
                                        });
                                      }
                                    } else if (status.isPermanentlyDenied) {
                                      await openAppSettings();
                                    } else if (status.isRestricted) {
                                      await openAppSettings();
                                    } else if (status.isLimited) {
                                      await openAppSettings();
                                    }
                                  } else {
                                    if (mounted){
                                      setState(() {
                                        value1 = value;
                                      });
                                    }
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(
                  flex: 2,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/phone.gif')),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleText(
                                "Contacts",
                              ),
                              descText(
                                "We need your contacts to provide better credit limit.",
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                            ),
                            CupertinoSwitch(
                                value: value2,
                                activeColor: Color(0xff33CCCC),
                                onChanged: (bool value) async {
                                  if (!await Permission.contacts.isGranted) {
                                    var status =
                                        await Permission.contacts.request();
                                    if (status.isGranted) {
                                      if (mounted){
                                        setState(() {
                                          value2 = value;
                                        });
                                      }
                                    } else if (status.isPermanentlyDenied) {
                                      await openAppSettings();
                                    } else if (status.isRestricted) {
                                      await openAppSettings();
                                    } else if (status.isLimited) {
                                      await openAppSettings();
                                    }
                                  } else {
                                    if (mounted){
                                      setState(() {
                                        value2 = value;
                                      });
                                    }
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(
                  flex: 2,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/message.gif')),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleText(
                                "Messages",
                              ),
                              descText(
                                "To track financial transaction and related activities.",
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                            ),
                            CupertinoSwitch(
                                value: value3,
                                activeColor: Color(0xff33CCCC),
                                onChanged: (bool value) async {
                                  if (!await Permission.sms.isGranted) {
                                    var status = await Permission.sms.request();
                                    if (status.isGranted) {
                                      if (mounted){
                                        setState(() {
                                          value3 = value;
                                        });
                                      }
                                    } else if (status.isPermanentlyDenied) {
                                      await openAppSettings();
                                    } else if (status.isRestricted) {
                                      await openAppSettings();
                                    } else if (status.isLimited) {
                                      await openAppSettings();
                                    }
                                  } else {
                                    if (mounted){
                                      setState(() {
                                        value3 = value;
                                      });
                                    }
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(
                  flex: 2,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/camera.gif')),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleText(
                                "Camera",
                              ),
                              descText(
                                "For KYC verification and to prove your identity.",
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                            ),
                            CupertinoSwitch(
                                value: value4,
                                activeColor: Color(0xff33CCCC),
                                onChanged: (bool value) async {
                                  if (!await Permission.camera.isGranted) {
                                    var status = await Permission.camera.request();
                                    if (status.isGranted) {
                                      if (mounted){
                                        setState(() {
                                          value4 = value;
                                        });
                                      }
                                    } else if (status.isPermanentlyDenied) {
                                      await openAppSettings();
                                    } else if (status.isRestricted) {
                                      await openAppSettings();
                                    } else if (status.isLimited) {
                                      await openAppSettings();
                                    }
                                  } else {
                                    if (mounted){
                                      setState(() {
                                        value4 = value;
                                      });
                                    }
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(
                  flex: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      Text(
                        'Note:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cabin(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                      Text(
                        'Please accept all the permissions to go to the home page.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cabin(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(
                  flex: 16,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Navigator.of(context).pop();
                      var status = await Permission.contacts.isGranted;
                      var status1 = await Permission.sms.isGranted;
                      var status2 = await Permission.camera.isGranted;
                      var status3 = await Permission.location.isGranted;
                      if (status && status1 && status2 && status3) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => BasicBottomNavBar()),
                            (Route<dynamic> route) => false);
                      } else {
                        final snackBar = SnackBar(
                          content: Text(
                            'Please give all the required permissions to Proceed.',
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
                            onPressed: () {},
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
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
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Text(
                        'Done',
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
                Spacer(
                  flex: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  titleText(txt) {
    return Text(
      txt,
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  descText(desc) {
    return Text(
      desc,
      maxLines: 2,
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
