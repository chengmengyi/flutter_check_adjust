import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event_success.dart';
import 'package:flutter_check_adjust/flutter_check_adjust.dart';
import 'package:flutter_check_adjust/request_adjust/request_adjust_callback.dart';
import 'package:flutter_check_adjust/storage/storage_hep.dart';

class RequestAdjust{
  String appToken;
  String distinctId;
  RequestAdjustCallback requestAdjustCallback;
  Function()? aPackageAfCall;

  bool afIsB=false;

  RequestAdjust({
    required this.appToken,
    required this.distinctId,
    required this.requestAdjustCallback,
  });

  init()async{
    Adjust.addGlobalCallbackParameter("customer_user_id", distinctId);
    var adjustConfig = AdjustConfig(appToken, AdjustEnvironment.production);
    adjustConfig.attributionCallback=(AdjustAttribution attributionChangedData) {
      var network = attributionChangedData.network??"";
      FlutterCheckAdjust.instance.log("check user---> request adjust result--->network:$network");
      var isB = network.isNotEmpty&&!network.contains("Organic");
      if(isB&&AfStorageHep.instance.getAfResult().isEmpty){
        AfStorageHep.instance.saveAfResult(network);
        requestAdjustCallback.firstRequestAdjustB.call();
      }
      requestAdjustCallback.requestSuccess.call(isB);
    };
    adjustConfig.eventSuccessCallback= (AdjustEventSuccess eventSuccessData) {
      // checkListener?.adjustEventCall(eventSuccessData);
    };
    requestAdjustCallback.startRequestAdjust.call();
    FlutterCheckAdjust.instance.log("check user---> start request adjust");
    Adjust.initSdk(adjustConfig);
  }

  uploadAdRevenue(String networkName,double revenue,String adId){
    var adjustAdRevenue = AdjustAdRevenue("applovin_max_sdk");
    adjustAdRevenue.setRevenue(revenue, "USD");
    adjustAdRevenue.adRevenueNetwork=networkName;
    adjustAdRevenue.adRevenueUnit=adId;
    Adjust.trackAdRevenue(adjustAdRevenue);
  }
}