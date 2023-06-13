import 'dart:developer';
import 'dart:io';
import 'package:Lendzy/login/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../page_3_subpage/add_upi_page.dart';
import '../page_3_subpage/faq_page.dart';
// ignore_for_file: prefer_const_constructors

class MyDashboardPage extends StatefulWidget {
  const MyDashboardPage({Key? key}) : super(key: key);

  @override
  _MyDashboardPageState createState() => _MyDashboardPageState();
}

class _MyDashboardPageState extends State<MyDashboardPage> {
  var connection = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    internet();
  }
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Register()),
        (Route<dynamic> route) => false);
  }

  internet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          connection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        connection = false;
      });
    }
  }

  Future<void> refreshData() async {
    internet();
    return await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return !connection
        ? LiquidPullToRefresh(
            onRefresh: refreshData,
            color: Colors.white,
            height: 100,
            backgroundColor: Color(0xff33CCCC),
            animSpeedFactor: 5,
            showChildOpacityTransition: false,
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 60,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Spacer(
                          flex: 8,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.width / 3,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/warning.gif')),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Oops!",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64),
                          child: Text(
                            "Looks Like you are not connected to the internet",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Spacer(
                          flex: 4,
                        ),
                        Row(
                          children: [
                            Spacer(),
                            Text(
                              "Pull to refresh",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_downward_outlined,
                              color: Colors.black,
                              size: 20,
                            ),
                            Spacer(),
                          ],
                        ),
                        Spacer(
                          flex: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddUpiPage(
                                back: false,
                              )),
                    );
                  },
                  title: Text(
                    "UPI Address",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              // Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FAQPage()),
                    );
                  },
                  title: Text(
                    "FAQ",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              // Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: ListTile(
                  onTap: () async {
                    const url =
                        'https://www.lendzy.in/privacy-policy/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      log('Could not launch $url');
                    }
                  },
                  title: Text(
                    "Privacy policy",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: ListTile(
                  onTap: () async {
                    const url =
                        'https://www.lendzy.in/terms-and-conditions/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      log('Could not launch $url');
                    }
                  },
                  title: Text(
                    "Terms & Conditions",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.insert_drive_file_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: ListTile(
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          'Logout!',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _signOut(),
                            child: Text(
                              'OK',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Color(0xffFE7977),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  title: Text(
                    "Logout",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.logout,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              Text(
                "Made in India",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                "V $currentVersionCode+$currentVersion",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      const url =
                          'https://www.instagram.com/lendzy.in/';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        log('Could not launch $url');
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width) / 8,
                      width: (MediaQuery.of(context).size.width) / 8,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                          AssetImage("assets/images/instagram.png"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  InkWell(
                    onTap: () async {
                      const url =
                          'https://www.linkedin.com/company/lendzy/';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        log('Could not launch $url');
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width) / 8,
                      width: (MediaQuery.of(context).size.width) / 8,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                          AssetImage("assets/images/linkedin.png"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  InkWell(
                    onTap: () async {
                      const url =
                          'https://www.youtube.com/channel/UClWJmKFovrsAWEKHhbvoOTw';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        log('Could not launch $url');
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width) / 8,
                      width: (MediaQuery.of(context).size.width) / 8,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                          AssetImage("assets/images/youtube.png"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 24,
              ),
            ],
          );
  }
}
