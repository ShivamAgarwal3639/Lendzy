// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../linode_s3.dart';

class AddPanPicPage extends StatefulWidget {
  const AddPanPicPage({Key? key}) : super(key: key);

  @override
  _AddPanPicPageState createState() => _AddPanPicPageState();
}

class _AddPanPicPageState extends State<AddPanPicPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool up1 = false;

  XFile? _imageFile1;
  String? url1;

  var name = "";
  var num = "";
  var aadhaarCard = false;
  var panCard = false;
  var videoCard = false;

  var frontPa = "";

  @override
  void initState() {
    // TODO: implement initState
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
      var front = data?['pan_front'];
      setState(() {
        frontPa = front.toString();
      });
    }
  }

  /// Select an image via gallery or camera
  Future<void> _pickImage1() async {
    setState(() {
      up1 = true;
    });
    XFile selected = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50,) as XFile;

    setState(() {
      _imageFile1 = selected;
    });
    if (_imageFile1 != null) {
      _startUpload1();
    }
  }

  /// Remove image
  void _clear1() {
    setState(() => _imageFile1 = null);
  }

  Future<bool> checkIfDocExists() async {
    try {
      var collectionRef = FirebaseFirestore.instance
          .collection('user')
          .doc(num)
          .collection('pan');
      var doc = await collectionRef.doc(num).get();
      return doc.exists;
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  /// Starts an upload task
  void _startUpload1() async {
    /// Unique file name for the file
    try {
      var data = await AWSClient().uploadData(
          "Pan",
          num.toString() + "_front.png",
          File(_imageFile1!.path).readAsBytesSync());
      log(data.toString());
      if (data.toString() == "204" || data.toString() == "200") {
        setState(() {
          url1 =
              "https://mybucket69420.ap-south-1.linodeobjects.com/Pan/" +
                  num.toString() +
                  "_front.png";
        });
        bool docExists = await checkIfDocExists();
        if (docExists) {
          FirebaseFirestore.instance
              .collection('user')
              .doc(num)
              .collection('pan')
              .doc(num)
              .update({'pan_front': url1});
        } else {
          FirebaseFirestore.instance
              .collection('user')
              .doc(num)
              .collection('pan')
              .doc(num)
              .set({'pan_front': url1});
        }
      }
    } catch (e) {
      log("");
    } finally {
      setState(() {
        up1 = false;
      });
      getInitialData();
      _clear1();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(
          "PAN Verification",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    "PAN Card \nPicture",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 16,
                        child: Column(
                          children: [
                            Text(
                              "Click the front of PAN Card",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          Container(
                              child: (url1 == "" || url1 == null) &&
                                      (frontPa == "null" || frontPa == "")
                                  ? InkWell(
                                      onTap: () {
                                        if (!up1) {
                                          _pickImage1();
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color(0xffFE7977),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: up1
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  "Add Front",
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width /
                                          2.5,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: up1 ? Color(0xffFE7977) : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: up1
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                          : Center(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    "Completed",
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    )),
                          // SizedBox(
                          //   height: 8,
                          // ),
                          // (frontAa != "null" && frontAa != "")
                          //     ? TextButton(
                          //         child: Text(
                          //           "Change",
                          //           style: GoogleFonts.poppins(
                          //             textStyle: TextStyle(
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.w500,
                          //               color: Color(0xffFE7977),
                          //             ),
                          //           ),
                          //         ),
                          //         onPressed: () {},
                          //       )
                          //     : SizedBox(),
                        ],
                      ),
                      SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (frontPa != "" && frontPa != "null")
                        ? InkWell(
                            onTap: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.3,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(0xffFE7977),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {},
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.3,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 16,
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
