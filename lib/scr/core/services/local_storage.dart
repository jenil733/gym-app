import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save a string value
  Future<bool> saveString(String key, String value) async {
    await init();
    return _prefs!.setString(key, value);
  }

  /// Get a string value
  String? getString(String key, {String? defaultValue}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  /// Save an integer value
  Future<bool> saveInt(String key, int value) async {
    await init();
    return _prefs!.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key, {int? defaultValue}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  /// Save a boolean value
  Future<bool> saveBool(String key, bool value) async {
    await init();
    return _prefs!.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key, {bool? defaultValue}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// Save a double value
  Future<bool> saveDouble(String key, double value) async {
    await init();
    return _prefs!.setDouble(key, value);
  }

  /// Get a double value
  double? getDouble(String key, {double? defaultValue}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  /// Save a string list
  Future<bool> saveStringList(String key, List<String> value) async {
    await init();
    return _prefs!.setStringList(key, value);
  }

  /// Get a string list
  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  /// Remove a specific key
  Future<bool> remove(String key) async {
    await init();
    return _prefs!.remove(key);
  }

  /// Clear all stored values
  Future<bool> clear() async {
    await init();
    return _prefs!.clear();
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}
