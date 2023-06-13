import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore_for_file: prefer_const_constructors

class WaitlistNotifier extends StatefulWidget {
  const WaitlistNotifier({Key? key, this.Name}) : super(key: key);
  final Name;

  @override
  State<WaitlistNotifier> createState() => _WaitlistNotifierState();
}

class _WaitlistNotifierState extends State<WaitlistNotifier> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          width: 32 * 3.00293255,
          height: 32,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/logo_png.png')),
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 32,
                ),
                Text(
                  'Hi ${widget.Name.split(' ')[0]},',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'We are sorry but we could not approve your application currently.'
                  '\n\nYou can re-apply after 90 days.\n',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'Possible reasons for not getting approved\n',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
                bulletPoints(
                    "• Multiple loan enquiries and loan commitments.\n"),
                bulletPoints("• KYC video was missing or not as instructed.\n"),
                bulletPoints("• Poor credit score or credit history.\n"),
                bulletPoints(
                    "• 18 - 28 years old students or professionals can avail our service, may be you don’t fall in that age group.\n"),
                bulletPoints(
                    "• Inaccurate details entered in the application.\n"),
                SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width) / 1.8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24)),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                                ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xffFE7177)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(
                            "Got It",
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  bulletPoints(text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black.withOpacity(0.8),
        ),
      ),
    );
  }
}
