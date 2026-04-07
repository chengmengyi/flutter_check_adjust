import 'dart:io';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:flutter_check_adjust/flutter_check_adjust.dart';
import 'package:flutter_check_adjust/storage/storage_hep.dart';

class RequestReferrer{
  var _referrerRequestNum=0;

  init()async{
    if(Platform.isIOS||_referrerRequestNum>=15){
      return;
    }
    var referrer = AfStorageHep.instance.getLocalReferrerStr();
    if(referrer.isNotEmpty){
      return;
    }
    try{
      var referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
      var referrerStr=referrerDetails.installReferrer??"";
      FlutterCheckAdjust.instance.log("check user---> request referrer result--->$referrerStr");
      if(referrerStr.isNotEmpty){
        AfStorageHep.instance.saveLocalReferrerStr(referrerStr);
      }else{
        _referrerRequestNum++;
        init();
      }
    }catch(e){
      _referrerRequestNum++;
      init();
    }
  }
}