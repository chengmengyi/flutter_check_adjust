import 'dart:async';
import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event_success.dart';
import 'package:flutter_check_adjust/callback/request_callback.dart';
import 'package:flutter_check_adjust/flutter_check_adjust.dart';
import 'package:flutter_check_adjust/storage/storage_hep.dart';

class RequestAdjust {
  RequestAdjust({
    required this.appToken,
    required this.distinctId,
    required this.requestCallback,
    required this.headlessStart,
    required this.headlessLifecycleTimeout,
  });

  final String appToken;
  final String distinctId;
  final RequestCallback requestCallback;
  final bool headlessStart;
  final Duration headlessLifecycleTimeout;

  Timer? _headlessLifecycleTimer;
  bool _headlessLifecycleResumed = false;

  void init() {
    Adjust.addGlobalCallbackParameter('customer_user_id', distinctId);
    final AdjustConfig adjustConfig = AdjustConfig(
      appToken,
      AdjustEnvironment.production,
    );
    adjustConfig
        .attributionCallback = (AdjustAttribution attributionChangedData) {
      final String network = attributionChangedData.network ?? '';
      FlutterCheckAdjust.instance.log(
        'check user---> request adjust result--->network:$network',
      );
      final bool isB = network.isNotEmpty && !network.contains('Organic');
      if (isB && AfStorageHep.instance.getAfResult().isEmpty) {
        AfStorageHep.instance.saveAfResult(network);
        requestCallback.requestAdjustCallback.firstRequestAdjustB.call();
      }
      requestCallback.requestAdjustCallback.requestSuccess.call(isB, network);
      finishHeadlessLifecycle(reason: 'attribution callback');
    };
    adjustConfig.eventSuccessCallback = (AdjustEventSuccess eventSuccessData) {
      // checkListener?.adjustEventCall(eventSuccessData);
    };
    requestCallback.requestAdjustCallback.startRequestAdjust.call();
    FlutterCheckAdjust.instance.log('check user---> start request adjust');
    Adjust.initSdk(adjustConfig);

    if (!headlessStart || !Platform.isAndroid) {
      return;
    }

    _headlessLifecycleResumed = true;
    // Adjust exposes these methods for lifecycle integration. Headless Android
    // startup has no Activity, so no automatic resume callback is generated.
    // ignore: invalid_use_of_visible_for_testing_member
    Adjust.onResume();
    FlutterCheckAdjust.instance.log(
      'check user---> start headless adjust lifecycle',
    );
    _headlessLifecycleTimer = Timer(
      headlessLifecycleTimeout,
      () => finishHeadlessLifecycle(reason: 'safety timeout'),
    );
  }

  void finishHeadlessLifecycle({String reason = 'host request'}) {
    if (!_headlessLifecycleResumed) {
      return;
    }
    _headlessLifecycleResumed = false;
    _headlessLifecycleTimer?.cancel();
    _headlessLifecycleTimer = null;
    // ignore: invalid_use_of_visible_for_testing_member
    Adjust.onPause();
    FlutterCheckAdjust.instance.log(
      'check user---> finish headless adjust lifecycle--->$reason',
    );
  }

  void switchToUiLifecycle() {
    if (!_headlessLifecycleResumed) {
      return;
    }
    _headlessLifecycleResumed = false;
    _headlessLifecycleTimer?.cancel();
    _headlessLifecycleTimer = null;

    // Close the synthetic foreground interval, then make the final Adjust
    // state match the Activity that is now visible. Subsequent lifecycle
    // changes continue to be handled by Adjust's Android integration.
    // ignore: invalid_use_of_visible_for_testing_member
    Adjust.onPause();
    // ignore: invalid_use_of_visible_for_testing_member
    Adjust.onResume();
    FlutterCheckAdjust.instance.log(
      'check user---> switch headless adjust lifecycle to ui',
    );
  }

  void uploadAdRevenue(String networkName, double revenue, String adId) {
    final AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('applovin_max_sdk');
    adjustAdRevenue.setRevenue(revenue, 'USD');
    adjustAdRevenue.adRevenueNetwork = networkName;
    adjustAdRevenue.adRevenueUnit = adId;
    Adjust.trackAdRevenue(adjustAdRevenue);
  }
}
