import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'dart:io';
import '../get_loan_page.dart';
import '../loan_details.dart';
// ignore_for_file: prefer_const_constructors

class LoanStatusPage extends StatefulWidget {
  const LoanStatusPage({Key? key}) : super(key: key);

  @override
  _LoanStatusPageState createState() => _LoanStatusPageState();
}

class _LoanStatusPageState extends State<LoanStatusPage> {
  bool toggle = true;
  var userNum = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  var time1 = DateTime.now().toLocal();
  var connection = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitialData();
    internet();
  }

  getInitialData() async {
    var useAmount = 0.0;
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    setState(() {
      userNum = uid!.substring(3, 13);
    });
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
        : ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 48,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                toggle = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  color: toggle
                                      ? Color(0xff212A34)
                                      : Color(0xffF5F6F8)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 12, top: 8, bottom: 8),
                                child: Center(
                                  child: Text(
                                    "Running",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: toggle
                                            ? Colors.white
                                            : Color(0xff7E858D),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                toggle = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  color: !toggle
                                      ? Color(0xff212A34)
                                      : Color(0xffF5F6F8)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 12, top: 8, bottom: 8),
                                child: Center(
                                  child: Text(
                                    "Completed",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: !toggle
                                              ? Colors.white
                                              : Color(0xff7E858D)),
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
                    StreamBuilder<QuerySnapshot>(
                      stream: toggle
                          ? FirebaseFirestore.instance
                              .collection('loan')
                              .where("user_num", isEqualTo: userNum)
                              .where('status', whereIn: ["initiated", "paid"])
                              .orderBy('date_time')
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection('loan')
                              .where("user_num", isEqualTo: userNum)
                              .where('status',
                                  whereIn: ["payment", "close", "failed"])
                              .orderBy('date_time')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot doc =
                                    snapshot.data!.docs[index];
                                return loanBox(
                                  discount: doc['late_discount'],
                                  loanId: doc['loan_id'],
                                  loanAmt: doc['loan_amt'],
                                  loanDate: doc['loan_date'],
                                  loanStatus: doc['status'],
                                  loanDueDat: doc['repayment'],
                                  loanDisAmt: doc['dis_amt'],
                                  upi: doc['upi_id'],
                                  fData: doc['failed_data'],
                                  extended: doc['extended'],
                                  extTime: doc['extended_time'],
                                  e1amt: doc['extended_one_payment'],
                                  e1date: doc['extended_one_date'],
                                  e1rep: doc['extended_one_repayment'],
                                  e2amt: doc['extended_two_payment'],
                                  e2date: doc['extended_two_date'],
                                  e2rep: doc['extended_two_repayment'],
                                );
                              });
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 64,
                              ),
                              Center(
                                  child: Text("No Data Available",
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ))),
                            ],
                          );
                        }
                      },
                    ),
                    // loanBox(),
                  ],
                ),
              ),
            ],
          );
  }

  loanBox(
      {fData,
      loanId,
      loanDate,
      loanAmt,
      loanDueDat,
      loanStatus,
      loanDisAmt,
      upi,
      extended,
      extTime,
      e1date,
      e1amt,
      e1rep,
      e2date,
      e2amt,
      e2rep,
      discount}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoanDetailsPage(
                      delay: extended.toString() == "true"
                          ? extTime == 1
                              ? int.tryParse(DateTime.tryParse(e1date)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays.toString())! >=
                                      0
                                  ? 0
                                  : int.tryParse(DateTime.tryParse(e1date)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays.toString())!
                                      .abs()
                              : int.tryParse(DateTime.tryParse(e2date)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays.toString())! >=
                                      0
                                  ? 0
                                  : int.tryParse(DateTime.tryParse(e2date)!
                                          .difference(DateTime(time1.year,
                                              time1.month, time1.day))
                                          .inDays
                                          .toString())!
                                      .abs()
                          : int.tryParse(DateTime.tryParse(loanDueDat)!
                                      .difference(DateTime(
                                          time1.year, time1.month, time1.day))
                                      .inDays
                                      .toString())! >=
                                  0
                              ? 0
                              : int.tryParse(DateTime.tryParse(loanDueDat)!
                                      .difference(DateTime(
                                          time1.year, time1.month, time1.day))
                                      .inDays
                                      .toString())!
                                  .abs(),
                      user: userNum,
                      status: loanStatus,
                      upi: upi,
                      loanIds: loanId,
                      type: "loanRepayment",
                      disAmt: loanDisAmt,
                      payAmt: loanAmt,
                      repDate: Jiffy(DateTime.parse(loanDueDat))
                          .format("d MMM yyyy")
                          .toString(),
                      fData: fData,
                      e1amt: e1amt,
                      e1date: e1date == ""
                          ? ""
                          : Jiffy(DateTime.parse(e1date))
                              .format("d MMM yyyy")
                              .toString(),
                      e1rep: e1rep,
                      e2amt: e2amt,
                      e2date: e2date == ""
                          ? ""
                          : Jiffy(DateTime.parse(e2date))
                              .format("d MMM yyyy")
                              .toString(),
                      e2rep: e2rep,
                      extended: extended,
                      extTime: int.tryParse(extTime.toString()),
                      rawe1date: e1date,
                      rawe2date: e2date,
                      loanDate: loanDate,
                      discount: discount,
                    )),
          );
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 48,
          child: Row(
            children: [
              Container(
                height: (MediaQuery.of(context).size.width / 4) - 32,
                width: (MediaQuery.of(context).size.width / 4) - 32,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    color: Color(0xffFE7977)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Jiffy(DateTime.tryParse(loanDate)).format("MMM"),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      Jiffy(DateTime.tryParse(loanDate)).format("d"),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 16.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "Amount",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            loanStatus == "initiated" || loanStatus == "paid"
                                ? "₹ ${extended.toString() == "true" ? extTime == 1 ? e1rep : e2rep : loanAmt}"
                                : "₹ $loanAmt",
                            style: GoogleFonts.cabin(
                                textStyle: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 36,
                      ),
                      Column(
                        children: [
                          Text(
                            "Due Date",
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500)),
                          ),
                          Text(
                            extended.toString() == "true"
                                ? extTime == 1
                                    ? Jiffy(DateTime.tryParse(e1date))
                                        .format("do MMM")
                                    : Jiffy(DateTime.tryParse(e2date))
                                        .format("do MMM")
                                : Jiffy(DateTime.tryParse(loanDueDat))
                                    .format("do MMM"),
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  loanStatus == "payment"
                      ? Text(
                          "Loan Closing..",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        )
                      : loanStatus == "close"
                          ? Text(
                              "Loan Closed",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff00C898),
                                ),
                              ),
                            )
                          : loanStatus == "initiated"
                              ? Text(
                                  "Processing Payment",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                )
                              : loanStatus == "failed"
                                  ? Text(
                                      "Loan failed",
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  : extended == true
                                      ? extTime == 1
                                          ? int.tryParse(
                                                      DateTime.tryParse(e1date)!
                                                          .difference(DateTime(
                                                              time1.year,
                                                              time1.month,
                                                              time1.day))
                                                          .inDays
                                                          .toString())! >=
                                                  0
                                              ? Text(
                                                  "${DateTime.tryParse(extended.toString() == "true" ? extTime == 1 ? e1date : e2date : loanDueDat)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays}"
                                                  " Days Remaining",
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: int.tryParse(DateTime
                                                                      .tryParse(
                                                                          e1date)!
                                                                  .difference(DateTime(
                                                                      time1
                                                                          .year,
                                                                      time1
                                                                          .month,
                                                                      time1
                                                                          .day))
                                                                  .inDays
                                                                  .toString())! <=
                                                              5
                                                          ? Colors.redAccent
                                                          : Color(0xff00C898),
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  "Overdue by ${int.tryParse(DateTime.tryParse(e1date)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays.toString())!.abs()}"
                                                  " Days",
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                )
                                          : int.tryParse(
                                                      DateTime.tryParse(e2date)!
                                                          .difference(DateTime(
                                                              time1.year,
                                                              time1.month,
                                                              time1.day))
                                                          .inDays
                                                          .toString())! >=
                                                  0
                                              ? Text(
                                                  "${DateTime.tryParse(extended.toString() == "true" ? extTime == 1 ? e1date : e2date : loanDueDat)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays}"
                                                  " Days Remaining",
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: int.tryParse(DateTime
                                                                      .tryParse(
                                                                          e2date)!
                                                                  .difference(DateTime(
                                                                      time1
                                                                          .year,
                                                                      time1
                                                                          .month,
                                                                      time1
                                                                          .day))
                                                                  .inDays
                                                                  .toString())! <=
                                                              5
                                                          ? Colors.redAccent
                                                          : Color(0xff00C898),
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  "Overdue by ${int.tryParse(DateTime.tryParse(e2date)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays.toString())!.abs()}"
                                                  " Days",
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                )
                                      : int.tryParse(
                                                  DateTime.tryParse(loanDueDat)!
                                                      .difference(DateTime(
                                                          time1.year,
                                                          time1.month,
                                                          time1.day))
                                                      .inDays
                                                      .toString())! >=
                                              0
                                          ? Text(
                                              "${DateTime.tryParse(extended.toString() == "true" ? extTime == 1 ? e1date : e2date : loanDueDat)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays}"
                                              " Days Remaining",
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: int.tryParse(DateTime
                                                                  .tryParse(
                                                                      loanDueDat)!
                                                              .difference(
                                                                  DateTime(
                                                                      time1
                                                                          .year,
                                                                      time1
                                                                          .month,
                                                                      time1
                                                                          .day))
                                                              .inDays
                                                              .toString())! <=
                                                          5
                                                      ? Colors.redAccent
                                                      : Color(0xff00C898),
                                                ),
                                              ),
                                            )
                                          : Text(
                                              "Overdue by ${int.tryParse(DateTime.tryParse(loanDueDat)!.difference(DateTime(time1.year, time1.month, time1.day)).inDays.toString())!.abs()}"
                                              " Days",
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                ],
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios),
              SizedBox(
                width: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
