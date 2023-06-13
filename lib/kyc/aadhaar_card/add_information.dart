// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAadhaarInfoPage extends StatefulWidget {
  const AddAadhaarInfoPage({Key? key}) : super(key: key);

  @override
  _AddAadhaarInfoPageState createState() => _AddAadhaarInfoPageState();
}

class _AddAadhaarInfoPageState extends State<AddAadhaarInfoPage> {
  String dropDownValue = 'Select Gender';

  String? _myActivity;
  String? _myActivityResult;

  final _formKey = GlobalKey<FormState>();

  var name = "";
  var num = "";
  var aadhaarInfo = "";
  var aadhaarFront = "";
  var aadhaarBack = "";
  var aadhaarCard = false;
  var panCard = false;
  var videoCard = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController _controllerNumber = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerFName = TextEditingController();
  final TextEditingController _controllerMName = TextEditingController();
  final TextEditingController _controllerDOB = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();
  final TextEditingController _controllerPin = TextEditingController();

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
        _controllerDOB.value = TextEditingValue(
            text: formatter.format(
                picked)); //Use formatter to format selected date and assign to text field
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInitialData();
    _myActivity = '';
    _myActivityResult = '';
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

  var titleFieldHint = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black45,
    ),
  );

  var titleField = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
  );

  Future<bool> checkIfDocExists() async {
    try {
      var collectionRef = FirebaseFirestore.instance
          .collection('user')
          .doc(num)
          .collection('aadhaar');
      var doc = await collectionRef.doc(num).get();
      return doc.exists;
    } catch (e) {
      log(e.toString());
    }
    return false;
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
          "Aadhaar Information",
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
                    "Aadhaar Number",
                    style: title,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    controller: _controllerNumber,
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
                      hintText: "Aadhaar Number",
                      fillColor: Colors.white70,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.contains(" ") ||
                          value.contains(",") ||
                          value.contains(".") ||
                          value.contains("-") ||
                          value.length < 12) {
                        return 'Please enter valid Aadhaar Number';
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
                    "Fathers Name",
                    style: title,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    style: titleField,
                    controller: _controllerFName,
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
                        hintText: "Fathers Name",
                        fillColor: Colors.white70),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter valid Father\'s Name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Mother Name",
                    style: titleField,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    controller: _controllerMName,
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
                        hintText: "Mother Name",
                        fillColor: Colors.white70),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter valid Mother\'s Name';
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
                          cursorColor: Color(0xffFE7977),
                          decoration: InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffFE7977)),
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
                    "Gender",
                    style: title,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  DropDownFormField(
                    titleText: 'My Gender',
                    hintText: 'Please Select Your Gender.',
                    value: _myActivity,
                    onSaved: (value) {
                      setState(() {
                        _myActivity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter valid Gender';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _myActivity = value;
                      });
                    },
                    dataSource: const [
                      {
                        "display": "Male",
                        "value": "Male",
                      },
                      {
                        "display": "Female",
                        "value": "Female",
                      },
                      {
                        "display": "Others",
                        "value": "Others",
                      },
                    ],
                    textField: 'display',
                    valueField: 'value',
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Address Mentioned on Aadhaar Card",
                    style: title,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    controller: _controllerAddress,
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
                        hintText: "Address Mentioned on Aadhaar Card",
                        fillColor: Colors.white70),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter valid Address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Pincode Mentioned On Aadhaar Card",
                    style: title,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    controller: _controllerPin,
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
                        hintText: "Pincode Mentioned On Aadhaar Card",
                        fillColor: Colors.white70),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.contains(" ") ||
                          value.contains(",") ||
                          value.contains(".") ||
                          value.contains("-") ||
                          value.length < 6) {
                        return 'Please enter valid Pin Code';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Please Check all the details again. All the details should be exactly same as in your Aadhaar Card.",
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
                                    .collection('aadhaar')
                                    .doc(num)
                                    .update({
                                  'aadhaar_num':
                                      _controllerNumber.text.toString(),
                                  'aadhaar_name':
                                      _controllerName.text.toString(),
                                  'aadhaar_f_name':
                                      _controllerFName.text.toString(),
                                  'aadhaar_m_name':
                                      _controllerMName.text.toString(),
                                  'aadhaar_dob': _controllerDOB.text.toString(),
                                  'aadhaar_gender': _myActivity,
                                  'aadhaar_address':
                                      _controllerAddress.text.toString(),
                                  'aadhaar_pin': _controllerPin.text.toString(),
                                  'date_time': Timestamp.now(),
                                  'date': DateTime.now(),
                                });
                              } else {
                                FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(num)
                                    .collection('aadhaar')
                                    .doc(num)
                                    .set({
                                  'aadhaar_num':
                                      _controllerNumber.text.toString(),
                                  'aadhaar_name':
                                      _controllerName.text.toString(),
                                  'aadhaar_f_name':
                                      _controllerFName.text.toString(),
                                  'aadhaar_m_name':
                                      _controllerMName.text.toString(),
                                  'aadhaar_dob': _controllerDOB.text.toString(),
                                  'aadhaar_gender': _myActivity,
                                  'aadhaar_address':
                                      _controllerAddress.text.toString(),
                                  'aadhaar_pin': _controllerPin.text.toString(),
                                  'date_time': Timestamp.now(),
                                  'date': DateTime.now(),
                                });
                              }
                              FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(num)
                                  .update({
                                'name': _controllerName.text.toString()
                              });
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
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }
}
