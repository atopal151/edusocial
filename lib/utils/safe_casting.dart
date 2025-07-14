import 'package:flutter/foundation.dart';

class SafeCast {
  /// 🔒 Güvenli int casting
  static int? toInt(dynamic value) {
    if (value == null) return null;
    
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    
    debugPrint('⚠️ SafeCast.toInt failed for value: $value (${value.runtimeType})');
    return null;
  }

  /// 🔒 Güvenli int casting (default değer ile)
  static int toIntWithDefault(dynamic value, int defaultValue) {
    return toInt(value) ?? defaultValue;
  }

  /// 🔒 Güvenli double casting
  static double? toDouble(dynamic value) {
    if (value == null) return null;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    
    debugPrint('⚠️ SafeCast.toDouble failed for value: $value (${value.runtimeType})');
    return null;
  }

  /// 🔒 Güvenli double casting (default değer ile)
  static double toDoubleWithDefault(dynamic value, double defaultValue) {
    return toDouble(value) ?? defaultValue;
  }

  /// 🔒 Güvenli string casting
  static String? toStringValue(dynamic value) {
    if (value == null) return null;
    
    if (value is String) return value;
    
    try {
      return value.toString();
    } catch (e) {
      debugPrint('⚠️ SafeCast.toStringValue failed for value: $value (${value.runtimeType})');
      return null;
    }
  }

  /// 🔒 Güvenli string casting (default değer ile)
  static String toStringWithDefault(dynamic value, String defaultValue) {
    final result = toStringValue(value);
    return (result == null || result.trim().isEmpty) ? defaultValue : result;
  }

  /// 🔒 Güvenli bool casting
  static bool? toBool(dynamic value) {
    if (value == null) return null;
    
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    
    debugPrint('⚠️ SafeCast.toBool failed for value: $value (${value.runtimeType})');
    return null;
  }

  /// 🔒 Güvenli bool casting (default değer ile)
  static bool toBoolWithDefault(dynamic value, bool defaultValue) {
    return toBool(value) ?? defaultValue;
  }

  /// 🔒 Güvenli List casting
  static List<T>? toList<T>(dynamic value) {
    if (value == null) return null;
    
    if (value is List<T>) return value;
    if (value is List) {
      try {
        return value.cast<T>();
      } catch (e) {
        debugPrint('⚠️ SafeCast.toList cast failed: $e');
        return null;
      }
    }
    
    debugPrint('⚠️ SafeCast.toList failed for value: $value (${value.runtimeType})');
    return null;
  }

  /// 🔒 Güvenli List casting (default değer ile)
  static List<T> toListWithDefault<T>(dynamic value, List<T> defaultValue) {
    return toList<T>(value) ?? defaultValue;
  }

  /// 🔒 Güvenli Map casting
  static Map<String, dynamic>? toMap(dynamic value) {
    if (value == null) return null;
    
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        debugPrint('⚠️ SafeCast.toMap cast failed: $e');
        return null;
      }
    }
    
    debugPrint('⚠️ SafeCast.toMap failed for value: $value (${value.runtimeType})');
    return null;
  }

  /// 🔒 Güvenli Map casting (default değer ile)
  static Map<String, dynamic> toMapWithDefault(dynamic value, Map<String, dynamic> defaultValue) {
    return toMap(value) ?? defaultValue;
  }

  /// 🔒 Güvenli DateTime parsing
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        debugPrint('⚠️ SafeCast.toDateTime failed for timestamp: $value');
        return null;
      }
    }
    
    debugPrint('⚠️ SafeCast.toDateTime failed for value: $value (${value.runtimeType})');
    return null;
  }

  /// 🔒 Arguments'dan güvenli değer alma
  static T? getFromArguments<T>(Map<String, dynamic>? arguments, String key) {
    if (arguments == null || !arguments.containsKey(key)) {
      debugPrint('⚠️ SafeCast.getFromArguments: Key "$key" not found in arguments');
      return null;
    }
    
    final value = arguments[key];
    if (value is T) return value;
    
    debugPrint('⚠️ SafeCast.getFromArguments: Expected $T but got ${value.runtimeType} for key "$key"');
    return null;
  }

  /// 🔒 Arguments'dan güvenli değer alma (default değer ile)
  static T getFromArgumentsWithDefault<T>(Map<String, dynamic>? arguments, String key, T defaultValue) {
    return getFromArguments<T>(arguments, key) ?? defaultValue;
  }
} 