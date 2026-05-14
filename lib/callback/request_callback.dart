import 'package:flutter_check_adjust/request_adjust/request_adjust_callback.dart';
import 'package:flutter_check_adjust/request_cloak/request_cloak_callback.dart';
import 'package:flutter_check_adjust/request_referrer/request_referrer_callback.dart';

class RequestCallback{
  RequestAdjustCallback requestAdjustCallback;
  RequestCloakCallback requestCloakCallback;
  RequestReferrerCallback requestReferrerCallback;
  RequestCallback({
    required this.requestAdjustCallback,
    required this.requestCloakCallback,
    required this.requestReferrerCallback,
});
}