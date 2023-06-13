// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'package:Lendzy/referal_history.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({Key? key, this.number}) : super(key: key);
  final number;

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changeNumber();
  }
  var numStr = "";
  changeNumber() {
    var num = widget.number;
    var n1 = num.replaceAll("0", "E");
    var n2 = n1.replaceAll("1", "Y");
    var n3 = n2.replaceAll("2", "R");
    var n4 = n3.replaceAll("3", "Q");
    var n5 = n4.replaceAll("4", "N");
    var n6 = n5.replaceAll("5", "A");
    var n7 = n6.replaceAll("6", "X");
    var n8 = n7.replaceAll("7", "F");
    var n9 = n8.replaceAll("8", "L");
    var n10 = n9.replaceAll("9", "S");

    setState(() {
      numStr = n10;
    });
  }

  openWhatsapp() async {
    var txt = 'Hi! I am inviting you to one of the Best Loan App of India. '
        'Download Lendzy and paste the given code while registering to get '
        'upto ₹50 when you take your first loan.\n\nCode : $numStr\n\n'
        'https://play.google.com/store/apps/details?id=in.lendzy.lendzy';
    var url = "whatsapp://send?text=$txt";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("whatsapp no installed")));
    }
  }

  openShare() async {
    var txt = 'Hi! I am inviting you to one of the Best Loan App of India. '
        'Download Lendzy and paste the given code while registering to get '
        'upto ₹50 when you take your first loan.\n\nCode : $numStr\n\n'
        'https://play.google.com/store/apps/details?id=in.lendzy.lendzy';

    Share.share(txt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
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
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.25,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 32),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ReferralHistory()),
                                );
                              },
                              icon: Icon(
                                Icons.filter_list,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Reward Earned",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "₹ 1000",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              height: 88,
                              width: 88,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/open-box.png"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Row(
                          children: [
                            Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width / 8.5),
                                width: (MediaQuery.of(context).size.width / 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    "Withdraw",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cabin(
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "UPI ID:",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  "675687887@ybl",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  // height: 200,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        topLeft: Radius.circular(24),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Spacer(
                          flex: 1,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Referral",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(
                          flex: 2,
                        ),
                        Row(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.width / 6.5,
                              width: MediaQuery.of(context).size.width / 6.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(600),
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
                                  "1",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 92) -
                                  (MediaQuery.of(context).size.width / 6.5),
                              child: Text(
                                "Invite your friends using Referral code",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(
                          flex: 2,
                        ),
                        Row(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.width / 6.5,
                              width: MediaQuery.of(context).size.width / 6.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(600),
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
                                  "2",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 92) -
                                  (MediaQuery.of(context).size.width / 6.5),
                              child: Text(
                                "When they complete KYC and take a loan.",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 6,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80),
                                  color: Color(0xffFCE3E3)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Text(
                                  "You get upto ₹75",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 6,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80),
                                  color: Color(0xffFCE3E3)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Text(
                                  "They get upto ₹50",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(
                          flex: 2,
                        ),
                        Row(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.width / 6.5,
                              width: MediaQuery.of(context).size.width / 6.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(600),
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
                                  "3",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            SizedBox(
                              width: (MediaQuery.of(context).size.width - 92) -
                                  (MediaQuery.of(context).size.width / 6.5),
                              child: Text(
                                "Every time your friend earn, you get paid too.",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(
                          flex: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  style: BorderStyle.solid,
                                  color: Colors.black12,
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Text(
                                    "Invite Code : $numStr",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        height: 1,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: numStr));
                                      const snackBar = SnackBar(
                                        content: Text(
                                          "Invite Code has been copied",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Spacer(
                          flex: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(6),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xff1FB69F)),
                                ),
                                onPressed: () {
                                  openWhatsapp();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/whatsapp.png")),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        "Via Whatsapp",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              // width: 50,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(6),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                ),
                                onPressed: () {
                                  openShare();
                                },
                                child: Center(
                                    child: Icon(Icons.share,
                                        color: Colors.black54)),
                              ),
                            ),
                          ],
                        ),
                        Spacer(
                          flex: 2,
                        )
                      ],
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
}
