import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/services/weight_graph_storage.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/data/model/profile_model.dart';
import 'package:gym/scr/data/model/update_profile.dart';
import 'package:gym/scr/domain/repository/update_profile_repository.dart';
import 'package:gym/scr/domain/usecase/height_weight_usecase.dart';
import 'package:gym/scr/domain/usecase/profile_usecase.dart';
import 'package:gym/scr/domain/usecase/update_profile_usecase.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';

class ProfileController extends GetxController {
  ProfileController([
    this._profileUseCase,
    this._updateProfileUseCase,
    this._heightWeightUseCase,
    this._weightGraphStorage,
    this._localStorage,
  ]);

  final ProfileUseCase? _profileUseCase;
  final UpdateProfileUseCase? _updateProfileUseCase;
  final HeightWeightUseCase? _heightWeightUseCase;
  final WeightGraphStorage? _weightGraphStorage;
  final LocalStorageService? _localStorage;

  static const String _streakCountKey = 'profile_daily_streak_count';
  static const String _streakLastVisitKey = 'profile_daily_streak_last_visit';

  String userName = 'Rahul Sharma';
  String userLevel = 'Intermediate Athlete';
  String streak = '1 day';
  String phone = '+91 98765 43210';
  String email = 'rahul.sharma@email.com';
  String gender = 'Male';
  String location = 'Chennai, India';
  String height = '176 cm';
  String profileImageAsset = profileImage;
  Uint8List? profileImageBytes;
  String? profileImageUrl;
  String weight = '72.5 kg';
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

  ProfileUseCase? get _useCase {
    if (_profileUseCase != null) {
      return _profileUseCase;
    }
    if (Get.isRegistered<ProfileUseCase>()) {
      return Get.find<ProfileUseCase>();
    }
    return null;
  }

  UpdateProfileUseCase? get _updateUseCase {
    if (_updateProfileUseCase != null) {
      return _updateProfileUseCase;
    }
    if (Get.isRegistered<UpdateProfileUseCase>()) {
      return Get.find<UpdateProfileUseCase>();
    }
    return null;
  }

  HeightWeightUseCase? get _measurementUseCase {
    if (_heightWeightUseCase != null) {
      return _heightWeightUseCase;
    }
    return Get.isRegistered<HeightWeightUseCase>()
        ? Get.find<HeightWeightUseCase>()
        : null;
  }

  WeightGraphStorage? get _graphStorage {
    if (_weightGraphStorage != null) {
      return _weightGraphStorage;
    }
    return Get.isRegistered<WeightGraphStorage>()
        ? Get.find<WeightGraphStorage>()
        : null;
  }

  LocalStorageService? get _streakStorage {
    if (_localStorage != null) {
      return _localStorage;
    }
    return Get.isRegistered<LocalStorageService>()
        ? Get.find<LocalStorageService>()
        : null;
  }

  @override
  void onInit() {
    super.onInit();
    _updateDailyStreak();
    if (_useCase != null) {
      getProfile();
    }
  }

  Future<void> _updateDailyStreak() async {
    final storage = _streakStorage;
    if (storage == null) {
      return;
    }

    await storage.init();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final storedDate = DateTime.tryParse(
      storage.getString(_streakLastVisitKey) ?? '',
    );
    final lastVisit = storedDate == null
        ? null
        : DateTime(storedDate.year, storedDate.month, storedDate.day);
    var count = storage.getInt(_streakCountKey, defaultValue: 0) ?? 0;

    if (lastVisit == null) {
      count = 1;
    } else {
      final daysSinceLastVisit = today.difference(lastVisit).inDays;
      if (daysSinceLastVisit == 1) {
        count = count < 1 ? 1 : count + 1;
      } else if (daysSinceLastVisit != 0) {
        count = 1;
      } else if (count < 1) {
        count = 1;
      }
    }

    await storage.saveInt(_streakCountKey, count);
    await storage.saveString(
      _streakLastVisitKey,
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
    );
    if (isClosed) {
      return;
    }
    streak = '$count ${count == 1 ? 'day' : 'days'}';
    update();
  }

