import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';

class MainNavigationController extends GetxController {
  static const String _initialProfileSetupPromptKey =
      'initial_profile_setup_prompt_shown';

  final RxInt selectedIndex = 0.obs;

  @override
  void onReady() {
    super.onReady();
    _showInitialPrompt();
  }

  Future<void> _showInitialPrompt() async {
    if (!Get.isRegistered<LocalStorageService>()) {
      return;
    }

    final storage = Get.find<LocalStorageService>();
    await storage.init();

    if (storage.getBool(_initialProfileSetupPromptKey) != true) {
      if (Get.context == null || Get.isDialogOpen == true) {
        return;
      }

      await storage.saveBool(_initialProfileSetupPromptKey, true);
      await Get.dialog<void>(
        _ProfileSetupDialog(onSetupProfile: _openProfile),
        barrierDismissible: false,
      );
    }
  }

  void _openProfile() {
    Get.back<void>();
    selectTab(3);
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

class _ProfileSetupDialog extends StatelessWidget {
  const _ProfileSetupDialog({required this.onSetupProfile});

  final VoidCallback onSetupProfile;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1B1F21),
      title: const Row(
        children: [
          Icon(Icons.person_rounded, color: Color(0xFFFF8A90)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Set up your profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      content: const Text(
        'Complete your profile to personalize your fitness journey and track your progress.',
        style: TextStyle(color: Colors.white70, fontSize: 13),
      ),
      actions: [
        TextButton(
          key: const ValueKey('set-up-profile-button'),
          onPressed: onSetupProfile,
          child: const Text(
            'Set Up Profile',
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
