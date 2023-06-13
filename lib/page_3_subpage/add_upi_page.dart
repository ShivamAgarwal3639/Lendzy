import 'dart:developer' as logs;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore_for_file: prefer_const_constructors

class AddUpiPage extends StatefulWidget {
  const AddUpiPage({Key? key, this.back}) : super(key: key);
  final back;

  @override
  _AddUpiPageState createState() => _AddUpiPageState();
}

class _AddUpiPageState extends State<AddUpiPage> {
  String add = "list";
  var upiId = "";
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  var userNum = "";
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            }),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "UPI Id",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: add == "list"
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .doc(userNum)
                        .collection('upi')
                        .orderBy('date_time')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc = snapshot.data!.docs[index];
                              return myUpiData(
                                upi: doc['upi'],
                                upiId: doc['upi_id'],
                                name: doc['upi_name'],
                                primary: doc['primary'],
                                dateTime: doc['date_time'],
                              );
                            });
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : addUpiAdd(),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: SizedBox(
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 8,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: Row(
                  children: [
                    add == "list"
                        ? SizedBox()
                        : SizedBox(
                            width: (MediaQuery.of(context).size.width - 40) / 3,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black54),
                              ),
                              onPressed: () async {
                                _controller.clear();
                                setState(() {
                                  add = "list";
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                child: Text(
                                  "Cancel",
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
                    SizedBox(
                      width: add == "list" ? 0 : 8,
                    ),
                    SizedBox(
                      width: add == "list"
                          ? MediaQuery.of(context).size.width - 32
                          : (MediaQuery.of(context).size.width - 40) -
                              ((MediaQuery.of(context).size.width - 40) / 3),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xffFE7977)),
                        ),
                        onPressed: () async {
                          if (add == "list") {
                            setState(() {
                              add = "check";
                            });
                          } else if (add == "check") {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                add = "valid";
                              });
                            }
                          } else if (add == "valid") {
                            if (_formKey.currentState!.validate()) {
                              var upi = _controller.text;
                              final User? user = auth.currentUser;
                              final uid = user!.phoneNumber!.substring(3, 13);
                              var upiId = getRandomString(12);

                              FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(uid)
                                  .collection("upi")
                                  .doc(upi)
                                  .set({
                                'upi_id': upiId,
                                'upi': upi,
                                'upi_name': "Shivam Kumar Agarwal",
                                'date_time': Timestamp.now(),
                                'primary': false,
                              });
                              setState(() {
                                add = "list";
                              });
                              _controller.clear();
                            } else if (add == "failed") {
                              setState(() {
                                add = "check";
                              });
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 0, right: 0, top: 12, bottom: 12),
                          child: Text(
                            add == "list"
                                ? "Add New UPI"
                                : add == "check"
                                    ? "Check UPI"
                                    : add == "valid"
                                        ? "Add UPI"
                                        : "Re-Enter UPI",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 18,
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
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  myUpiData({upiId, upi, primary, name, dateTime}) {
    return SizedBox(
      child: InkWell(
        onTap: () async {
          try {
            CollectionReference ref = FirebaseFirestore.instance
                .collection('user')
                .doc(userNum)
                .collection("upi");

            QuerySnapshot eventsQuery = await ref.get();
            for (var document in eventsQuery.docs) {
              setState(() {
                if (document["primary"] == true) {
                  FirebaseFirestore.instance
                      .collection('user')
                      .doc(userNum)
                      .collection('upi')
                      .doc(document["upi"])
                      .update({'primary': false});
                }
              });
            }
            FirebaseFirestore.instance
                .collection('user')
                .doc(userNum)
                .collection('upi')
                .doc(upi)
                .update({'primary': true});
          } catch (e) {
            logs.log(e.toString());
          } finally {
            if (widget.back == true) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      upi,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Spacer(),
                    if (!primary)
                      InkWell(
                        onTap: () async {
                          try {
                            CollectionReference ref = FirebaseFirestore.instance
                                .collection('user')
                                .doc(userNum)
                                .collection("upi");

                            QuerySnapshot eventsQuery = await ref.get();
                            for (var document in eventsQuery.docs) {
                              setState(() {
                                if (document["primary"] == true) {
                                  FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(userNum)
                                      .collection('upi')
                                      .doc(document["upi"])
                                      .update({'primary': false});
                                }
                              });
                            }

                            FirebaseFirestore.instance
                                .collection('user')
                                .doc(userNum)
                                .collection('upi')
                                .doc(upi)
                                .update({'primary': true});
                          } catch (e) {
                            logs.log(e.toString());
                          } finally {
                            if (widget.back == true) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: Icon(
                          Icons.radio_button_off,
                          color: Colors.black,
                        ),
                      )
                    else
                      Icon(
                        Icons.radio_button_checked,
                        color: Color(0xffFE7977),
                      ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                // Text(
                //   name,
                //   style: GoogleFonts.poppins(
                //     textStyle: TextStyle(
                //       fontSize: 13,
                //       color: Colors.black,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
                TextButton(
                  onPressed: primary
                      ? null
                      : () {
                          FirebaseFirestore.instance
                              .collection("user")
                              .doc(userNum)
                              .collection("upi")
                              .doc(upi)
                              .delete()
                              .then((value) {});
                        },
                  child: Text(
                    "Click here to delete",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 12,
                        color: primary ? Colors.black54 : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  addUpiAdd() {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            onChanged: (val) {
              setState(() {
                upiId = val;
              });
            },
            controller: _controller,
            enabled: add == "valid" || add == "failed" ? false : true,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.contains(" ") ||
                  !RegExp(r"[\w.-]+@[\w.-]").hasMatch(upiId)) {
                return 'Please enter valid UPI';
              }
              return null;
            },
            cursorColor: Color(0xffFE7977),
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            decoration: InputDecoration(
              isDense: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffFE7977)),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              hintText: 'Enter UPI Address',
            ),
          ),
        ),
        SizedBox(
          height: 32,
        ),
        add == "check"
            ? SizedBox()
            : add == "failed"
                ? SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    child: Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "UPI Verification Failed Please check your UPI and Enter again",
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (add == "valid") {
                              if (_formKey.currentState!.validate()) {
                                var upi = _controller.text;
                                final User? user = auth.currentUser;
                                final uid = user!.phoneNumber!.substring(3, 13);
                                var upiId = getRandomString(12);

                                FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(uid)
                                    .collection("upi")
                                    .doc(upi)
                                    .set({
                                  'upi_id': upiId,
                                  'upi': upi,
                                  'upi_name': "",
                                  'date_time': Timestamp.now(),
                                  'primary': false,
                                  'valid': false,
                                });
                                setState(() {
                                  add = "list";
                                });
                                _controller.clear();
                              }
                            }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 48,
                            child: Card(
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "your UPI id is:",
                                      maxLines: 2,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      _controller.text,
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 64,
                        ),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Please re-check the entered UPI ID to avoid transaction failure.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cabin(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black38,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ],
    );
  }
}