  Future<void> getProfile() async {
    final useCase = _useCase;
    if (useCase == null || isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    userName = '';
    userLevel = '';
    phone = '';
    email = '';
    gender = '';
    location = '';
    height = '';
    weight = '';
    profileImageUrl = null;
    update();

    try {
      final response = await useCase();
      final isSuccessful = response.success == true || response.code == 200;
      final user = response.data?.user;

      if (!isSuccessful || user == null) {
        errorMessage = response.message ?? 'Unable to load profile.';
        return;
      }

      _applyProfile(user);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      errorMessage = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load profile. Please check your connection.';
    } catch (_) {
      errorMessage = 'Something went wrong while loading your profile.';
    } finally {
      isLoading = false;
      update();
    }
  }

  void _applyProfile(ProfileUser user) {
    userName = _valueOrFallback(user.name, userName);
    userLevel = _valueOrFallback(user.fitnessGoal, userLevel);
    phone = _valueOrFallback(user.phone, phone);
    email = _valueOrFallback(user.email, email);
    gender = _valueOrFallback(user.gender, gender);
    location = _valueOrFallback(user.address, location);
    height = _metricOrFallback(user.height, 'cm', height);
    weight = _metricOrFallback(user.weight, 'kg', weight);
    profileImageUrl = _imageUrl(user.profileImage) ?? profileImageUrl;
  }

  String _valueOrFallback(String? value, String fallback) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  String _metricOrFallback(String? value, String unit, String fallback) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return fallback;
    }
    return normalized.toLowerCase().endsWith(unit.toLowerCase())
        ? normalized
        : '$normalized $unit';
  }

  String? _imageUrl(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return Uri.parse(ApiRoutes.baseUrl).resolve(normalized).toString();
  }

  final List<ProfileQuickAction> quickActions = const [
    ProfileQuickAction(
      icon: Icons.workspace_premium_rounded,
      label: 'Plan',
      route: AppRoutes.choosePlan,
    ),
    ProfileQuickAction(
      icon: Icons.restaurant_menu_rounded,
      label: 'Diet',
      route: AppRoutes.dietPlan,
    ),
    ProfileQuickAction(
      icon: Icons.logout_rounded,
      label: 'Logout',
      route: 'logout',
    ),
  ];

  List<ProfileItem> get physicalDetails => [
    ProfileItem(
      icon: Icons.height_rounded,
      title: 'Height',
      value: height,
      route: 'update_height',
    ),
    ProfileItem(
      icon: Icons.monitor_weight_rounded,
      title: 'Weight',
      value: weight,
      route: 'update_weight',
    ),
  ];

  List<ProfileItem> get profileItems => [
    ProfileItem(
      icon: Icons.badge_rounded,
      title: 'Personal Information',
      value: userName,
      route: AppRoutes.personalInformation,
    ),
    ProfileItem(
      icon: Icons.receipt_long_rounded,
      title: 'Transaction History',
      value: 'Membership payments',
      route: AppRoutes.transactionHistory,
    ),
    ProfileItem(
      icon: Icons.privacy_tip_rounded,
      title: 'Privacy Policy',
      value: 'Data and app policy',
      route: AppRoutes.privacyPolicy,
    ),
  ];

  void updateProfileImage(String imageAsset) {
    profileImageAsset = imageAsset;
    profileImageBytes = null;
    profileImageUrl = null;
    update();
  }

  Future<bool> updatePersonalInformation({
    required String userName,
    required String gender,
    required String location,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final useCase = _updateUseCase;
    if (useCase == null) {
      this.userName = userName;
      this.gender = gender;
      this.location = location;
      profileImageBytes = imageBytes ?? profileImageBytes;
      _syncHomeName(userName);
      update();
      return true;
    }
    if (isUpdating) {
      return false;
    }

    isUpdating = true;
    errorMessage = null;
    update();

    try {
      final response = await useCase(
        UpdateProfileParams(
          name: userName,
          gender: gender,
          address: location,
          profileImageBytes: imageBytes,
          profileImageName: imageName,
        ),
      );
      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;

      if (!isSuccessful) {
        errorMessage = response.message ?? 'Unable to update profile.';
        return false;
      }

      final user = response.data?.user;
      if (user != null) {
        _applyUpdatedProfile(user);
        this.userName = userName;
      } else {
        this.userName = userName;
        this.gender = gender;
        this.location = location;
      }
      profileImageBytes = imageBytes ?? profileImageBytes;
      _syncHomeName(this.userName);
      return true;
    } on DioException catch (error) {
      final responseData = error.response?.data;
      errorMessage = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to update profile. Please check your connection.';
      return false;
    } catch (_) {
      errorMessage = 'Something went wrong while updating your profile.';
      return false;
    } finally {
      isUpdating = false;
      update();
    }
  }

  void _applyUpdatedProfile(UpdatedProfileUser user) {
    userName = _valueOrFallback(user.name, userName);
    userLevel = _valueOrFallback(user.fitnessGoal, userLevel);
    phone = _valueOrFallback(user.phone, phone);
    email = _valueOrFallback(user.email, email);
    gender = _valueOrFallback(user.gender, gender);
    location = _valueOrFallback(user.address, location);
    height = _metricOrFallback(user.height, 'cm', height);
    weight = _metricOrFallback(user.weight, 'kg', weight);
    profileImageUrl = _imageUrl(user.profileImage) ?? profileImageUrl;
  }

  void _syncHomeName(String name) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().applyUserName(name);
    }
  }

  void openRoute(String route) {
    if (route == 'update_height') {
      _openMetricDialog(editingHeight: true);
      return;
    }

    if (route == 'update_weight') {
      _openMetricDialog(editingHeight: false);
      return;
    }

    if (route == 'logout') {
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF1B1F21),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                final storage = _streakStorage ?? LocalStorageService();
                await storage.remove('auth_token');
                Get.offAllNamed(AppRoutes.login);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    Get.toNamed(route);
  }

  void _openMetricDialog({required bool editingHeight}) {
    Get.dialog(
      _HeightWeightDialog(
        editingHeight: editingHeight,
        initialHeight: _metricValue(height, 'cm'),
        initialWeight: _metricValue(weight, 'kg'),
        onSave: (heightValue, weightValue) => saveHeightWeight(
          heightValue: heightValue,
          weightValue: weightValue,
        ),
        errorMessage: () => errorMessage,
      ),
    );
  }

  String _metricValue(String value, String unit) {
    final trimmedValue = value.trim();
    final suffix = ' $unit';

    if (trimmedValue.toLowerCase().endsWith(suffix)) {
      return trimmedValue.substring(0, trimmedValue.length - suffix.length);
    }

    return trimmedValue;
  }

  Future<bool> saveHeightWeight({
    String? heightValue,
    String? weightValue,
  }) async {
    final parsedHeight = _parseMetric(heightValue ?? height, 'cm');
    final parsedWeight = _parseMetric(weightValue ?? weight, 'kg');
    if (parsedHeight == null || parsedWeight == null) {
      errorMessage = 'Enter valid height and weight values.';
      return false;
    }
    if (isUpdating) {
      return false;
    }

    final useCase = _measurementUseCase;
    if (useCase == null) {
      await _applyHeightWeight(parsedHeight, parsedWeight);
      return true;
    }

    isUpdating = true;
    errorMessage = null;
    update();
    try {
      final response = await useCase(
        height: parsedHeight,
        weight: parsedWeight,
      );
      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      if (!isSuccessful) {
        errorMessage = response.message ?? 'Unable to save height and weight.';
        return false;
      }

      final savedHeight =
          _parseMetric(response.data?.height, 'cm') ?? parsedHeight;
      final savedWeight =
          _parseMetric(response.data?.weight, 'kg') ?? parsedWeight;
      await _applyHeightWeight(savedHeight, savedWeight);
      return true;
    } on DioException catch (error) {
      final responseData = error.response?.data;
      errorMessage = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to save height and weight. Please check your connection.';
      return false;
    } catch (_) {
      errorMessage = 'Something went wrong while saving height and weight.';
      return false;
    } finally {
      isUpdating = false;
      update();
    }
  }

  double? _parseMetric(String? value, String unit) {
    final normalized = value
        ?.trim()
        .replaceAll(RegExp(unit, caseSensitive: false), '')
        .replaceAll(',', '.')
        .trim();
    final parsed = double.tryParse(normalized ?? '');
    return parsed != null && parsed > 0 ? parsed : null;
  }

  Future<void> _applyHeightWeight(double newHeight, double newWeight) async {
    height = '${_compactMetric(newHeight)} cm';
    weight = '${_compactMetric(newWeight)} kg';
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().applyWeight(newWeight);
    }
    if (Get.isRegistered<ProgressController>()) {
      await Get.find<ProgressController>().recordWeight(newWeight);
    } else {
      await _graphStorage?.add(newWeight);
    }
    update();
  }

  String _compactMetric(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}

