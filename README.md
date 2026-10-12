# flutter_check_adjust

Adjust、cloak 和 install referrer 的组合判断插件。

## Android Headless 启动

正常 Activity 启动时保持默认配置：

```dart
FlutterCheckAdjust.instance.init(
  // 原有参数
);
```

如果 FlutterEngine 是由 Android Service 在没有 Activity 的情况下创建，传入：

```dart
FlutterCheckAdjust.instance.init(
  // 原有参数
  headlessStart: true,
  headlessLifecycleTimeout: const Duration(seconds: 15),
);
```

插件会补一次 Adjust 前台生命周期，使首次 session 和 attribution 请求能够启动。
归因、session 成功、session 失败或安全时间到达后，会自动结束模拟前台，但不会
销毁 Adjust、FlutterEngine 或 attribution 回调。

如果模拟前台期间用户真正打开 UI，在 UI 初始化最前面调用：

```dart
FlutterCheckAdjust.instance.switchToUiLifecycle();
```

该方法和 `finishHeadlessAdjustLifecycle()` 都是幂等的。不要在正常启动路径中
直接、无条件地调用 `Adjust.onResume()`。

