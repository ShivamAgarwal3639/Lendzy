import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
// ignore_for_file: prefer_const_constructors

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var userNum = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitialData();
  }

  getInitialData() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    setState(() {
      userNum = uid!.substring(3, 13);
    });
    FirebaseFirestore.instance.collection("user").doc(userNum).update({
      'notification_seen': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Notification",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(userNum)
                    .collection("notification")
                    .orderBy('date_time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = snapshot.data!.docs[index];
                          return notificationItems(
                            notId: doc['notification_id'],
                            user: doc['user'],
                            title: doc['title'],
                            disc: doc['disc'],
                            type: doc['type'],
                            dt: doc['date_time'],
                            date: doc['date'],
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  notificationItems({notId, user, title, disc, type, dt, date}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  type == "warning"
                      ? Icons.warning_rounded
                      : type == "success"
                          ? Icons.check_circle
                          : type == "critical"
                              ? Icons.cancel_rounded
                              : Icons.info_rounded,
                  color: type == "warning"
                      ? Color(0xffF75A39)
                      : type == "success"
                          ? Color(0xff01A38F)
                          : type == "critical"
                              ? Color(0xffEFAD6E)
                              : Color(0xff5A34D3),
                  size: 22,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your $type Message - $title",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: type == "warning"
                                ? Color(0xffF75A39)
                                : type == "success"
                                    ? Color(0xff01A38F)
                                    : type == "critical"
                                        ? Color(0xffEFAD6E)
                                        : Color(0xff5A34D3),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        disc,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            height: 1.1,
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            Jiffy(DateTime.parse(date)).fromNow(),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: Colors.black26,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
