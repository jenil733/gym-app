import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/data/model/profile_model.dart';
import 'package:gym/scr/domain/repository/profile_repository.dart';
import 'package:gym/scr/domain/usecase/profile_usecase.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';

void main() {
  test('marks zero profile measurements as missing', () async {
    final controller = HomeController(
      null,
      null,
      null,
      ProfileUseCase(_MissingMeasurementsRepository()),
    );

    await controller.getProfileName();

    expect(controller.hasLoadedProfileMeasurements.value, isTrue);
    expect(controller.profileHeight.value, 0);
    expect(controller.profileWeight.value, 0);
  });
}

class _MissingMeasurementsRepository implements ProfileRepository {
  @override
  Future<ProfileModel> getProfile() async {
    return const ProfileModel(
      success: true,
      code: 200,
      data: ProfileData(
        user: ProfileUser(name: 'New member', height: '0', weight: '0'),
      ),
    );
  }
}
