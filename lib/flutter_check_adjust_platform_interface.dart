import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_check_adjust_method_channel.dart';

abstract class FlutterCheckAdjustPlatform extends PlatformInterface {
  /// Constructs a FlutterCheckAdjustPlatform.
  FlutterCheckAdjustPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterCheckAdjustPlatform _instance = MethodChannelFlutterCheckAdjust();

  /// The default instance of [FlutterCheckAdjustPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterCheckAdjust].
  static FlutterCheckAdjustPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterCheckAdjustPlatform] when
  /// they register themselves.
  static set instance(FlutterCheckAdjustPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
