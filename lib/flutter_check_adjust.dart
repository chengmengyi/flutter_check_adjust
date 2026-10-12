import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_check_adjust/callback/request_callback.dart';
import 'package:flutter_check_adjust/request_adjust/request_adjust.dart';
import 'package:flutter_check_adjust/request_cloak/request_cloak.dart';
import 'package:flutter_check_adjust/request_referrer/request_referrer.dart';
import 'package:flutter_check_adjust/storage/storage_hep.dart';

class FlutterCheckAdjust {
  static final FlutterCheckAdjust _adjust = FlutterCheckAdjust();
  static FlutterCheckAdjust get instance => _adjust;

  RequestAdjust? _requestAdjust;
  RequestCloak? _requestCloak;
  final List<String> _referrerConfList = [];
  bool _referrerAlwaysB = false;

  void init({
    required String adjustAppToken,
    required String distinctId,
    required String clockUrl,
    required String cloakWhiteKey,
    required Map<String, dynamic> cloakData,
    required RequestCallback requestCallback,
    bool headlessStart = false,
    Duration headlessLifecycleTimeout = const Duration(seconds: 15),
  }) {
    _requestAdjust = RequestAdjust(
      appToken: adjustAppToken,
      distinctId: distinctId,
      requestCallback: requestCallback,
      headlessStart: headlessStart,
      headlessLifecycleTimeout: headlessLifecycleTimeout,
    );
    _requestCloak = RequestCloak(
      url: clockUrl,
      data: cloakData,
      whiteKey: cloakWhiteKey,
      requestCallback: requestCallback,
    );
    _requestAdjust?.init();
    _requestCloak?.init();
    RequestReferrer(requestCallback: requestCallback).init();
  }

  /// Ends a synthetic Adjust foreground interval started for headless Android.
  ///
  /// This is idempotent. It does not destroy Adjust, the FlutterEngine, or any
  /// registered attribution callback.
  void finishHeadlessAdjustLifecycle() {
    _requestAdjust?.finishHeadlessLifecycle();
  }

  /// Hands a still-active synthetic lifecycle over to a visible Activity.
  ///
  /// Call this at the beginning of UI initialization. Normal, non-headless
  /// startup and already-finished headless intervals are no-ops.
  void switchToUiLifecycle() {
    _requestAdjust?.switchToUiLifecycle();
  }

  bool checkUser() {
    if (AfStorageHep.instance.getLocalIsB()) {
      log("check user---> checkUser --->local is b");
      return true;
    }
    if (_requestCloak?.clockIsWhite != true) {
      log("check user---> checkUser --->cloak is black");
      return false;
    }
    if (Platform.isIOS) {
      if (AfStorageHep.instance.getAfResult().isEmpty) {
        log("check user---> checkUser --->adjust not buy user");
        return false;
      }
    } else {
      var referrerBuyUser = false;
      if (_referrerAlwaysB) {
        referrerBuyUser = true;
      } else {
        if (_referrerConfList.isNotEmpty) {
          referrerBuyUser = _checkReferrerBuyUser();
        }
      }
      var adjustBuyUser = AfStorageHep.instance.getAfResult().isNotEmpty;
      log(
        "check user---> checkUser --->referrerBuyUser:$referrerBuyUser--->adjustBuyUser:$adjustBuyUser",
      );
      if (!referrerBuyUser && !adjustBuyUser) {
        return false;
      }
    }
    AfStorageHep.instance.saveUser(true);
    log("check user---> checkUser ---> is b");
    return true;
  }

  bool _checkReferrerBuyUser() {
    var referrerStr = AfStorageHep.instance.getLocalReferrerStr();
    if (_referrerConfList.isEmpty) {
      return referrerStr.contains("adjust");
    }
    return _referrerConfList.indexWhere(
          (element) => referrerStr.contains(element),
        ) >=
        0;
  }

  uploadAdRevenueToAdjust(String networkName, double revenue, String adId) {
    _requestAdjust?.uploadAdRevenue(networkName, revenue, adId);
  }

  updateReferrerList(bool referrerAlwaysB, List<String> list) {
    _referrerConfList.clear();
    _referrerConfList.addAll(list);
    _referrerAlwaysB = referrerAlwaysB;
    log(
      "check user---> updateReferrerList ---> $list--->referrerAlwaysB:$referrerAlwaysB",
    );
  }

  // logEvent({
  //   required String eventName,
  //   Map? eventValues,
  // }){
  //   _requestAf?.logEvent(eventName: eventName,eventValues: eventValues);
  // }

  log(String s) {
    if (kDebugMode) {
      print(s);
    }
  }
}
