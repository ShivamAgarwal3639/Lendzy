// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PanCardInfo extends StatefulWidget {
  const PanCardInfo({Key? key}) : super(key: key);

  @override
  _PanCardInfoState createState() => _PanCardInfoState();
}

class _PanCardInfoState extends State<PanCardInfo> {
  var panNumVal = "";

  final _formKey = GlobalKey<FormState>();

  var name = "";
  var num = "";
  var panInfo = "";
  var panFront = "";
  var aadhaarCard = false;
  var panCard = false;
  var videoCard = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController _controllerNumber = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDOB = TextEditingController();

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
  }

  var title = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
  );

  var titleField = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
  );

  var titleFieldHint = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black45,
    ),
  );

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

  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    DateFormat formatter =
        DateFormat('dd/MM/yyyy'); //specifies day/month/year format

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _controllerDOB.value = TextEditingValue(text: formatter.format(picked));//Use formatter to format selected date and assign to text field
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PAN Information",
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "PAN Number",
                    style: title,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    controller: _controllerNumber,
                    textCapitalization: TextCapitalization.characters,
                    style: titleField,
                    cursorColor: Color(0xffFE7977),
                    onChanged: (val) {
                      setState(() {
                        panNumVal = val;
                      });
                    },
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.allow(
                    //     RegExp('[A-Z]{5}[0-9]{4}[A-Z]{1}'),
                    //   ),
                    // ],
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffFE7977),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      hintStyle: titleFieldHint,
                      hintText: "PAN Number",
                      fillColor: Colors.white70,
                    ),
                    maxLength: 10,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.contains(" ") ||
                          value.contains(",") ||
                          value.contains(".") ||
                          value.contains("-") ||
                          value.length < 10 ||
                          !RegExp(r"[A-Z]{5}[0-9]{4}[A-Z]{1}")
                              .hasMatch(panNumVal)) {
                        return 'Please enter valid PAN Number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Name",
                    style: title,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    controller: _controllerName,
                    style: titleField,
                    cursorColor: Color(0xffFE7977),
                    decoration: InputDecoration(
                        isDense: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffFE7977)),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        hintStyle: titleFieldHint,
                        hintText: "Name",
                        fillColor: Colors.white70),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter valid Name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Date Of Birth",
                    style: title,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _controllerDOB,
                          style: titleField,
                          keyboardType: TextInputType.datetime,
                          cursorColor: Color(0xffFE7977),
                          decoration: InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffFE7977),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              filled: true,
                              hintStyle: titleFieldHint,
                              hintText: "DD/MM/YYYY",
                              fillColor: Colors.white70),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter valid DOB';
                            }
                            return null;
                          },
                        ),
                      )),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Please Check all the details again. All the details should be exactly same as in your PAN Card.",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          try {
                            if (_formKey.currentState!.validate()) {
                              bool docExists = await checkIfDocExists();
                              if (docExists) {
                                FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(num)
                                    .collection('pan')
                                    .doc(num)
                                    .update({
                                  'pan_num': _controllerNumber.text.toString(),
                                  'pan_name': _controllerName.text.toString(),
                                  'pan_dob': _controllerDOB.text.toString(),
                                  'date_time': Timestamp.now(),
                                  'date': DateTime.now(),
                                });
                              } else {
                                FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(num)
                                    .collection('pan')
                                    .doc(num)
                                    .set({
                                  'pan_num': _controllerNumber.text.toString(),
                                  'pan_name': _controllerName.text.toString(),
                                  'pan_dob': _controllerDOB.text.toString(),
                                  'date_time': Timestamp.now(),
                                  'date': DateTime.now(),
                                });
                              }
                            }
                          } catch (e) {
                            log(e.toString());
                          } finally {
                            Navigator.of(context).pop(true);
                          }
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
