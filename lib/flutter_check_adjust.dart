import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_check_adjust/request_adjust/request_adjust.dart';
import 'package:flutter_check_adjust/request_adjust/request_adjust_callback.dart';
import 'package:flutter_check_adjust/request_cloak/request_cloak.dart';
import 'package:flutter_check_adjust/request_cloak/request_cloak_callback.dart';
import 'package:flutter_check_adjust/request_referrer/request_referrer.dart';
import 'package:flutter_check_adjust/storage/storage_hep.dart';

class FlutterCheckAdjust {
  static final FlutterCheckAdjust _adjust=FlutterCheckAdjust();
  static FlutterCheckAdjust get instance => _adjust;

  RequestAdjust? _requestAdjust;
  RequestCloak? _requestCloak;
  final List<String> _referrerConfList=[];

  init({
    required String adjustAppToken,
    required String distinctId,
    required String clockUrl,
    required String cloakWhiteKey,
    required Map<String,dynamic> cloakData,
    required List<String> referrerConfList,
    required RequestAdjustCallback requestAdjustCallback,
    required RequestCloakCallback requestCloakCallback,
  }){
    _referrerConfList.clear();
    _referrerConfList.addAll(referrerConfList);
    _requestAdjust=RequestAdjust(appToken: adjustAppToken, distinctId: distinctId, requestAdjustCallback: requestAdjustCallback);
    _requestCloak=RequestCloak(url: clockUrl, data: cloakData, whiteKey: cloakWhiteKey, requestCloakCallback: requestCloakCallback);
    _requestAdjust?.init();
    _requestCloak?.init();
    if(_referrerConfList.isNotEmpty){
      RequestReferrer().init();
    }
  }

  bool checkUser(){
    if(AfStorageHep.instance.getLocalIsB()){
      log("check user---> checkUser --->local is b");
      return true;
    }
    if(_requestCloak?.clockIsWhite!=true){
      log("check user---> checkUser --->cloak is black");
      return false;
    }
    if(Platform.isIOS){
      if(AfStorageHep.instance.getAfResult().isEmpty){
        log("check user---> checkUser --->adjust not buy user");
        return false;
      }
    }else{
      var referrerBuyUser=false;
      if(_referrerConfList.isNotEmpty){
        referrerBuyUser = _checkReferrerBuyUser();
      }
      var adjustBuyUser = AfStorageHep.instance.getAfResult().isNotEmpty;
      log("check user---> checkUser --->referrerBuyUser:$referrerBuyUser--->adjustBuyUser:$adjustBuyUser");
      if(!referrerBuyUser&&!adjustBuyUser){
        return false;
      }
    }
    AfStorageHep.instance.saveUser(true);
    log("check user---> checkUser ---> is b");
    return true;

  }

  bool _checkReferrerBuyUser(){
    var referrerStr = AfStorageHep.instance.getLocalReferrerStr();
    if(_referrerConfList.isEmpty){
      return referrerStr.contains("adjust");
    }
    return _referrerConfList.indexWhere((element) => referrerStr.contains(element))>=0;
  }

  uploadAdRevenueToAdjust(String networkName,double revenue,String adId){
    _requestAdjust?.uploadAdRevenue(networkName, revenue, adId);
  }

  logEvent({
    required String eventName,
    Map? eventValues,
  }){
    // _requestAf?.logEvent(eventName: eventName,eventValues: eventValues);
  }

  log(String s){
    if(kDebugMode){
      print(s);
    }
  }
}
