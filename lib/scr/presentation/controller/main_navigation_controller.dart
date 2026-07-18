import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';

class MainNavigationController extends GetxController {
  static const String _morningWeightPromptKey =
      'morning_weight_prompt_last_shown';

  final RxInt selectedIndex = 0.obs;
  bool _isSavingMorningWeight = false;

  @override
  void onReady() {
    super.onReady();
    _showMorningWeightPrompt();
  }

  Future<void> _showMorningWeightPrompt() async {
    if (!Get.isRegistered<LocalStorageService>()) {
      return;
    }

    final now = DateTime.now();
    if (now.hour >= 12) {
      return;
    }

    final storage = Get.find<LocalStorageService>();
    await storage.init();
    final today = _dateKey(now);
    if (storage.getString(_morningWeightPromptKey) == today) {
      return;
    }

    await storage.saveString(_morningWeightPromptKey, today);
    if (Get.context == null || Get.isDialogOpen == true) {
      return;
    }

    await Get.dialog<void>(
      _MorningWeightDialog(onSave: _saveMorningWeight),
      barrierDismissible: false,
    );
  }

  Future<void> _saveMorningWeight(String value) async {
    if (_isSavingMorningWeight) {
      return;
    }

    final normalizedValue = value.trim().replaceAll(',', '.');
    final weight = double.tryParse(normalizedValue);
    if (weight == null || weight <= 0) {
      ToastHelper.error('Invalid weight', 'Enter a valid weight in kg.');
      return;
    }

    _isSavingMorningWeight = true;
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final saved = await profileController.saveHeightWeight(
      weightValue: normalizedValue,
    );
    _isSavingMorningWeight = false;

    if (!saved) {
      ToastHelper.error(
        'Weight not saved',
        profileController.errorMessage ?? 'Please try again.',
      );
      return;
    }

    Get.back<void>();
    ToastHelper.success('Weight updated', "Today's weight has been saved.");
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void selectTab(int index) {
    selectedIndex.value = index;

    if (index == 1 && Get.isRegistered<WorkoutController>()) {
      final workoutController = Get.find<WorkoutController>();
      if (workoutController.categories.isEmpty &&
          !workoutController.isCategoryLoading.value) {
        workoutController.getCategories();
      }
    }
  }
}

class _MorningWeightDialog extends StatefulWidget {
  const _MorningWeightDialog({required this.onSave});

  final Future<void> Function(String value) onSave;

  @override
  State<_MorningWeightDialog> createState() => _MorningWeightDialogState();
}

class _MorningWeightDialogState extends State<_MorningWeightDialog> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1B1F21),
      title: const Row(
        children: [
          Icon(Icons.wb_sunny_rounded, color: Color(0xFFFF8A90)),
          SizedBox(width: 10),
          Expanded(
            child: Text('Good morning!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Please enter today's weight to keep your daily progress up to date.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('morning-weight-input'),
            controller: _weightController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              hintText: 'Enter weight in kg',
              hintStyle: const TextStyle(color: Colors.white38),
              suffixText: 'kg',
              suffixStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Later', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          key: const ValueKey('morning-weight-save'),
          onPressed: () => widget.onSave(_weightController.text),
          child: const Text(
            'Save Weight',
            style: TextStyle(
              color: Color(0xFFFF5A64),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
