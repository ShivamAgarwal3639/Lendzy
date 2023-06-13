import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:developer' as dev;
import '../ad_helper.dart';
import '../notification.dart';
// ignore_for_file: prefer_const_constructors

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  var userNum = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  // TODO: Add _bannerAd
  late BannerAd _bannerAd;

  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          dev.log('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
    getInitialData();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  Timestamp lockedTime =  Timestamp.now();

  getInitialData() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    setState(() {
      userNum = uid!.substring(3, 13);
    });
    var collection = FirebaseFirestore.instance.collection('user');
    var docSnapshot = await collection.doc(uid!.substring(3, 13)).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var kycD = data?['chat_lock'];
      if (mounted) {
        setState(() {
          lockedTime = kycD;
        });
      }
      // dev.log(lockedTime!.toDate().difference(DateTime.now()).inMinutes>0?);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          if (_isBannerAdReady)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(userNum)
                    .collection("support")
                    .orderBy('date_time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = snapshot.data!.docs[index];
                          return message(
                            sId: doc['support_id'],
                            uNum: doc['user_num'],
                            msg: doc['message'],
                            type: doc['type'],
                            user: doc['user'],
                            dateTime: doc['date_time'],
                            date: doc['date'],
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
          chatInputField(),
        ],
      ),
    );
  }

  chatInputField() {
    return lockedTime.toDate().difference(DateTime.now()).inMinutes > 0
        ? Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 32,
                  color: Color(0xffFE7977).withOpacity(0.08),
                ),
              ],
            ),
            child: Text(
              "You have been blocked by our Support team \nfor 24 hrs for violating "
              "our guidelines you can mail us at support@lendzy.in",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    height: 1.2,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,),),
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 32,
                  color: Color(0xffFE7977).withOpacity(0.08),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Color(0xffFE7977).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: "Type message",
                                hintStyle: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black38)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Color(0xffFE7977),
                      size: 30,
                    ),
                    onPressed: () async {
                      getInitialData();
                      if (_controller.text != "") {
                        var supId = getRandomString(12);
                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(userNum)
                            .collection("support")
                            .doc(supId)
                            .set({
                          'support_id': supId,
                          'user_num': userNum,
                          'message': _controller.text,
                          'date_time': Timestamp.now(),
                          'type': 'text',
                          'user': true,
                          'date': DateTime.now().toString(),
                        });

                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(userNum)
                            .update({
                          "support": true,
                          'support_time': Timestamp.now(),
                          'support_ack': false,
                        });
                        _controller.clear();
                        FocusManager.instance.primaryFocus?.unfocus();

                        QuerySnapshot eventsQuery = await FirebaseFirestore
                            .instance
                            .collection("admin")
                            .get();
                        for (var document in eventsQuery.docs) {
                          NotificationHandler.sendNotification(
                              title: "New Support request",
                              body: "There is a new message from $userNum",
                              to: document["fcm_id"]);
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      title: Text(
        "Customer Support",
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  message({sId, uNum, msg, type, user, dateTime, date}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            user ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!user) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black54,
              child: Icon(
                Icons.support_agent,
                color: Color(0xffE9E9E8),
                size: 25,
              ),
            ),
            SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .75,
                ),
                decoration: BoxDecoration(
                  color: !user ? Color(0xffE9E9E8) : Color(0xffFE7977),
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                        user ? Radius.circular(12.0) : Radius.circular(0.0),
                    bottomRight:
                        user ? Radius.circular(0.0) : Radius.circular(12.0),
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: Text(
                  msg,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: user ? Colors.white : Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Text(
                Jiffy(DateTime.parse(date)).fromNow(), // in 5 hours,
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
    );
  }
}
