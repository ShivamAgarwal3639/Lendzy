import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:Lendzy/payment_success_failed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer' as dev;
import 'package:jiffy/jiffy.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'main.dart';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'notification.dart';
// ignore_for_file: prefer_const_constructors

class LoanDetailsPage extends StatefulWidget {
  const LoanDetailsPage({
    Key? key,
    this.disAmt,
    this.payAmt,
    this.repDate,
    this.type,
    this.loanIds,
    this.upi,
    this.status,
    this.user,
    this.delay,
    this.fData,
    this.e1amt,
    this.e1date,
    this.e1rep,
    this.e2amt,
    this.e2date,
    this.e2rep,
    this.extended,
    this.extTime,
    this.rawe1date,
    this.rawe2date,
    this.loanDate,
    this.discount
  }) : super(key: key);
  final disAmt;
  final payAmt;
  final repDate;
  final type;
  final loanIds;
  final upi;
  final status;
  final user;
  final delay;
  final fData;
  final extended,
      extTime,
      e1date,
      e1amt,
      e1rep,
      e2date,
      e2amt,
      e2rep,
      rawe1date,
      rawe2date,
      loanDate,discount;

  @override
  _LoanDetailsPageState createState() => _LoanDetailsPageState();
}

class _LoanDetailsPageState extends State<LoanDetailsPage> {
  var totalLimit = 0;
  var usedLimit = 0;
  late var userNumber;

  final FirebaseAuth auth = FirebaseAuth.instance;
  late Razorpay _razorpay;

  var paymentType = 0;
  var time1 = DateTime.now().toLocal();

