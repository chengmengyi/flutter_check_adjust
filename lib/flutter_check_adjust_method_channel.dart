import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_check_adjust_platform_interface.dart';

/// An implementation of [FlutterCheckAdjustPlatform] that uses method channels.
class MethodChannelFlutterCheckAdjust extends FlutterCheckAdjustPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_check_adjust');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
