import 'dart:io';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:flutter_check_adjust/callback/request_callback.dart';
import 'package:flutter_check_adjust/flutter_check_adjust.dart';
import 'package:flutter_check_adjust/storage/storage_hep.dart';

class RequestReferrer{
  var _referrerRequestNum=0;
  RequestCallback requestCallback;
  RequestReferrer({
    required this.requestCallback,
});


  init()async{
    if(Platform.isIOS||_referrerRequestNum>=15){
      return;
    }
    var referrer = AfStorageHep.instance.getLocalReferrerStr();
    if(referrer.isNotEmpty){
      requestCallback.requestReferrerCallback.startRequestReferrer.call();
      requestCallback.requestReferrerCallback.requestSuccess.call(referrer);
      return;
    }
    try{
      if(_referrerRequestNum==0){
        requestCallback.requestReferrerCallback.startRequestReferrer.call();
      }
      var referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
      var referrerStr=referrerDetails.installReferrer??"";
      FlutterCheckAdjust.instance.log("check user---> request referrer result--->$referrerStr");
      if(referrerStr.isNotEmpty){
        requestCallback.requestReferrerCallback.requestSuccess.call(referrerStr);
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