  var paymentBody;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // log(DateTime.parse(widget.loanDate).difference(DateTime.now()).inDays.toString() );
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getInitialData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response)async {
    // Do something when payment succeeds
    if(paymentType ==0){
      var responses = response.orderId;
      var response1 = response.paymentId;
      var response2 = response.signature;
      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .collection("status")
          .doc()
          .set({
        "orderId": responses,
        "paymentId": response1,
        "signature": response2,
        "body":paymentBody,
        "type":"Success",
        "message":"",
        "time":Timestamp.now(),
      });

      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .update({
        'status': 'payment',
      });

      var loanAmt = double.tryParse(widget.payAmt) as double;
      var usedLim = (usedLimit - loanAmt).toInt();
      FirebaseFirestore.instance.collection("user").doc(widget.user).update(
        {
          'used_limit': usedLim < 0 ? 0.toString() : usedLim.toString(),
        },
      );
      QuerySnapshot eventsQuery =
      await FirebaseFirestore.instance.collection("admin").get();
      for (var document in eventsQuery.docs) {
        NotificationHandler.sendNotification(
            title: "Loan Closing request",
            body:
            "There is a Loan closing request of ${widget.payAmt} from ${widget
                .user}",
            to: document["fcm_id"],
        );
      }

      if (widget.delay <= 0 && DateTime.parse(widget.loanDate).difference(DateTime(time1.year, time1.month, time1.day)).inDays <= -15) {
        int newLimit =
        calculateNumber((int.tryParse(totalLimit.toString())! ~/ 2));
        var finalLimit =
        totalLimit + newLimit >= 5000 ? 5000 : totalLimit + newLimit;
        FirebaseFirestore.instance
            .collection("user")
            .doc(widget.user)
            .update(
          {
            'limit': finalLimit.toString(),
          },
        );
      }

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TransactionSuccess()),
              (Route<dynamic> route) => false);
    }
    if(paymentType ==1){

      var time2 = DateTime.now().add(Duration(days: 30)).toLocal();
      time2 = DateTime(time2.year, time2.month, time2.day);
      var responses = response.orderId;
      var response1 = response.paymentId;
      var response2 = response.signature;
      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .collection("status")
          .doc()
          .set({
        "orderId": responses,
        "paymentId": response1,
        "signature": response2,
        "body":paymentBody,
        "type":"Success",
        "message":"",
        "time":Timestamp.now(),
      });

      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .update({
        'pp_done':false,
        'status': 'paid',
        'extended': true,
        'extended_time': widget.extTime == 0 ? 1 :widget.extTime == 1? 2:3,
        'extended_one_payment': widget.extTime == 0
            ? leftOver.toStringAsFixed(2)
            : widget.e1amt,
        'extended_one_repayment':
        widget.extTime == 0 ? repAmt.toStringAsFixed(2) : widget.e1rep,
        'extended_one_date':
        widget.extTime == 0 ? time2.toString() : widget.rawe1date,
        'extended_two_payment': widget.extTime == 1
            ? leftOver.toStringAsFixed(2)
            : widget.e2amt,
        'extended_two_repayment':
        widget.extTime == 1 ? repAmt.toStringAsFixed(2) : widget.e2rep,
        'extended_two_date':
        widget.extTime == 1 ? time2.toString() : widget.rawe2date,
        'partial_valid': false,
      });

      var loanAmt = double.tryParse(nowAmt.toString()) as double;
      var usedLim = (usedLimit - loanAmt).toInt();
      FirebaseFirestore.instance.collection("user").doc(widget.user).update(
        {
          'used_limit': usedLim < 0 ? 0.toString() : usedLim.toString(),
        },
      );
      QuerySnapshot eventsQuery =
      await FirebaseFirestore.instance.collection("admin").get();
      for (var document in eventsQuery.docs) {
        NotificationHandler.sendNotification(
            title: "Loan Partial payment",
            body:
            "There is a partial payment of a loan from ${widget.user}",
            to: document["fcm_id"]);
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TransactionSuccess()),
              (Route<dynamic> route) => false);
    }
    else if(paymentType ==2){
      var responses = response.orderId;
      var response1 = response.paymentId;
      var response2 = response.signature;
      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .collection("status")
          .doc()
          .set({
        "orderId": responses,
        "paymentId": response1,
        "signature": response2,
        "body":paymentBody,
        "type":"Success",
        "message":"",
        "time":Timestamp.now(),
      });

      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .update({
        'status': 'payment',
      });

      var loanAmt = double.tryParse(widget.e2amt) as double;
      var usedLim = (usedLimit - loanAmt).toInt();
      FirebaseFirestore.instance.collection("user").doc(widget.user).update(
        {
          'used_limit': usedLim < 0 ? 0.toString() : usedLim.toString(),
        },
      );
      QuerySnapshot eventsQuery =
      await FirebaseFirestore.instance.collection("admin").get();
      for (var document in eventsQuery.docs) {
        NotificationHandler.sendNotification(
            title: "Loan Closing request",
            body:
            "There is a Loan closing request of ${widget.e2amt} from ${widget.user}",
            to: document["fcm_id"]);
      }

      if (widget.delay <= 0) {
        int newLimit =
        calculateNumber((int.tryParse(totalLimit.toString())! ~/ 2));
        var finalLimit =
        totalLimit + newLimit >= 5000 ? 5000 : totalLimit + newLimit;
        FirebaseFirestore.instance
            .collection("user")
            .doc(widget.user)
            .update(
          {
            'limit': finalLimit.toString(),
          },
        );
      }

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TransactionSuccess()),
              (Route<dynamic> route) => false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async{
    // Do something when payment fails
    if(paymentType ==0){
      var responses = response.message;
      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .collection("status")
          .doc()
          .set({
        "orderId": "",
        "paymentId": "",
        "signature": "",
        "body":paymentBody,
        "type":"Failed",
        "message":responses,
        "time":Timestamp.now(),
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TransactionFailed()),
              (Route<dynamic> route) => false);
    }else if(paymentType ==1){
      var responses = response.message;
      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .collection("status")
          .doc()
          .set({
        "orderId": "",
        "paymentId": "",
        "signature": "",
        "body":paymentBody,
        "type":"Failed",
        "message":responses,
        "time":Timestamp.now(),
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TransactionFailed()),
              (Route<dynamic> route) => false);
    }else if (paymentType ==2){
      var responses = response.message;
      FirebaseFirestore.instance
          .collection("loan")
          .doc(widget.loanIds)
          .collection("status")
          .doc()
          .set({
        "orderId": "",
        "paymentId": "",
        "signature": "",
        "body":paymentBody,
        "type":"Failed",
        "message":responses,
        "time":Timestamp.now(),
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TransactionFailed()),
              (Route<dynamic> route) => false);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    log("External Wallet Payment : "+response.toString());
  }

  var leftOver = 0.0;
  var processingFee = 0.0;
  var gst = 0.0;
  var interest = 0.0;
  var disAmt = 0.0;
  var repAmt = 0.0;
  List<double> amounts = [1.1, 2.2, 3.3];
  var nowAmt = 0.0;


  calcAmt() {
    if (widget.type == "loanRepayment") {
      var amnt = widget.extTime == 0
          ? widget.payAmt.toString()
          : widget.extTime == 1
              ? widget.e1rep
              : widget.e2rep;
      var num = double.tryParse(amnt.toString())! - nowAmt;
      var totInterest = num * (10 / 100);
      setState(() {
        interest =
            (double.tryParse((totInterest * (15 / 100)).toStringAsFixed(2)))!;
      });
      var pAndQ = totInterest - interest;
      setState(() {
        leftOver = num;
        gst = double.tryParse(
            (pAndQ * (15.25294117647059 / 100)).toStringAsFixed(2))!;
        processingFee = double.tryParse((pAndQ - gst).toStringAsFixed(2))!;
        disAmt = (double.tryParse((num - totInterest).toStringAsFixed(2)))!;
        repAmt = (num * 1.0) + (num * 0.1);
      });
    }
  }

  getInitialData() async {
    final User? user = auth.currentUser;
    final uid = user!.phoneNumber;
    setState(() {
      userNumber = uid!.substring(3, 13);
    });
    var collection = FirebaseFirestore.instance.collection('user');
    var docSnapshot = await collection.doc(uid!.substring(3, 13)).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['limit'];
      var uValue = data?['used_limit'];
      setState(() {
        totalLimit = int.tryParse(value)!;
        usedLimit = int.tryParse(uValue)!;
        if (widget.type == "loanRepayment") {
          amounts.clear();
          amounts.add((widget.extTime == 0
                  ? double.tryParse(widget.payAmt.toString())!
                  : widget.extTime == 1
                      ? double.tryParse(widget.e1rep.toString())!
                      : double.tryParse(widget.e2rep.toString())!) *
              0.25);
          amounts.add((widget.extTime == 0
                  ? double.tryParse(widget.payAmt.toString())!
                  : widget.extTime == 1
                      ? double.tryParse(widget.e1rep.toString())!
                      : double.tryParse(widget.e2rep.toString())!) *
              0.5);
          amounts.add((widget.extTime == 0
                  ? double.tryParse(widget.payAmt.toString())!
                  : widget.extTime == 1
                      ? double.tryParse(widget.e1rep.toString())!
                      : double.tryParse(widget.e2rep.toString())!) *
              0.75);
          nowAmt = amounts[1];
        }
      });

      calcAmt();
    }
  }

  var fontW = 13.0;

  int calculateNumber(int number) {
    int a = number % 100;

    if (a > 0) {
      return (number ~/ 100) * 100 + 100;
    }

    return number;
  }

  makePayment() async {
    if (widget.type == "loanRepayment") {
      // var match = {
      //   "orderId": widget.loanIds,
      //   // "orderAmount": widget.extended.toString() == "true"
      //   //     ? widget.extTime == 1
      //   //         ? (((double.tryParse(widget.e1rep.toString()) as double))
      //   //                     .toInt() +
      //   //                 (widget.delay / 100) *
      //   //                     (double.tryParse(widget.e1amt.toString()) as double)
      //   //                         .toInt())
      //   //             .toString()
      //   //         : (((double.tryParse(widget.e2rep.toString()) as double)
      //   //                     .toInt()) +
      //   //                 (widget.delay / 100) *
      //   //                     (double.tryParse(widget.e2amt.toString()) as double)
      //   //                         .toInt())
      //   //             .toString()
      //   //     : (((double.tryParse(widget.payAmt.toString()) as double).toInt()) +
      //   //             (widget.delay / 100) *
      //   //                 (double.tryParse(widget.payAmt.toString()) as double)
      //   //                     .toInt())
      //   //         .toString(),
      //   "orderAmount": widget.extended.toString() == "true"
      //       ? widget.extTime == 1
      //           ? ((double.tryParse(((double.tryParse(widget.e1rep.toString()) as double))
      //                       .toStringAsFixed(2))as double) +
      //                   (widget.delay / 100) *
      //                       double.tryParse((double.tryParse(widget.e1amt.toString()) as double)
      //                           .toStringAsFixed(2)))
      //               .toString()
      //           : ((double.tryParse((double.tryParse(widget.e2rep.toString()) as double)
      //                       .toStringAsFixed(2))as double) +
      //                   (widget.delay / 100) *
      //                       double.tryParse((double.tryParse(widget.e2amt.toString()) as double)
      //                           .toStringAsFixed(2)))
      //               .toString()
      //       : ((double.tryParse((double.tryParse(widget.payAmt.toString()) as double).toStringAsFixed(2))as double) +
      //               (widget.delay / 100) *
      //                   double.tryParse((double.tryParse(widget.payAmt.toString()) as double)
      //                       .toStringAsFixed(2)))
      //           .toString(),
      //   "orderCurrency": "INR"
      // };
      var response = await post(
          Uri.parse("https://test.cashfree.com/api/v2/cftoken/order"),
          headers: {
            'Content-Type': 'application/json',
            'x-client-id': '1358768da9bc1640cdebc2c851678531',
            'x-client-secret': '46df4ef77188de84b5a50fe225ec191a0e5129e1'
          },
          body: json.encode(match),
          encoding: Encoding.getByName("utf-8"));
      //
      // var tokenData = json.decode(response.body)["cftoken"];
      //
      // Map<String, dynamic> inputParams = {
      //   "orderId": widget.loanIds,
      //   "orderAmount": widget.extended.toString() == "true"
      //       ? widget.extTime == 1
      //       ? ((double.tryParse(((double.tryParse(widget.e1rep.toString()) as double))
      //       .toStringAsFixed(2))as double) +
      //       (widget.delay / 100) *
      //           double.tryParse((double.tryParse(widget.e1amt.toString()) as double)
      //               .toStringAsFixed(2)))
      //       .toString()
      //       : ((double.tryParse((double.tryParse(widget.e2rep.toString()) as double)
      //       .toStringAsFixed(2))as double) +
      //       (widget.delay / 100) *
      //           double.tryParse((double.tryParse(widget.e2amt.toString()) as double)
      //               .toStringAsFixed(2)))
      //       .toString()
      //       : ((double.tryParse((double.tryParse(widget.payAmt.toString()) as double).toStringAsFixed(2))as double) +
      //       (widget.delay / 100) *
      //           double.tryParse((double.tryParse(widget.payAmt.toString()) as double)
      //               .toStringAsFixed(2)))
      //       .toString(),
      //   // "orderAmount": widget.extended.toString() == "true"
      //   //     ? widget.extTime == 1
      //   //         ? (((double.tryParse(widget.e1rep.toString()) as double)
      //   //                     .toInt()) +
      //   //                 (widget.delay / 100) *
      //   //                     (double.tryParse(widget.e1amt.toString()) as double)
      //   //                         .toInt())
      //   //             .toString()
      //   //         : (((double.tryParse(widget.e2rep.toString()) as double)
      //   //                     .toInt()) +
      //   //                 (widget.delay / 100) *
      //   //                     (double.tryParse(widget.e2amt.toString()) as double)
      //   //                         .toInt())
      //   //             .toString()
      //   //     : (((double.tryParse(widget.payAmt.toString()) as double).toInt()) +
      //   //             (widget.delay / 100) *
      //   //                 (double.tryParse(widget.payAmt.toString()) as double)
      //   //                     .toInt())
      //   //         .toString(),
      //   "orderCurrency": "INR",
      //   "appId": "1358768da9bc1640cdebc2c851678531",
      //   "customerName": "Shivam Agarwal",
      //   "customerPhone": "8660453029",
      //   "customerEmail": "Shivamagarwal067@gmail.com",
      //   "stage": "TEST",
      //   "tokenData": tokenData,
      //   "notifyUrl": "",
      //   "orderNote": "this is test transaction",
      // };

      // CashfreePGSDK.doUPIPayment(inputParams).then((value) async {
      //   var data = Map<String, dynamic>.from(value!);
      //   if (data['txStatus'] == "SUCCESS") {
      //     FirebaseFirestore.instance
      //         .collection("loan")
      //         .doc(widget.loanIds)
      //         .collection("status")
      //         .doc()
      //         .set(data);
      //
      //     FirebaseFirestore.instance
      //         .collection("loan")
      //         .doc(widget.loanIds)
      //         .update({
      //       'status': 'payment',
      //     });
      //
      //     var loanAmt = double.tryParse(widget.payAmt) as double;
      //     var usedLim = (usedLimit - loanAmt).toInt();
      //     FirebaseFirestore.instance.collection("user").doc(widget.user).update(
      //       {
      //         'used_limit': usedLim < 0 ? 0.toString() : usedLim.toString(),
      //       },
      //     );
      //     QuerySnapshot eventsQuery =
      //         await FirebaseFirestore.instance.collection("admin").get();
      //     for (var document in eventsQuery.docs) {
      //       NotificationHandler.sendNotification(
      //           title: "Loan Closing request",
      //           body:
      //               "There is a Loan closing request of ${widget.payAmt} from ${widget.user}",
      //           to: document["fcm_id"]);
      //     }
      //
      //     if (widget.delay <= 0) {
      //       int newLimit =
      //           calculateNumber((int.tryParse(totalLimit.toString())! ~/ 2));
      //       var finalLimit =
      //           totalLimit + newLimit >= 5000 ? 5000 : totalLimit + newLimit;
      //       FirebaseFirestore.instance
      //           .collection("user")
      //           .doc(widget.user)
      //           .update(
      //         {
      //           'limit': finalLimit.toString(),
      //         },
      //       );
      //     }
      //
      //     Navigator.of(context).pushAndRemoveUntil(
      //         MaterialPageRoute(builder: (context) => TransactionSuccess()),
      //         (Route<dynamic> route) => false);
      //   }else{
      //     Navigator.of(context).pushAndRemoveUntil(
      //         MaterialPageRoute(builder: (context) => TransactionFailed()),
      //             (Route<dynamic> route) => false);
      //   }
      // });

      setState(() {
        paymentType =0;
      });

      var myRazorPayRes = {
        "amount": widget.extended.toString() == "true"
            ? widget.extTime == 1
            ? ((double.tryParse(((double.tryParse(((double.tryParse(widget.e1rep.toString()) as double))
            .toStringAsFixed(2))as double) +
            (widget.delay / 100) *
                double.tryParse((double.tryParse(widget.e1amt.toString()) as double)
                    .toStringAsFixed(2)))
            .toString())as double) - widget.discount)
        *100
            : ((double.tryParse(((double.tryParse((double.tryParse(widget.e2rep.toString()) as double)
            .toStringAsFixed(2))as double) +
            (widget.delay / 100) *
                double.tryParse((double.tryParse(widget.e2amt.toString()) as double)
                    .toStringAsFixed(2)))
            .toString())as double) - widget.discount)
        *100
            : ((double.tryParse(((double.tryParse((double.tryParse(widget.payAmt.toString()) as double).toStringAsFixed(2))as double) +
            (widget.delay / 100) *
                double.tryParse((double.tryParse(widget.payAmt.toString()) as double)
                    .toStringAsFixed(2)))
            .toString())as double) - widget.discount)
        *100,
        "currency": "INR",
        "receipt": widget.loanIds,
      };
      var razResponse = await post(
          Uri.parse("https://api.razorpay.com/v1/orders"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':'Basic cnpwX2xpdmVfdHVYV1l5MmxBdVlsbFY6Z2d3MkwzU0RaanFSTkxHdnNyaHZqanFG'
          },
          body: json.encode(myRazorPayRes),

          encoding: Encoding.getByName("utf-8"));

      var orderId = json.decode(razResponse.body)["id"];

      var options = {
        'key': 'rzp_live_tuXWYy2lAuYllV',
        'amount': widget.extended.toString() == "true"
            ? widget.extTime == 1
            ? ((double.tryParse(((double.tryParse(((double.tryParse(widget.e1rep.toString()) as double))
            .toStringAsFixed(2))as double) +
            (widget.delay / 100) *
                double.tryParse((double.tryParse(widget.e1amt.toString()) as double)
                    .toStringAsFixed(2)))
            .toString())as double) - widget.discount)
            *100
            : ((double.tryParse(((double.tryParse((double.tryParse(widget.e2rep.toString()) as double)
            .toStringAsFixed(2))as double) +
            (widget.delay / 100) *
                double.tryParse((double.tryParse(widget.e2amt.toString()) as double)
                    .toStringAsFixed(2)))
            .toString())as double) - widget.discount)
            *100
            : ((double.tryParse(((double.tryParse((double.tryParse(widget.payAmt.toString()) as double).toStringAsFixed(2))as double) +
            (widget.delay / 100) *
                double.tryParse((double.tryParse(widget.payAmt.toString()) as double)
                    .toStringAsFixed(2)))
            .toString())as double) - widget.discount)
            *100,
        'name': 'Lendzy',
        'order_id': orderId, // Generate order_id using Orders API
        'description': 'PaymentId: ${widget.loanIds}',
        'timeout': 60, // in seconds
        'prefill': {
          'contact': userNumber,
          'email': 'lendzyindia@gmail.com'
        },
        "notes": {
          "number": userNumber,
          "amount": widget.extended.toString() == "true"
              ? widget.extTime == 1
              ? ((double.tryParse(((double.tryParse(((double.tryParse(widget.e1rep.toString()) as double))
              .toStringAsFixed(2))as double) +
              (widget.delay / 100) *
                  double.tryParse((double.tryParse(widget.e1amt.toString()) as double)
                      .toStringAsFixed(2)))
              .toString())as double) - widget.discount)
              *100
              : ((double.tryParse(((double.tryParse((double.tryParse(widget.e2rep.toString()) as double)
              .toStringAsFixed(2))as double) +
              (widget.delay / 100) *
                  double.tryParse((double.tryParse(widget.e2amt.toString()) as double)
                      .toStringAsFixed(2)))
              .toString())as double) - widget.discount)
              *100
              : ((double.tryParse(((double.tryParse((double.tryParse(widget.payAmt.toString()) as double).toStringAsFixed(2))as double) +
              (widget.delay / 100) *
                  double.tryParse((double.tryParse(widget.payAmt.toString()) as double)
                      .toStringAsFixed(2)))
              .toString())as double) - widget.discount)
              *100,
          "dTime":DateTime.now().toString(),
          "lId":widget.loanIds,
          "rId": widget.loanIds,
        }
      };

      setState(() {
        paymentBody = options;
      });

      _razorpay.open(options);
    }
  }

  payPartial() async {
    if (widget.type == "loanRepayment") {
      // var match = {
      //   "orderId": widget.loanIds + widget.extTime.toString(),
      //   // "orderAmount":
      //   //     (((double.tryParse(nowAmt.toString()) as double).toInt()) +
      //   //             (widget.delay / 100) *
      //   //                 (double.tryParse(widget.extTime == 0
      //   //                         ? widget.payAmt.toString()
      //   //                         : widget.e1amt.toString()) as double)
      //   //                     .toInt())
      //   //         .toString(),
      //   "orderAmount": ((double.tryParse(
      //               (double.tryParse(nowAmt.toString()) as double)
      //                   .toStringAsFixed(2)) as double) +
      //           (widget.delay / 100) *
      //               double.tryParse((double.tryParse(widget.extTime == 0
      //                       ? widget.payAmt.toString()
      //                       : widget.e1amt.toString()) as double)
      //                   .toStringAsFixed(2)))
      //       .toString(),
      //   "orderCurrency": "INR"
      // };
      // var response = await post(
      //     Uri.parse("https://test.cashfree.com/api/v2/cftoken/order"),
      //     headers: {
      //       'Content-Type': 'application/json',
      //       'x-client-id': '1358768da9bc1640cdebc2c851678531',
      //       'x-client-secret': '46df4ef77188de84b5a50fe225ec191a0e5129e1'
      //     },
      //     body: json.encode(match),
      //     encoding: Encoding.getByName("utf-8"));
      //
      // var tokenData = json.decode(response.body)["cftoken"];
      //
      // Map<String, dynamic> inputParams = {
      //   "orderId": widget.loanIds + widget.extTime.toString(),
      //   "orderAmount":
      //       // (((double.tryParse(nowAmt.toString()) as double).toInt()) +
      //       //         (widget.delay / 100) *
      //       //             (double.tryParse(widget.extTime == 0
      //       //                     ? widget.payAmt.toString()
      //       //                     : widget.e1amt.toString()) as double)
      //       //                 .toInt())
      //       //     .toString(),
      //       ((double.tryParse((double.tryParse(nowAmt.toString()) as double)
      //                   .toStringAsFixed(2)) as double) +
      //               (widget.delay / 100) *
      //                   double.tryParse((double.tryParse(widget.extTime == 0
      //                           ? widget.payAmt.toString()
      //                           : widget.e1amt.toString()) as double)
      //                       .toStringAsFixed(2)))
      //           .toString(),
      //   "orderCurrency": "INR",
      //   "appId": "1358768da9bc1640cdebc2c851678531",
      //   "customerName": "Shivam Agarwal",
      //   "customerPhone": "8660453029",
      //   "customerEmail": "Shivamagarwal067@gmail.com",
      //   "stage": "TEST",
      //   "tokenData": tokenData,
      //   "notifyUrl": "",
      //   "orderNote": "this is test transaction",
      // };
      // var time2 = DateTime.now().add(Duration(days: 30)).toLocal();
      // time2 = DateTime(time2.year, time2.month, time2.day);
      //
      // CashfreePGSDK.doUPIPayment(inputParams).then((value) async {
      //   var data = Map<String, dynamic>.from(value!);
      //   if (data['txStatus'] == "SUCCESS") {
      //     FirebaseFirestore.instance
      //         .collection("loan")
      //         .doc(widget.loanIds)
      //         .collection("status")
      //         .doc()
      //         .set(data);
      //
      //     FirebaseFirestore.instance
      //         .collection("loan")
      //         .doc(widget.loanIds)
      //         .update({
      //       'status': 'paid',
      //       'extended': true,
      //       'extended_time': widget.extTime == 0 ? 1 :widget.extTime == 1? 2:3,
      //       'extended_one_payment': widget.extTime == 0
      //           ? leftOver.toStringAsFixed(2)
      //           : widget.e1amt,
      //       'extended_one_repayment':
      //           widget.extTime == 0 ? repAmt.toStringAsFixed(2) : widget.e1rep,
      //       'extended_one_date':
      //           widget.extTime == 0 ? time2.toString() : widget.rawe1date,
      //       'extended_two_payment': widget.extTime == 1
      //           ? leftOver.toStringAsFixed(2)
      //           : widget.e2amt,
      //       'extended_two_repayment':
      //           widget.extTime == 1 ? repAmt.toStringAsFixed(2) : widget.e2rep,
      //       'extended_two_date':
      //           widget.extTime == 1 ? time2.toString() : widget.rawe2date,
      //       'partial_valid': false,
      //     });
      //
      //     var loanAmt = double.tryParse(nowAmt.toString()) as double;
      //     var usedLim = (usedLimit - loanAmt).toInt();
      //     FirebaseFirestore.instance.collection("user").doc(widget.user).update(
      //       {
      //         'used_limit': usedLim < 0 ? 0.toString() : usedLim.toString(),
      //       },
      //     );
      //     QuerySnapshot eventsQuery =
      //         await FirebaseFirestore.instance.collection("admin").get();
      //     for (var document in eventsQuery.docs) {
      //       NotificationHandler.sendNotification(
      //           title: "Loan Partial payment",
      //           body:
      //               "There is a partial payment of a loan from ${widget.user}",
      //           to: document["fcm_id"]);
      //     }
      //     Navigator.of(context).pushAndRemoveUntil(
      //         MaterialPageRoute(builder: (context) => TransactionSuccess()),
      //             (Route<dynamic> route) => false);
      //   }else{
      //     Navigator.of(context).pushAndRemoveUntil(
      //         MaterialPageRoute(builder: (context) => TransactionFailed()),
      //             (Route<dynamic> route) => false);
      //   }
      // });


      setState(() {
        paymentType =1;
      });

      var myRazorPayRes = {
        "amount": double.tryParse(((double.tryParse((double.tryParse(nowAmt.toString()) as double)
            .toStringAsFixed(2)) as double) +
            (widget.delay / 100) *
                double.tryParse((double.tryParse(widget.extTime == 0
                    ? widget.payAmt.toString()
                    : widget.e1amt.toString()) as double)
                    .toStringAsFixed(2)))
            .toString())
        !*100,
        "currency": "INR",
        "receipt": widget.loanIds + widget.extTime.toString(),
      };
      var razResponse = await post(
          Uri.parse("https://api.razorpay.com/v1/orders"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':'Basic cnpwX2xpdmVfdHVYV1l5MmxBdVlsbFY6Z2d3MkwzU0RaanFSTkxHdnNyaHZqanFG'
          },
          body: json.encode(myRazorPayRes),

          encoding: Encoding.getByName("utf-8"));

      var orderId = json.decode(razResponse.body)["id"];

      var options = {
        'key': 'rzp_live_tuXWYy2lAuYllV',
        'amount': double.tryParse(((double.tryParse((double.tryParse(nowAmt.toString()) as double)
            .toStringAsFixed(2)) as double) +
            (widget.delay / 100) *
                double.tryParse((double.tryParse(widget.extTime == 0
                    ? widget.payAmt.toString()
                    : widget.e1amt.toString()) as double)
                    .toStringAsFixed(2)))
            .toString())
        !*100,//in the smallest currency sub-unit.
        'name': 'Lendzy',
        'order_id': orderId, // Generate order_id using Orders API
        'description': 'PaymentId: ${widget.loanIds + widget.extTime.toString()}',
        'timeout': 60, // in seconds
        'prefill': {
          'contact': userNumber,
          'email': 'lendzyindia@gmail.com'
        },
        "notes": {
          "number": userNumber,
          "amount": double.tryParse(((double.tryParse((double.tryParse(nowAmt.toString()) as double)
              .toStringAsFixed(2)) as double) +
              (widget.delay / 100) *
                  double.tryParse((double.tryParse(widget.extTime == 0
                      ? widget.payAmt.toString()
                      : widget.e1amt.toString()) as double)
                      .toStringAsFixed(2)))
              .toString())
          !*100,
          "dTime":DateTime.now().toString(),
          "lId":widget.loanIds,
          "rId": widget.loanIds + widget.extTime.toString(),
        }

      };

      setState(() {
        paymentBody = options;
      });

      _razorpay.open(options);

    }
  }

  makeFullPayment() async {
    if (widget.type == "loanRepayment") {
      // var match = {
      //   "orderId": widget.loanIds + widget.extTime.toString(),
      //   // "orderAmount":
      //   //     (((double.tryParse(widget.e2rep.toString()) as double).toInt()) +
      //   //             (widget.delay / 100) *
      //   //                 (double.tryParse(widget.e2amt.toString()) as double)
      //   //                     .toInt())
      //   //         .toString(),
      //   "orderAmount": ((double.tryParse(
      //               (double.tryParse(widget.e2rep.toString()) as double)
      //                   .toStringAsFixed(2)) as double) +
      //           (widget.delay / 100) *
      //               double.tryParse(
      //                   (double.tryParse(widget.e2amt.toString()) as double)
      //                       .toStringAsFixed(2)))
      //       .toString(),
      //   "orderCurrency": "INR"
      // };
      // var response = await post(
      //     Uri.parse("https://test.cashfree.com/api/v2/cftoken/order"),
      //     headers: {
      //       'Content-Type': 'application/json',
      //       'x-client-id': '1358768da9bc1640cdebc2c851678531',
      //       'x-client-secret': '46df4ef77188de84b5a50fe225ec191a0e5129e1'
      //     },
      //     body: json.encode(match),
      //     encoding: Encoding.getByName("utf-8"));
      //
      // var tokenData = json.decode(response.body)["cftoken"];
      //
      // Map<String, dynamic> inputParams = {
      //   "orderId": widget.loanIds + widget.extTime.toString(),
      //   // "orderAmount":
      //   //     (((double.tryParse(widget.e2rep.toString()) as double).toInt()) +
      //   //             (widget.delay / 100) *
      //   //                 (double.tryParse(widget.e2amt.toString()) as double)
      //   //                     .toInt())
      //   //         .toString(),
      //   "orderAmount": ((double.tryParse(
      //               (double.tryParse(widget.e2rep.toString()) as double)
      //                   .toStringAsFixed(2)) as double) +
      //           (widget.delay / 100) *
      //               double.tryParse(
      //                   (double.tryParse(widget.e2amt.toString()) as double)
      //                       .toStringAsFixed(2)))
      //       .toString(),
      //   "orderCurrency": "INR",
      //   "appId": "1358768da9bc1640cdebc2c851678531",
      //   "customerName": "Shivam Agarwal",
      //   "customerPhone": "8660453029",
      //   "customerEmail": "Shivamagarwal067@gmail.com",
      //   "stage": "TEST",
      //   "tokenData": tokenData,
      //   "notifyUrl": "",
      //   "orderNote": "this is test transaction",
      // };
      //
      // CashfreePGSDK.doUPIPayment(inputParams).then((value) async {
      //   var data = Map<String, dynamic>.from(value!);
      //   if (data['txStatus'] == "SUCCESS") {
      //     FirebaseFirestore.instance
      //         .collection("loan")
      //         .doc(widget.loanIds)
      //         .collection("status")
      //         .doc()
      //         .set(data);
      //
      //     FirebaseFirestore.instance
      //         .collection("loan")
      //         .doc(widget.loanIds)
      //         .update({
      //       'status': 'payment',
      //     });
      //
      //     var loanAmt = double.tryParse(widget.e2amt) as double;
      //     var usedLim = (usedLimit - loanAmt).toInt();
      //     FirebaseFirestore.instance.collection("user").doc(widget.user).update(
      //       {
      //         'used_limit': usedLim < 0 ? 0.toString() : usedLim.toString(),
      //       },
      //     );
      //     QuerySnapshot eventsQuery =
      //         await FirebaseFirestore.instance.collection("admin").get();
      //     for (var document in eventsQuery.docs) {
      //       NotificationHandler.sendNotification(
      //           title: "Loan Closing request",
      //           body:
      //               "There is a Loan closing request of ${widget.e2amt} from ${widget.user}",
      //           to: document["fcm_id"]);
      //     }
      //
      //     if (widget.delay <= 0) {
      //       int newLimit =
      //           calculateNumber((int.tryParse(totalLimit.toString())! ~/ 2));
      //       var finalLimit =
      //           totalLimit + newLimit >= 5000 ? 5000 : totalLimit + newLimit;
      //       FirebaseFirestore.instance
      //           .collection("user")
      //           .doc(widget.user)
      //           .update(
      //         {
      //           'limit': finalLimit.toString(),
      //         },
      //       );
      //     }
      //
      //     Navigator.of(context).pushAndRemoveUntil(
      //         MaterialPageRoute(builder: (context) => TransactionSuccess()),
      //             (Route<dynamic> route) => false);
      //   }else{
      //     Navigator.of(context).pushAndRemoveUntil(
      //         MaterialPageRoute(builder: (context) => TransactionFailed()),
      //             (Route<dynamic> route) => false);
      //   }
      // });
      setState(() {
        paymentType =2;
      });

      var myRazorPayRes = {
        "amount": ((double.tryParse(((double.tryParse(
            (double.tryParse(widget.e2rep.toString()) as double)
                .toStringAsFixed(2)) as double) +
            (widget.delay / 100) *
                double.tryParse(
                    (double.tryParse(widget.e2amt.toString()) as double)
                        .toStringAsFixed(2)))
            .toString())as double) -  widget.discount)
        *100
        ,
        "currency": "INR",
        "receipt": widget.loanIds + widget.extTime.toString(),
      };
      var razResponse = await post(
          Uri.parse("https://api.razorpay.com/v1/orders"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':'Basic cnpwX2xpdmVfdHVYV1l5MmxBdVlsbFY6Z2d3MkwzU0RaanFSTkxHdnNyaHZqanFG'
          },
          body: json.encode(myRazorPayRes),

          encoding: Encoding.getByName("utf-8"));

      var orderId = json.decode(razResponse.body)["id"];

      var options = {
        'key': 'rzp_live_tuXWYy2lAuYllV',
        'amount': ((double.tryParse(((double.tryParse(
            (double.tryParse(widget.e2rep.toString()) as double)
                .toStringAsFixed(2)) as double) +
            (widget.delay / 100) *
                double.tryParse(
                    (double.tryParse(widget.e2amt.toString()) as double)
                        .toStringAsFixed(2)))
            .toString())as double) -  widget.discount)
            *100, //in the smallest currency sub-unit.
        'name': 'Lendzy',
        'order_id': orderId, // Generate order_id using Orders API
        'description': 'PaymentId: ${widget.loanIds + widget.extTime.toString()}',
        'timeout': 60, // in seconds
        'prefill': {
          'contact': userNumber,
          'email': 'lendzyindia@gmail.com'
        },
        "notes": {
          "number": userNumber,
          "amount": ((double.tryParse(((double.tryParse(
              (double.tryParse(widget.e2rep.toString()) as double)
                  .toStringAsFixed(2)) as double) +
              (widget.delay / 100) *
                  double.tryParse(
                      (double.tryParse(widget.e2amt.toString()) as double)
                          .toStringAsFixed(2)))
              .toString())as double) -  widget.discount)
              *100,
          "dTime":DateTime.now().toString(),
          "lId":widget.loanIds,
          "rId": widget.loanIds + widget.extTime.toString(),
        }
      };

      setState(() {
        paymentBody = options;
      });

      _razorpay.open(options);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SizedBox(
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
                width: MediaQuery.of(context).size.width - 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Card(
                  margin: const EdgeInsets.all(0.0),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: (MediaQuery.of(context).size.width / 2.8) / 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          widget.type == "loanRepayment"
                              ? widget.status == "failed"
                                  ? "Oops!"
                                  : widget.status == "paid"
                                      ? "Loan Successful!"
                                      : widget.status == "close"
                                          ? "Loan Closed!"
                                          : widget.status == "initiated"
                                              ? "Processing!"
                                              : "Loan Closing!"
                              : "Great!",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: widget.status == "failed"
                                  ? Colors.red
                                  : Color(0xffFE7977),
                            ),
                          ),
                        ),
                        Text(
                          widget.type == "loanRepayment"
                              ? widget.status == "failed"
                                  ? "Loan Failed"
                                  : "Loan Details"
                              : "Loan Success",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            widget.type == "loanRepayment"
                                ? widget.status == "failed"
                                    ? widget.fData
                                    : widget.status == "paid"
                                        ? "Loan has been successfully disbursed to your bank account."
                                        : widget.status == "close"
                                            ? "You have paid the loan amount and it is successfully closed."
                                            : widget.status == "initiated"
                                                ? "Shortly you will receive the amount in your bank account."
                                                : "Loan closing is under process, shortly it will be closed."
                                : "Check the current status of the loan in My Loans section\n\nBelow is your loan Summary :",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                "Disbursal Amount",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: fontW,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff7C7A7A),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "₹"+widget.disAmt.toString(),
                                // "₹ ${widget.extended.toString() == "true" ? widget.extTime == 1 ? widget.e1amt.toString() : widget.e2amt.toString() : widget.disAmt.toString()}",
                                style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                )),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                "Loan Amount",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: fontW,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff7C7A7A),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                               "₹"+ widget.payAmt.toString(),
                                // "₹ ${widget.extended.toString() == "true" ? widget.extTime == 1 ? widget.e1amt.toString() : widget.e2amt.toString() : widget.disAmt.toString()}",
                                style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text("Payment Amount",
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: fontW,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff7C7A7A),
                                    ),
                                  )),
                              Spacer(),
                              Text(
                                "₹ ${widget.status =="paid" || widget.status =="initiated"?widget.extended.toString() == "true" ? widget.extTime == 1 ? widget.e1rep.toString() :widget.extTime == 2 ? widget.e2rep.toString():"0" : widget.payAmt.toString():"0"}",
                                style: GoogleFonts.cabin(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.only(left: 24.0, right: 24.0),
                        //   child: Row(
                        //     children: [
                        //       Text(
                        //         "Duration",
                        //         style: GoogleFonts.poppins(
                        //           textStyle: TextStyle(
                        //             fontSize: fontW,
                        //             fontWeight: FontWeight.w500,
                        //             color: Color(0xff7C7A7A),
                        //           ),
                        //         ),
                        //       ),
                        //       Spacer(),
                        //       Text(
                        //         "30 Days",
                        //         style: GoogleFonts.poppins(
                        //             textStyle: TextStyle(
                        //           fontSize: 13,
                        //           fontWeight: FontWeight.w600,
                        //           color: Colors.black,
                        //         )),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        Padding(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                userNumber =="1111111111"?"EMI Date":"Repayment Date",
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                  fontSize: fontW,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff7C7A7A),
                                )),
                              ),
                              Spacer(),
                              Text(
                                widget.extended.toString() == "true"
                                    ? widget.extTime == 1
                                        ? widget.e1date.toString()
                                        : widget.e2date.toString()
                                    : widget.repDate.toString(),
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                "Max Duration",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: fontW,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff7C7A7A),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "90 Days",
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                )),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                "UPI Id",
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                  fontSize: fontW,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff7C7A7A),
                                )),
                              ),
                              Spacer(),
                              Text(
                                widget.upi.toString(),
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                )),
                              ),
                            ],
                          ),
                        ),
                        widget.status == "paid"
                            ? Padding(
                          padding: const EdgeInsets.only(
                              left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                "Late Fine "
                                    "(1% per day)",
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: fontW,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff7C7A7A),
                                    )),
                              ),
                              Spacer(),
                              Text(
                                widget.delay == 0
                                    ? "₹0"
                                    : "₹" +
                                    ((widget.delay / 100) *
                                        (double.tryParse(widget
                                            .extended
                                            .toString() ==
                                            "true"
                                            ? widget.extTime ==
                                            1
                                            ? widget
                                            .e1amt
                                            .toString()
                                            : widget
                                            .e2amt
                                            .toString()
                                            : widget
                                            .payAmt
                                            .toString()) as double)
                                    )
                                        .toStringAsFixed(2),
                                style: GoogleFonts.cabin(
                                  textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            : SizedBox(),
                        widget.status == "paid" && widget.discount != 0
                            ? Padding(
                          padding: const EdgeInsets.only(
                              left: 24.0, right: 24.0),
                          child: Row(
                            children: [
                              Text(
                                "Discount",
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: fontW,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff7C7A7A),
                                    )),
                              ),
                              Spacer(),
                              Text(
                                "-"+widget.discount.toString(),
                                style: GoogleFonts.cabin(
                                  textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            : SizedBox(),
                        Divider(),
                        Text("Total Loan",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: fontW + 5.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff7C7A7A),
                              ),
                            )),
                        Text(
                          widget.status == "paid"
                              ? "₹ ${widget.extended.toString() == "true" ? widget.extTime == 1 ? ((double.tryParse((((double.tryParse(widget.e1rep.toString()) as double)) + (widget.delay / 100) * (double.tryParse(widget.e1amt.toString()) as double)).toString()) as double) - widget.discount).toStringAsFixed(2) : ((double.tryParse((((double.tryParse(widget.e2rep.toString()) as double)) + (widget.delay / 100) * (double.tryParse(widget.e2amt.toString()) as double)).toString())as double) - widget.discount).toStringAsFixed(2) : ((((double.tryParse(widget.payAmt.toString()) as double)) + (widget.delay / 100) * (double.tryParse(widget.payAmt.toString()) as double))- widget.discount).toStringAsFixed(2)}"
                              : "₹" +
                                  (double.tryParse(widget.payAmt.toString()) as double)
                                      .toString(),
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff00C898),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ((MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).size.height / 1.5)) /
                      2) -
                  ((MediaQuery.of(context).size.width / 2.8) / 2),
              left: (MediaQuery.of(context).size.width / 2) -
                  ((MediaQuery.of(context).size.width / 2.8) / 2),
              child: Container(
                height: MediaQuery.of(context).size.width / 2.8,
                width: MediaQuery.of(context).size.width / 2.8,
                decoration: BoxDecoration(
                  color: Color(0xffFE7977).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
            ),
            Positioned(
              top: ((MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).size.height / 1.5)) /
                      2) -
                  ((MediaQuery.of(context).size.width / 3.8) / 2),
              left: (MediaQuery.of(context).size.width / 2) -
                  ((MediaQuery.of(context).size.width / 3.8) / 2),
              child: Container(
                height: MediaQuery.of(context).size.width / 3.8,
                width: MediaQuery.of(context).size.width / 3.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100.0)),
                child: Center(
                  child: Icon(
                    widget.type == "loanRepayment"
                        ? widget.status == "failed"
                            ? Icons.clear
                            : Icons.payments_outlined
                        : Icons.check_outlined,
                    size: 75,
                    color: widget.status == "failed"
                        ? Colors.red
                        : Color(0xff00C898),
                  ),
                ),
              ),
            ),
            widget.type == "loanRepayment"
                ? widget.status == "paid"
                    ? widget.extTime != 2
                        ? Positioned(
                            bottom: 32,
                            right: 32,
                            left: 32,
                            child: Row(
                              children: [
                                Spacer(),
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width -
                                          132) /
                                      2,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Color(0xffFE7977)),
                                    ),
                                    onPressed: () async {
                                      makePayment();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12, bottom: 12),
                                      child: Text(
                                        "Pay in Full",
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
                                Spacer(),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 32) /
                                          2,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Color(0xff00C898)),
                                    ),
                                    onPressed: () async {
                                      showModalBottomSheet<void>(
                                        isScrollControlled: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter mystate) {
                                            return ListView(
                                              children: [
                                                SizedBox(
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
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 24),
                                                            child: SizedBox(
                                                              height: 18,
                                                              child: ListView(
                                                                primary: false,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                shrinkWrap: true,
                                                                children: [
                                                                  Radio(
                                                                    value:
                                                                        amounts[0],
                                                                    activeColor: Color(
                                                                        0xffFE7977),
                                                                    groupValue:
                                                                        nowAmt,
                                                                    onChanged:
                                                                        (value) {
                                                                      mystate(() {
                                                                        nowAmt = value
                                                                            as double;
                                                                        calcAmt();
                                                                      });
                                                                    },
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      mystate(() {
                                                                        nowAmt =
                                                                            amounts[
                                                                                0];
                                                                        calcAmt();
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                      "₹${amounts[0].toStringAsFixed(2)}",
                                                                      style:
                                                                          GoogleFonts
                                                                              .cabin(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w600,
                                                                          color: Colors
                                                                              .black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Radio(
                                                                    value:
                                                                        amounts[1],
                                                                    activeColor: Color(
                                                                        0xffFE7977),
                                                                    groupValue:
                                                                        nowAmt,
                                                                    onChanged:
                                                                        (value) {
                                                                      mystate(() {
                                                                        nowAmt = value
                                                                            as double;
                                                                        calcAmt();
                                                                      });
                                                                    },
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      mystate(() {
                                                                        nowAmt =
                                                                            amounts[
                                                                                1];
                                                                        calcAmt();
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                      "₹${amounts[1].toStringAsFixed(2)}",
                                                                      style:
                                                                          GoogleFonts
                                                                              .cabin(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w600,
                                                                          color: Colors
                                                                              .black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Radio(
                                                                    value:
                                                                        amounts[2],
                                                                    activeColor: Color(
                                                                        0xffFE7977),
                                                                    groupValue:
                                                                        nowAmt,
                                                                    onChanged:
                                                                        (value) {
                                                                      mystate(() {
                                                                        nowAmt = value
                                                                            as double;
                                                                        calcAmt();
                                                                      });
                                                                    },
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      mystate(() {
                                                                        nowAmt =
                                                                            amounts[
                                                                                2];
                                                                        calcAmt();
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                      "₹${amounts[2].toStringAsFixed(2)}",
                                                                      style:
                                                                          GoogleFonts
                                                                              .cabin(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w600,
                                                                          color: Colors
                                                                              .black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          feeDistribution(
                                                              "Left Over Amount",
                                                              " ₹" +
                                                                  leftOver
                                                                      .toStringAsFixed(
                                                                          2)),
                                                          feeDistribution(
                                                              "Processing Fee",
                                                              "+ ₹" +
                                                                  processingFee
                                                                      .toStringAsFixed(
                                                                          2)),
                                                          feeDistribution(
                                                              "GST (18%)",
                                                              "+ ₹" +
                                                                  gst.toStringAsFixed(
                                                                      2)),
                                                          feeDistribution(
                                                              "Interest (1.5%)",
                                                              "+ ₹" +
                                                                  interest
                                                                      .toStringAsFixed(
                                                                          2)),
                                                          feeDistribution(
                                                              "Next EMI Amount",
                                                              "₹" +
                                                                  repAmt
                                                                      .toStringAsFixed(
                                                                          2)),
                                                          feeDistribution(
                                                            "EMI Date",
                                                            "After 30 days on " +
                                                                Jiffy(DateTime.now()
                                                                        .add(Duration(
                                                                            days:
                                                                                30)))
                                                                    .format(
                                                                        "d MMM yyyy"),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                48,
                                                            child: ElevatedButton(
                                                              style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all<Color>(
                                                                            Color(
                                                                                0xffFE7977)),
                                                              ),
                                                              onPressed: () {
                                                                payPartial();
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left: 64,
                                                                        right: 64,
                                                                        top: 12,
                                                                        bottom: 12),
                                                                child: Text(
                                                                  "Pay Loan",
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    textStyle:
                                                                        TextStyle(
                                                                      fontSize: 18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .white,
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
                                                ),
                                              ],
                                            );
                                          });
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12, bottom: 12),
                                      child: Text(
                                        "Pay Partial",
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
                                Spacer(),
                              ],
                            ),
                          )
                        : Positioned(
                            bottom: 32,
                            right: 64,
                            child: Center(
                              child: SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 128),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xff00C898)),
                                  ),
                                  onPressed: () {
                                    makeFullPayment();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, bottom: 12),
                                    child: Text(
                                      "Pay Full",
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
                            ),
                          )
                    : Positioned(
                        bottom: 32,
                        right: 64,
                        child: Center(
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width - 128),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color(0xffFE7977)),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                child: Text(
                                  "Back",
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
                        ),
                      )
                : Positioned(
                    bottom: 32,
                    right: 64,
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 128,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xffFE7977)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => BasicBottomNavBar()),
                                (Route<dynamic> route) => false);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 12),
                            child: Text(
                              "Go to Home",
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
                    ),
                  ),
          ],
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
