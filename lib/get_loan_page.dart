import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:developer' as loga;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import 'loan_details.dart';
import 'notification.dart';
import 'dart:io';

import 'page_3_subpage/add_upi_page.dart';
// ignore_for_file: prefer_const_constructors

class GetLoanPage extends StatefulWidget {
  const GetLoanPage({Key? key}) : super(key: key);

  @override
  _GetLoanPageState createState() => _GetLoanPageState();
}

class _GetLoanPageState extends State<GetLoanPage> {
  var checkedValue = false;
  var checkedValue1 = false;
  var connection = true;
  var kyc = false;

  final _formKey = GlobalKey<FormState>();
  double _currentSliderValue = 5;
  final TextEditingController _controller = TextEditingController();

  var processingFee = 0.0;
  var gst = 0.0;
  var interest = 0.0;
  var disAmt = 0.0;
  var repAmt = 0.0;
  var upi = "";
  var upiName = "";

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  final FirebaseAuth auth = FirebaseAuth.instance;
  var totalLimit = 0;
  var usedLimit = 0;
  var userNumber;

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  final DateFormat serverFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    internet();
    getInitialData();
  }

  getInitialData() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    var collection = FirebaseFirestore.instance.collection('user');
    var docSnapshot = await collection.doc(uid!.substring(3, 13)).get();
    setState(() {
      userNumber = uid.substring(3, 13);
    });
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['limit'];
      var uValue = data?['used_limit'];
      var uKyc = data?['kyc'];
      setState(() {
        totalLimit = int.tryParse(value)!;
        usedLimit = int.tryParse(uValue)!;
        kyc = uKyc;
      });
    }

    QuerySnapshot eventsQuery2 = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid.substring(3, 13))
        .collection("upi")
        .where('primary', isEqualTo: true)
        .get();
    for (var document in eventsQuery2.docs) {
      setState(() {
        upi = document["upi"].toString();
        upiName = document["upi_name"].toString();
      });
    }
  }

  Future<Null> updated1(StateSetter updateState, data) async {
    updateState(() {
      checkedValue = data;
    });
  }

  Future<Null> updated2(StateSetter updateState, data) async {
    updateState(() {
      checkedValue1 = data;
    });
  }

  calcAmt(val) {
    if (_formKey.currentState!.validate()) {
      var num = val != "" || val != 0 ? int.tryParse(_controller.text) : 0.0;
      var totInterest = val != "" || val != 0 ? num! * (10 / 100) : 0.0;
      setState(() {
        interest = (val != "" || val != 0
            ? double.tryParse((totInterest * (15 / 100)).toStringAsFixed(2))
            : 0.0)!;
      });
      var pAndQ = val != "" || val != 0 ? totInterest - interest : 0.0;
      setState(() {
        gst = val != "" || val != 0
            ? double.tryParse(
                (pAndQ * (15.25294117647059 / 100)).toStringAsFixed(2))!
            : 0.0;
        processingFee = val != "" || val != 0
            ? double.tryParse((pAndQ - gst).toStringAsFixed(2))!
            : 0.0;
        disAmt = (val != "" || val != 0
            ? double.tryParse((num! - totInterest).toStringAsFixed(2))
            : 0.0)!;
        repAmt = val != "" || val != 0 ? (num! * 1.0) : 0.0;
      });
    } else {
      setState(() {
        processingFee = 0.0;
        interest = 0.0;
        gst = 0.0;
        disAmt = 0.0;
        repAmt = 0.0;
      });
    }
  }

  addLoanData() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber!.substring(3, 13);
    var loanId = getRandomString(12);
    var time1 = DateTime.now().toLocal();
    time1 = DateTime(time1.year, time1.month, time1.day);
    var time2 = DateTime.now().add(Duration(days: 30)).toLocal();
    time2 = DateTime(time2.year, time2.month, time2.day);
    FirebaseFirestore.instance.collection("loan").doc(loanId).set({
      'pp_done':true,
      'loan_id': loanId,
      'upi_id': upi,
      'user_num': uid,
      'upi_name': upiName,
      'loan_amt': repAmt.toString(),
      'dis_amt': disAmt.toString(),
      'rep_amt': repAmt.toString(),
      'interest': interest.toString(),
      'proc_fee': processingFee.toString(),
      'gst': gst.toString(),
      'date_time': Timestamp.now(),
      'loan_date': time1.toString(),
      'repayment': time2.toString(),
      'status': "initiated",
      'term_one': true,
      'term_two': true,
      'failed_data': "",
      'extended': false,
      'extended_time': 0,
      'extended_one_payment': "",
      'extended_one_repayment': "",
      'extended_one_date': "",
      'extended_two_payment': "",
      'extended_two_repayment': "",
      'extended_two_date': "",
      'partial_valid': true,
      'late_discount': 0,
    });

    var usedLim = (usedLimit + repAmt).toInt();
    FirebaseFirestore.instance.collection("user").doc(uid).update({
      'used_limit': usedLim.toString(),
    });
    QuerySnapshot eventsQuery =
        await FirebaseFirestore.instance.collection("admin").get();
    for (var document in eventsQuery.docs) {
      NotificationHandler.sendNotification(
          title: "New Loan request",
          body: "There is a new Loan request of $repAmt from $uid",
          to: document["fcm_id"]);
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoanDetailsPage(
              discount: 0,
                  user: uid,
                  extended: false,
                  status: "initiated",
                  upi: upi,
                  loanIds: loanId,
                  type: "loanTaking",
                  disAmt: disAmt,
                  payAmt: repAmt,
                  repDate: Jiffy(DateTime.now().add(Duration(days: 30)))
                      .format("d MMM yyyy")
                      .toString(),
                loanDate:time1.toString(),
                )),
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Get Loan",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: !connection
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
                                  image:
                                      AssetImage('assets/images/warning.gif')),
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
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Enter Amount",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          onChanged: (val) {
                            calcAmt(val);
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.contains(" ") ||
                                value.contains(",") ||
                                value.contains(".") ||
                                value.contains("-")) {
                              return 'Please enter valid Amount';
                            } else if (int.tryParse(value)! < 500 ||
                                int.tryParse(value)! > 2000) {
                              return 'Please Enter Amount Between 500 and 2000';
                            } else if (double.tryParse(totalLimit.toString())! <
                                (usedLimit +
                                    double.tryParse(value.toString())!)) {
                              return 'Loan amount exceeding your limit';
                            }
                            return null;
                          },
                          controller: _controller,
                          cursorColor: Color(0xffFE7977),
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                          decoration: InputDecoration(
                            isDense: true,
                            prefix: Text("₹ ",
                                style: GoogleFonts.cabin(
                                  textStyle: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                )),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffFE7977)),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            hintText: 'Enter Amount in INR',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      feeDistribution(
                          "Processing Fee", "- ₹" + processingFee.toString()),
                      feeDistribution("GST (18%)", "- ₹" + gst.toString()),
                      feeDistribution(
                          "Interest (1.5%)", "+ ₹" + interest.toString()),
                      feeDistribution(
                          "Disbursal Amount", "₹" + disAmt.toString()),
                      feeDistribution(
                          "Repayment Amount", "₹" + repAmt.toString()),
                      userNumber != "1111111111"
                          ? feeDistribution(
                              "Repayment Date",
                              _controller.text != ""
                                  ? "After 30 days on " +
                                      Jiffy(DateTime.now()
                                              .add(Duration(days: 30)))
                                          .format("d MMM yyyy")
                                  : "--",
                            )
                          : feeDistribution(
                              "First EMI Date",
                              _controller.text != ""
                                  ? Jiffy(DateTime.now()
                                          .add(Duration(days: 30)))
                                      .format("d MMM yyyy")
                                  : "--",
                            ),
                      userNumber == "1111111111"
                          ? feeDistribution(
                              "Second EMI Date",
                              _controller.text != ""
                                  ?
                                  // "After 60 days on " +
                                  Jiffy(DateTime.now().add(Duration(days: 60)))
                                      .format("d MMM yyyy")
                                  : "--",
                            )
                          : SizedBox(
                        height:0,
                        width: 0,
                      ),
                      userNumber == "1111111111"
                          ? feeDistribution(
                              "Last EMI Date",
                              _controller.text != ""
                                  ?
                                  // "After 90 days on " +
                                  Jiffy(DateTime.now().add(Duration(days: 90)))
                                      .format("d MMM yyyy")
                                  : "--",
                            )
                          : SizedBox(
                        height:0,
                        width: 0,
                      ),
                      userNumber != "1111111111"
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "The tenure of this loan can be extended to a minimum of 62 days. If you are facing any difficulty in paying the loan on the repayment date, you can extend this loan for more 30 days.",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                maxLines: 5,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                        height:0,
                        width: 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: !connection
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: SizedBox(
                height: 160,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    "Your UPI id is:",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                upi,
                                maxLines: 2,
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () async {
                            try {
                              internet();
                            } catch (e) {
                              loga.log("a");
                            } finally {
                              if (connection) {
                                var val = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddUpiPage(
                                            back: true,
                                          )),
                                );
                                if (val == null || val == true) {
                                  getInitialData();
                                }
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                color: Color(0xff2F2E2F)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              child: Text(
                                upi != "" ? "Change" : "Add UPI",
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
                    SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 48,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xffFE7977)),
                        ),
                        onPressed: upi == ""
                            ? () {
                                try {
                                  internet();
                                } catch (e) {
                                  loga.log("a");
                                } finally {
                                  if (connection) {
                                    final snackBar = SnackBar(
                                      content: Text(
                                        'Please add your UPI ID.',
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      action: SnackBarAction(
                                        label: 'Ok',
                                        onPressed: () {
                                          // Some code to undo the change.
                                        },
                                      ),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                }
                              }
                            : () {
                                try {
                                  internet();
                                } catch (e) {
                                  loga.log("a");
                                } finally {
                                  if (connection) {
                                    if (_formKey.currentState!.validate()) {
                                      showModalBottomSheet<void>(
                                        isScrollControlled: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                              builder: (context, state) {
                                            return SizedBox(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 24, right: 24),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    // mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        "Confirm Loan",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                textStyle:
                                                                    TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        )),
                                                      ),
                                                      Divider(
                                                        thickness: 1.5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Disbursal Amount",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    textStyle:
                                                                        TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            )),
                                                          ),
                                                          Spacer(),
                                                          Text(
                                                            "₹" +
                                                                disAmt
                                                                    .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .cabin(
                                                                    textStyle:
                                                                        TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            )),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(
                                                        thickness: 1.5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Repayment Amount",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    textStyle:
                                                                        TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            )),
                                                          ),
                                                          Spacer(),
                                                          Text(
                                                            "₹" +
                                                                repAmt
                                                                    .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .cabin(
                                                                    textStyle:
                                                                        TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            )),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(
                                                        thickness: 1.5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            userNumber ==
                                                                    "1111111111"
                                                                ? "First EMI Date"
                                                                : "Repayment Date",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    textStyle:
                                                                        TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            )),
                                                          ),
                                                          Spacer(),
                                                          Text(
                                                            Jiffy(DateTime.now()
                                                                    .add(Duration(
                                                                        days:
                                                                            30)))
                                                                .format(
                                                                    "d MMM yyyy")
                                                                .toString()
                                                            // +
                                                            // "\n(Extend 30 + 60 days)"
                                                            ,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    textStyle:
                                                                        TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            )),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(
                                                        thickness: 1.5,
                                                      ),
                                                      CheckboxListTile(
                                                        activeColor:
                                                            Color(0xffFE7977),
                                                        title: Text(
                                                            "I Accept the Loan Agreement",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    textStyle:
                                                                        TextStyle())),
                                                        value: checkedValue,
                                                        onChanged: (newValue) {
                                                          updated1(
                                                              state, newValue!);
                                                        },
                                                        controlAffinity:
                                                            ListTileControlAffinity
                                                                .leading, //  <-- leading Checkbox
                                                      ),
                                                      CheckboxListTile(
                                                        activeColor:
                                                            Color(0xffFE7977),
                                                        title: Text(
                                                            "If I do not repay, share my default "
                                                            "status with my parents, friends and anyone i know.",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    textStyle:
                                                                        TextStyle())),
                                                        value: checkedValue1,
                                                        onChanged: (newValue) {
                                                          updated2(
                                                              state, newValue!);
                                                        },
                                                        controlAffinity:
                                                            ListTileControlAffinity
                                                                .leading, //  <-- leading Checkbox
                                                      ),
                                                      Center(
                                                        child:
                                                            ConfirmationSlider(
                                                          iconColor:
                                                              Color(0xffFE7977),
                                                          // backgroundColor: Color(0xffFE7977),
                                                          foregroundColor:
                                                              Color(0xffFE7977),
                                                          // backgroundColorEnd: Color(0xffFE7977),

                                                          height: 48,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              48,
                                                          onConfirmation:
                                                              checkedValue &&
                                                                      checkedValue1
                                                                  ? () {
                                                                      internet();
                                                                      if(connection && kyc){
                                                                        addLoanData();
                                                                      }
                                                                    }
                                                                  : () {},
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    }
                                  }
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 64, right: 64, top: 12, bottom: 12),
                          child: Text(
                            "Get Loan",
                            style: GoogleFonts.poppins(
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
  }

  feeDistribution(t, f) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              t.toString(),
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
            ),
            Spacer(),
            Text(
              f.toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cabin(
                  textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
            ),
          ],
        ),
        SizedBox(
          height: 4,
        ),
        Divider(),
        SizedBox(
          height: 12,
        )
      ],
    );
  }
}
