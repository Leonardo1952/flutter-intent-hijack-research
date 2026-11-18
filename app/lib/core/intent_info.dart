import 'package:flutter/services.dart';

class IntentInfo {
  IntentInfo(this.raw);

  final Map<String, dynamic> raw;

  static const _channel = MethodChannel('banconow/intent');

  static Future<IntentInfo> load() async {
    try {
      final data = await _channel.invokeMapMethod<String, dynamic>('describe');
      return IntentInfo(data ?? const {});
    } on MissingPluginException {
      return IntentInfo(const {'activity': 'unknown (no channel)'});
    }
  }

  String get activity => '${raw['activity']}';
  String? get action => raw['action'] as String?;
  String? get data => raw['data'] as String?;
  Map<String, dynamic> get extras =>
      Map<String, dynamic>.from((raw['extras'] as Map?) ?? const {});
  String? get callingPackage => raw['callingPackage'] as String?;
  String? get ownPackage => raw['ownPackage'] as String?;
}
