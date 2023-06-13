import 'dart:async';
import 'dart:io';
import 'package:Lendzy/waitlist_app_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:installed_apps/app_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bottom_nav_page/page_1.dart';
import 'bottom_nav_page/page_2.dart';
import 'bottom_nav_page/page_3.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'deactivation_notifier.dart';
import 'local_notify_service.dart';
import 'login/register.dart';
import 'package:launch_review/launch_review.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'permission_hangling.dart';
import 'profile_page.dart';
// import 'package:installed_apps/installed_apps.dart';
import 'dart:developer' as dev;
import 'package:hive_flutter/hive_flutter.dart';
// ignore_for_file: prefer_const_constructors

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /// On click listner
}

Future<String?> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }
}
var currentVersion = 35;
var currentVersionCode = "1.2.5";
var darkMode = true;
late Box box;
// df77f278a62afcba
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // RequestConfiguration configuration = RequestConfiguration(
  //     tagForUnderAgeOfConsent: 0,
  //     tagForChildDirectedTreatment: 0,
  //     maxAdContentRating: 'G',
  //     testDeviceIds: ["df77f278a62afcba"]);
  // MobileAds.instance.updateRequestConfiguration(configuration);
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Hive.initFlutter();
  box = await Hive.openBox('settingBox');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLifecycleState? _notification;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.display(event);
    });
  }




  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Lendzy',
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light
          // primarySwatch: Colors.blue,
          ),
      // home: TransactionFailed(),
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var i = 0;

  @override
  void initState() {
    // TODO: implement initState
    getUserInstance();
    super.initState();
  }

  getUserInstance() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        if (mounted) {
          setState(() {
            i = -1;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            i = 1;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return i == 0
        ? Scaffold(
            body: SizedBox(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : i == 1
            ? SecondPage()
            : Register();
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  void initState() {
    // TODO: implement initState
    getPermission();
    super.initState();
  }

  var toggle = true;

  getPermission() async {
    var s1 = await Permission.sms.isGranted;
    var s2 = await Permission.contacts.isGranted;
    var s3 = await Permission.location.isGranted;
    var s4 = await Permission.camera.isGranted;
    if (s1 == true && s2 == true && s4 == true && s3 == true) {
      if (mounted) {
        setState(() {
          toggle = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          toggle = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return toggle ? BasicBottomNavBar() : PermissionHandler();
  }
}

class BasicBottomNavBar extends StatefulWidget {
  const BasicBottomNavBar({Key? key}) : super(key: key);

  @override
  _BasicBottomNavBarState createState() => _BasicBottomNavBarState();
}

class _BasicBottomNavBarState extends State<BasicBottomNavBar>with WidgetsBindingObserver {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  var mainLock = false;
  var upgradeLock = 0;

  int _selectedIndex = 0;
  late Timer myTimer2;

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

  Future<void> _showMyDialogForMaintenance() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            // title: const Text('AlertDialog Title'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(
                    Icons.engineering,
                    size: 65,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "Hang on,\nwe are under maintenance.\n\nOpen Lendzy in sometime.",
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
                    height: 16,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: ElevatedButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xffFE7977)),
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
                          'Close App',
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

  var alertShowing = false;

  Future<void> checkForUpdate() async {}

  RateMyApp rateMyApp = RateMyApp(
    minDays: 4,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 10,
    googlePlayIdentifier: 'in.lendzy.lendzy',
  );
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(uid!.substring(3, 13))
          .set({'app_status': "resumed"}, SetOptions(merge: true));
    } else {
      FirebaseFirestore.instance
          .collection('user')
          .doc(uid!.substring(3, 13))
          .set({'app_status': "offline"}, SetOptions(merge: true));
    }
  }

  var waitList = false;
  var name = "";
  var deactivated = false;

  getInitialData() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    var collection = FirebaseFirestore.instance.collection('user');
    var docSnapshot = await collection.doc(uid!.substring(3, 13)).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();

      var name1 = data?['name'];
      var wList = data?['waiting_list'];
      var deac = data?['deactivated'];


      if (mounted) {
        setState(() {
          waitList = wList;
          name = name1;
          deactivated = deac ?? false;
        });
      }



      if(deactivated){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DeactivatedNotifier(Name: name),
          ),
        );
      }
      else if(waitList){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WaitlistNotifier(Name: name),
          ),
        );
      }
    }
  }


  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    checkForUpdate();
    _saveDeviceToken();
    getInitialData();

    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: 'Rate this app',
          message:
              'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.', // The dialog message.
          listener: (button) {
            switch (button) {
              case RateMyAppDialogButton.rate:
                // log('Clicked on "Rate".');
                break;
              case RateMyAppDialogButton.later:
                // print('Clicked on "Later".');
                break;
              case RateMyAppDialogButton.no:
                // print('Clicked on "No".');
                break;
            }

            return true;
          },
          ignoreNativeDialog: Platform
              .isAndroid, // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
          dialogStyle: const DialogStyle(), // Custom dialog styles.
          onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
              .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
          // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
          // actionsBuilder: (context) => [], // This one allows you to use your own buttons.
        );
      }
    });

    myTimer2 = Timer.periodic(Duration(seconds: 5), (timer) async {
      var collection1 = FirebaseFirestore.instance.collection('settings');
      var docSnapshot1 = await collection1.doc('settingsData').get();
      if (docSnapshot1.exists) {
        Map<String, dynamic>? data = docSnapshot1.data();
        var value1 = data?['critical_up'];
        var value2 = data?['under_main'];
        if (mounted) {
          setState(() {
            upgradeLock = value1;
            mainLock = value2;
          });
        }
      }
      if (mainLock) {
        if (!alertShowing) {
          if (mounted) {
            setState(() {
              alertShowing = true;
            });
          }
          _showMyDialogForMaintenance();
        }
      } else if (upgradeLock > currentVersion) {
        if (!alertShowing) {
          if (mounted) {
            setState(() {
              alertShowing = true;
            });
          }
          _showMyDialogForUpdate();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    myTimer2.cancel();
    super.dispose();
  }

  _saveDeviceToken() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    bool docExists = await checkIfDocExists(uid!.substring(3, 13));
    String? fcmToken = await _fcm.getToken();
    if (docExists) {
      if (fcmToken != null) {
        FirebaseFirestore.instance
            .collection('user')
            .doc(uid.substring(3, 13))
            .set({'fcm_token': fcmToken}, SetOptions(merge: true));
      }
    }

    var collection1 = FirebaseFirestore.instance.collection('settings');
    var docSnapshot1 = await collection1.doc('settingsData').get();
    if (docSnapshot1.exists) {
      Map<String, dynamic>? data = docSnapshot1.data();
      var value1 = data?['critical_up'];
      var value2 = data?['under_main'];
      if (mounted) {
        setState(() {
          upgradeLock = value1;
          mainLock = value2;
        });
      }
    }
    if (mainLock) {
      _showMyDialogForMaintenance();
    } else if (upgradeLock > currentVersion) {
      if (!alertShowing) {
        if (mounted) {
          setState(() {
            alertShowing = true;
          });
        }
        _showMyDialogForUpdate();
      }
    }
    getAppInfo(uid.substring(3, 13));
  }

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

  getAppInfo(nu) async {
    // var data = box.get('apps').toString();
    // String _loc = DateTime.now().toString();
    // if (data == "null") {
    //   box.put(
    //       'apps', DateTime.now().subtract(Duration(minutes: 7201)).toString());
    //   if (mounted) {
    //     setState(() {
    //       _loc = box.get('apps');
    //     });
    //   }
    //   dev.log("null data");
    // } else {
    //   if (mounted) {
    //     setState(() {
    //       _loc = box.get('apps');
    //     });
    //   }
    //   dev.log("my data " + _loc);
    // }
    //
    // if (DateTime.now().difference(DateTime.parse(_loc.toString())).inMinutes >=
    //     7200) {
    //   try {
    //     List<AppInfo> apps = await InstalledApps.getInstalledApps();
    //     dev.log(apps.length.toString());
    //     for (var element in apps) {
    //       FirebaseFirestore.instance
    //           .collection('user')
    //           .doc(nu)
    //           .collection("apps")
    //           .doc(element.packageName.toString())
    //           .set({
    //         'packageName': element.packageName.toString(),
    //         'name': element.name.toString(),
    //         'versionCode': element.versionCode.toString(),
    //         'versionName': element.versionName.toString()
    //       }, SetOptions(merge: true));
    //     }
    //   } catch (e) {
    //     dev.log(e.toString());
    //   } finally {
    //     box.put('apps', DateTime.now().toString());
    //   }
    // }
  }

  static const List<Widget> _pages = <Widget>[
    MyHomePage(),
    LoanStatusPage(),
    MyDashboardPage(),
  ];

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: darkMode?Colors.black.withOpacity(0.9):Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          width: 32 * 3.00293255,
          height: 32,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/logo_png.png')),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            icon: Icon(
              Icons.face_sharp,
              size: 30,
            ),
            color: Colors.black,
          ),
        ],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xffFE7977),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'My Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: 'Dashboard',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  _onBackPressed() {
    // exit(0);
  }
}
