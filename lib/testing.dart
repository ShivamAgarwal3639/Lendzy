import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyHomePage1 extends StatefulWidget {
  const MyHomePage1({Key? key,}) : super(key: key);
  @override
  _MyHomePage1State createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  late NativeAd _adSmall;
  late NativeAd _adMedium;
  bool _isAdLoaded = false;
  bool _isAdLoadedMedium = false;

  @override
  void initState() {
    super.initState();

    _adSmall = NativeAd(
      // Here in adUnitId: add your own ad unit ID before release build

      adUnitId: NativeAd.testAdUnitId,
      factoryId: 'listTileSmall',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _adSmall.load();

    _adMedium = NativeAd(
      // Here in adUnitId: add your own ad unit ID before release build


      adUnitId: NativeAd.testAdUnitId,
      factoryId: 'listTileMedium',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoadedMedium = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _adMedium.load();
  }

  @override
  void dispose() {
    _adSmall.dispose();
    _adMedium.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
            children: [
//  small native ad template widget
              _isAdLoaded
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: AdWidget(ad: _adSmall),
                  height: 150,
                  width: 400,
                ),
              )
                  : const SizedBox.shrink(),
//  medium native ad template widget
              _isAdLoadedMedium
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: AdWidget(ad: _adMedium),
                  height: 380,
                  width: 400,
                ),
              )
                  : const SizedBox.shrink(),
            ],
          )),
    );
  }
}