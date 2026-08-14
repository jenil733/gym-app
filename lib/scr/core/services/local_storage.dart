import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;
  final Map<String, Object> _runtimeValues = <String, Object>{};

  static const Set<String> persistentKeys = <String>{
    'auth_token',
    'fcm_token',
    'fcm_account_phone',
    'device_installation_id',
    'initial_profile_setup_prompt_shown',
    'weight_graph_samples_v1',
    'weight_goal_v1',
  };
  static const List<String> persistentKeyPrefixes = <String>[
    'step_tracking_',
    'weight_goal_v1_',
  ];

  Future<void> init() async {
    // Refresh the handle so hot restarts and preference-cache resets cannot
    // leave this singleton pointing at an obsolete preferences instance.
    _prefs = await SharedPreferences.getInstance();
    await _removeLegacyPersistentValues();
  }

  Future<void> _removeLegacyPersistentValues() async {
    final preferences = _prefs!;
    final legacyKeys = preferences
        .getKeys()
        .where((key) => !_isPersistent(key))
        .toList(growable: false);

    for (final key in legacyKeys) {
      final value = preferences.get(key);
      if (value != null) {
        _runtimeValues.putIfAbsent(key, () => value);
      }
      await preferences.remove(key);
    }
  }

  bool _isPersistent(String key) =>
      persistentKeys.contains(key) || persistentKeyPrefixes.any(key.startsWith);

  T? _read<T>(String key) {
    if (_isPersistent(key)) {
      return _prefs?.get(key) as T?;
    }
    return _runtimeValues[key] as T?;
  }

  /// Save a string value
  Future<bool> saveString(String key, String value) async {
    await init();
    if (_isPersistent(key)) {
      return _prefs!.setString(key, value);
    }
    _runtimeValues[key] = value;
    return true;
  }

  /// Get a string value
  String? getString(String key, {String? defaultValue}) {
    return _read<String>(key) ?? defaultValue;
  }

  /// Save an integer value
  Future<bool> saveInt(String key, int value) async {
    await init();
    if (_isPersistent(key)) {
      return _prefs!.setInt(key, value);
    }
    _runtimeValues[key] = value;
    return true;
  }

  /// Get an integer value
  int? getInt(String key, {int? defaultValue}) {
    return _read<int>(key) ?? defaultValue;
  }

  /// Save a boolean value
  Future<bool> saveBool(String key, bool value) async {
    await init();
    if (_isPersistent(key)) {
      return _prefs!.setBool(key, value);
    }
    _runtimeValues[key] = value;
    return true;
  }

  /// Get a boolean value
  bool? getBool(String key, {bool? defaultValue}) {
    return _read<bool>(key) ?? defaultValue;
  }

  /// Save a double value
  Future<bool> saveDouble(String key, double value) async {
    await init();
    if (_isPersistent(key)) {
      return _prefs!.setDouble(key, value);
    }
    _runtimeValues[key] = value;
    return true;
  }

  /// Get a double value
  double? getDouble(String key, {double? defaultValue}) {
    return _read<double>(key) ?? defaultValue;
  }

  /// Save a string list
  Future<bool> saveStringList(String key, List<String> value) async {
    await init();
    if (_isPersistent(key)) {
      return _prefs!.setStringList(key, value);
    }
    _runtimeValues[key] = List<String>.unmodifiable(value);
    return true;
  }

  /// Get a string list
  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _read<List<String>>(key) ?? defaultValue;
  }

  /// Remove a specific key
  Future<bool> remove(String key) async {
    await init();
    _runtimeValues.remove(key);
    return _isPersistent(key) ? _prefs!.remove(key) : true;
  }

  /// Clear all stored values
  Future<bool> clear() async {
    await init();
    _runtimeValues.clear();
    return _prefs!.clear();
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _isPersistent(key)
        ? (_prefs?.containsKey(key) ?? false)
        : _runtimeValues.containsKey(key);
  }
}
