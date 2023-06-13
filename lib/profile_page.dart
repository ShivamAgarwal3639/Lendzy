// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore_for_file: prefer_const_constructors

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var name = "";
  var num = "";
  var aadhaarCard = false;
  var panCard = false;
  var videoCard = false;

  var aNum = "";
  var aName = "";
  var aDOB = "";
  var aGen = "";
  var aAdd = "";
  var aPin = "";

  var pNum = "";
  var pName = "";
  var pDOB = "";

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getInitialData();
  }

  getInitialData() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    var collection = FirebaseFirestore.instance.collection('user');
    var docSnapshot = await collection.doc(uid!.substring(3, 13)).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var num1 = data?['phone'];
      var name1 = data?['name'];
      var aadhaar1 = data?['aadhaar'];
      var pan1 = data?['pan'];
      var video1 = data?['video'];
      setState(() {
        num = num1;
        name = name1;
        aadhaarCard = aadhaar1;
        panCard = pan1;
        videoCard = video1;
      });
    }

    var collection1 = FirebaseFirestore.instance
        .collection('user')
        .doc(uid.substring(3, 13))
        .collection("pan");
    var docSnapshot1 = await collection1.doc(uid.substring(3, 13)).get();
    if (docSnapshot1.exists) {
      Map<String, dynamic>? data = docSnapshot1.data();
      var num = data?['pan_num'];
      var name = data?['pan_name'];
      var dob = data?['pan_dob'];
      setState(() {
        pNum = num.toString();
        pName = name.toString();
        pDOB = dob.toString();
      });
    }

    var collection2 = FirebaseFirestore.instance
        .collection('user')
        .doc(uid.substring(3, 13))
        .collection("aadhaar");
    var docSnapshot2 = await collection2.doc(uid.substring(3, 13)).get();
    if (docSnapshot2.exists) {
      Map<String, dynamic>? data = docSnapshot2.data();
      var num = data?['aadhaar_num'];
      var name = data?['aadhaar_name'];
      var dob = data?['aadhaar_dob'];
      var gen = data?['aadhaar_gender'];
      var pin = data?['aadhaar_pin'];
      var add = data?['aadhaar_address'];
      setState(() {
        aNum = num.toString();
        aName = name.toString();
        aDOB = dob.toString();
        aGen = gen.toString();
        aAdd = add.toString();
        aPin = pin.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Hi, ${name == "" ? num : name}!",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 24,
          ),
          Center(
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: Color(0xffFE7977),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/images/profile_pic_png.png"),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Center(
            child: Text(
              name == "" ? num : name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              name != "" ? "+91 " + num : "",
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          expandAadhaarDataWidget(title: "Aadhaar Details"),
          expandPanDataWidget(title: "PAN Details"),
          expandPersonalDataWidget(title: "Personal Details"),
        ],
      ),
    );
  }

  expandAadhaarDataWidget({title}) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: <Widget>[
            ExpandablePanel(
              theme: const ExpandableThemeData(
                iconColor: Color(0xffFE7977),
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapBodyToCollapse: true,
              ),
              header: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              collapsed: SizedBox(),
              expanded: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textStyle("Aadhaar Number:"),
                      textStyle("Name:"),
                      textStyle("Date Of Birth:"),
                      textStyle("Gender:"),
                      textStyle("Address:"),
                      textStyle("Pincode:"),
                    ],
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textStyle(aNum),
                      textStyle(aName),
                      textStyle(aDOB),
                      textStyle(aGen),
                      textStyle(aAdd),
                      textStyle(aPin),
                    ],
                  ),
                ],
              ),
              builder: (_, collapsed, expanded) {
                return Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                  child: Expandable(
                    collapsed: collapsed,
                    expanded: expanded,
                    theme: const ExpandableThemeData(crossFadePoint: 0),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  expandPanDataWidget({title}) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: <Widget>[
            ExpandablePanel(
              theme: const ExpandableThemeData(
                iconColor: Color(0xffFE7977),
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapBodyToCollapse: true,
              ),
              header: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              collapsed: SizedBox(),
              expanded: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textStyle("Pan Number:"),
                      textStyle("Name:"),
                      textStyle("Date Of Birth:"),
                    ],
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textStyle(pNum),
                      textStyle(pName),
                      textStyle(pDOB),
                    ],
                  ),
                ],
              ),
              builder: (_, collapsed, expanded) {
                return Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                  child: Expandable(
                    collapsed: collapsed,
                    expanded: expanded,
                    theme: const ExpandableThemeData(crossFadePoint: 0),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  expandPersonalDataWidget({title}) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: <Widget>[
            ExpandablePanel(
              theme: const ExpandableThemeData(
                iconColor: Color(0xffFE7977),
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapBodyToCollapse: true,
              ),
              header: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              collapsed: SizedBox(),
              expanded: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textStyle("Name:"),
                      textStyle("Number:"),
                    ],
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      textStyle(name),
                      textStyle(num),
                    ],
                  ),
                ],
              ),
              builder: (_, collapsed, expanded) {
                return Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
                  child: Expandable(
                    collapsed: collapsed,
                    expanded: expanded,
                    theme: const ExpandableThemeData(crossFadePoint: 0),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  textStyle(data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: SizedBox(
        width: MediaQuery.of(context).size.width/2.5,
        child: Text(
          data == "null" || data == null ? "" : data,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