class _HeightWeightDialog extends StatefulWidget {
  const _HeightWeightDialog({
    required this.editingHeight,
    required this.initialHeight,
    required this.initialWeight,
    required this.onSave,
    required this.errorMessage,
  });

  final bool editingHeight;
  final String initialHeight;
  final String initialWeight;
  final Future<bool> Function(String height, String weight) onSave;
  final String? Function() errorMessage;

  @override
  State<_HeightWeightDialog> createState() => _HeightWeightDialogState();
}

class _HeightWeightDialogState extends State<_HeightWeightDialog> {
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: widget.initialHeight);
    _weightController = TextEditingController(text: widget.initialWeight);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heightField = _measurementField(
      controller: _heightController,
      label: 'Height (cm)',
      hint: 'e.g. 176',
      autofocus: widget.editingHeight,
    );
    final weightField = _measurementField(
      controller: _weightController,
      label: 'Weight (kg)',
      hint: 'e.g. 72.5',
      autofocus: !widget.editingHeight,
    );

    return AlertDialog(
      backgroundColor: const Color(0xFF1B1F21),
      title: Text(
        widget.editingHeight ? 'Update Height' : 'Update Weight',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.editingHeight
            ? [weightField, const SizedBox(height: 12), heightField]
            : [heightField, const SizedBox(height: 12), weightField],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: _isSaving ? null : _save,
          child: Text(
            _isSaving ? 'Saving...' : 'Save',
            style: const TextStyle(
              color: Color(0xFFD0FD3E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _measurementField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool autofocus,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _save() async {
    final heightValue = _heightController.text.trim();
    final weightValue = _weightController.text.trim();
    final parsedHeight = double.tryParse(heightValue.replaceAll(',', '.'));
    final parsedWeight = double.tryParse(weightValue.replaceAll(',', '.'));

    if (parsedHeight == null ||
        parsedHeight <= 0 ||
        parsedWeight == null ||
        parsedWeight <= 0) {
      ToastHelper.error(
        'Invalid measurements',
        'Enter valid height and weight values.',
      );
      return;
    }

    setState(() => _isSaving = true);
    final saved = await widget.onSave(heightValue, weightValue);
    if (!mounted) return;

    if (saved) {
      Navigator.of(context).pop();
      ToastHelper.success(
        'Updated successfully',
        'Your height and weight have been saved.',
      );
      return;
    }

    setState(() => _isSaving = false);
    ToastHelper.error(
      'Update failed',
      widget.errorMessage() ?? 'Unable to save height and weight.',
    );
  }
}

class ProfileQuickAction {
  const ProfileQuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class ProfileItem {
  const ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
    this.route,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? route;
}
