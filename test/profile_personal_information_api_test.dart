import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gym/scr/data/model/profile_model.dart';
import 'package:gym/scr/data/model/update_profile.dart';
import 'package:gym/scr/domain/repository/profile_repository.dart';
import 'package:gym/scr/domain/repository/update_profile_repository.dart';
import 'package:gym/scr/domain/usecase/profile_usecase.dart';
import 'package:gym/scr/domain/usecase/update_profile_usecase.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/view/profile/personal_information.dart';

void main() {
  tearDown(Get.reset);

  test(
    'posts personal information and refreshes displayed values with GET',
    () async {
      final profileRepository = _FakeProfileRepository();
      final updateRepository = _FakeUpdateProfileRepository();
      final controller = ProfileController(
        ProfileUseCase(profileRepository),
        UpdateProfileUseCase(updateRepository),
      );

      final saved = await controller.updatePersonalInformation(
        userName: 'Submitted Name',
        email: 'submitted@example.com',
        gender: 'Female',
        bloodGroup: 'A+',
        fitnessGoal: 'Weight Loss',
        location: 'Submitted Location',
      );

      expect(saved, isTrue);
      expect(updateRepository.params?.email, 'submitted@example.com');
      expect(updateRepository.params?.bloodGroup, 'A+');
      expect(updateRepository.params?.fitnessGoal, 'Weight Loss');
      expect(profileRepository.getCalls, 1);
      expect(controller.userName, 'Persisted Name');
      expect(controller.email, 'persisted@example.com');
      expect(controller.bloodGroup, 'O-');
      expect(controller.fitnessGoal, 'Muscle Gain');
      expect(controller.location, 'Persisted Location');
    },
  );

  testWidgets('shows the profile GET fitness goal in the dropdown', (
    tester,
  ) async {
    final controller = Get.put(
      ProfileController(ProfileUseCase(_FakeProfileRepository())),
    );
    await tester.pumpWidget(
      const GetMaterialApp(home: PersonalInformationScreen()),
    );
    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    expect(controller.fitnessGoal, 'Muscle Gain');
    expect(dropdown.value, 'Muscle Gain');
  });
}

class _FakeProfileRepository implements ProfileRepository {
  int getCalls = 0;

  @override
  Future<ProfileModel> getProfile() async {
    getCalls += 1;
    return const ProfileModel(
      success: true,
      code: 200,
      data: ProfileData(
        user: ProfileUser(
          name: 'Persisted Name',
          email: 'persisted@example.com',
          gender: 'Female',
          bloodGroup: 'O-',
          fitnessGoal: 'Muscle Gain',
          address: 'Persisted Location',
        ),
      ),
    );
  }
}

class _FakeUpdateProfileRepository implements UpdateProfileRepository {
  UpdateProfileParams? params;

  @override
  Future<UpdateProfileModel> updateProfile(UpdateProfileParams params) async {
    this.params = params;
    return const UpdateProfileModel(success: true, code: 200);
  }
}
