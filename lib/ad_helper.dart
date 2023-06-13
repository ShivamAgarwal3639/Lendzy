import 'dart:io';

import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // if(kDebugMode) {
      //   return 'ca-app-pub-3940256099942544/6300978111';
      // }else {
           return 'ca-app-pub-5564820319667760/2212513021';
      // }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
