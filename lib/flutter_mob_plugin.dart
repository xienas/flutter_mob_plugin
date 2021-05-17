import 'dart:async';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> event);
class FlutterMobPlugin {
  static final MethodChannel _channel =
  const MethodChannel('xns/flutter_SVSDK_plugin');

  /// Handler of login auth
  EventHandler _loginAuthHandler;

  /// Handler of login auth
  EventHandler _loginAuthFailHandler;

  /// Handler of login success
  EventHandler _loginSuccessHandler;

  /// Handler of login fail
  EventHandler _loginFailHandler;

  /// Handler of login cancel
  EventHandler _loginCancelHandler;

  /// Handler of changes verify Enable
  EventHandler _verifyHandler;

  /// Handler of changes operator type
  EventHandler _operatorTypeHandler;

  Future<int> _invokeMethod({
    String method,
    Map<String, dynamic> arguments,
  }) {
    arguments ??= const {};
    return _channel.invokeMethod(method, arguments);
  }

  /// getStatus
  Future<void> getStatus({
    bool status = false,
  }) async {
    status ??= false;
    await _invokeMethod(
      method: 'getStatus',
      arguments: {
        'status': status,
      },
    );
  }

  /// preLogin
  Future<void> preLogin() async {
    await _invokeMethod(
      method: 'preLogin',
    );
  }

  /// preLogin
  Future<void> loginAuth() async {
    await _invokeMethod(
      method: 'loginAuth',
    );
  }

  /// isVerifyEnable
  Future<void> getIsVerifyEnable() {
    return _invokeMethod(method: 'isVerifyEnable');
  }

  /// cleanPhoneScripCache
  Future<void> cleanPhoneScripCache() async {
    await _invokeMethod(method: 'cleanPhoneScripCache');
  }

  /// isVerifyEnable
  Future<void> getCurrentOperatorType() {
    return _invokeMethod(method: 'getCurrentOperatorType');
  }

  void addEventHandler({
    EventHandler loginAuthHandler,
    EventHandler loginAuthFailHandler,
    EventHandler loginSuccessHandler,
    EventHandler loginFailHandler,
    EventHandler loginCancelHandler,
    EventHandler verifyHandler,
    EventHandler operatorTypeHandler,
  }) {
    _loginAuthHandler = loginAuthHandler;
    _loginAuthFailHandler = loginAuthFailHandler;
    _loginSuccessHandler = loginSuccessHandler;
    _loginFailHandler = loginFailHandler;
    _loginCancelHandler = loginCancelHandler;
    _verifyHandler = verifyHandler;
    _operatorTypeHandler = operatorTypeHandler;
    _channel.setMethodCallHandler(_doHandlePlatformCall);
  }

  Future<Null> _doHandlePlatformCall(MethodCall call) async {
    final Map<dynamic, dynamic> callArgs = call.arguments as Map;
    _log('_platformCallHandler call ${call.method} $callArgs');
    switch (call.method) {
      case 'login.auth':
        return _loginAuthHandler(callArgs);
        break;
      case 'login.authFail':
        return _loginAuthFailHandler(callArgs);
        break;
      case 'login.success':
        return _loginSuccessHandler(callArgs);
        break;
      case 'login.fail':
        return _loginFailHandler(callArgs);
        break;
      case 'login.cancel':
        return _loginCancelHandler(callArgs);
        break;
      case 'login.privacyPermissionStatus':
        return _verifyHandler(callArgs);
        break;
      case 'login.preLoginResult':
        return _operatorTypeHandler(callArgs);
        break;
      default:
        _log('Unknown method ${call.method} ');
    }
  }

  static void _log(String param) {
    print(param);
  }
}
