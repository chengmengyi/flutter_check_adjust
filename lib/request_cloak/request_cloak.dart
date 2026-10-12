import 'package:flutter_check_adjust/callback/request_callback.dart';
import 'package:flutter_check_adjust/dio/dio_hep.dart';
import 'package:flutter_check_adjust/flutter_check_adjust.dart';

class RequestCloak{
  String url;
  Map<String,dynamic> data;
  String whiteKey;
  RequestCallback requestCallback;

  var _firstRequest=true,clockIsWhite=false;
  Function()? aPackageCall;

  RequestCloak({
    required this.url,
    required this.data,
    required this.whiteKey,
    required this.requestCallback,
  });

  init()async{
    if(_firstRequest){
      requestCallback.requestCloakCallback.startRequestCloak.call();
      _firstRequest=false;
    }
    FlutterCheckAdjust.instance.log("check user---> start request cloak--->url:$url---->data:$data");
    var dioResult = await DioHep.instance.requestPost(path: url, data: data);
    FlutterCheckAdjust.instance.log("check user---> request cloak result--->result:${dioResult.success}---->msg:${dioResult.msg}");
    if(dioResult.success){
      clockIsWhite=dioResult.msg==whiteKey;
      requestCallback.requestCloakCallback.requestSuccess.call(clockIsWhite);
      aPackageCall?.call();
    }else{
      await Future.delayed(const Duration(milliseconds: 1000));
      init();
    }
  }

  setAPackageCloakCall(Function() call){
    aPackageCall=call;
  }
}
