// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ReferralHistory extends StatefulWidget {
  const ReferralHistory({Key? key}) : super(key: key);

  @override
  State<ReferralHistory> createState() => _ReferralHistoryState();
}

class _ReferralHistoryState extends State<ReferralHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          "Reward History",
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 36,
          ),
          listItem("You used invite code of 79XXXXXX56",50,true),
          listItem("79XXXXXX56 used your invite code.",75,true),
          listItem("You withdrew from your wallet.",75,false),
        ],
      ),
    );
  }

  listItem(txt,reward,icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16,),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(icon?Icons.call_received:Icons.call_made,size: 28,),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        icon?"Received":"Withdraw",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        txt,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    icon?"+ ₹ $reward.0":"- ₹ $reward.0",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: icon?Colors.greenAccent:Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 16,
            thickness: 1.5,
          ),
        ],
      ),
    );
  }
}
