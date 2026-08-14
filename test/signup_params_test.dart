import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/domain/repository/signup_repository.dart';

void main() {
  test('signup payload sends address and fitness goal backend keys', () {
    const params = SignupParams(
      name: 'Meena',
      phone: '9876543210',
      gender: 'Female',
      address: 'Chennai',
      dob: '2000-01-01',
      fitnessGoal: 'Weight Loss',
    );

    expect(params.toJson(), {
      'name': 'Meena',
      'phone_number': '9876543210',
      'gender': 'Female',
      'address': 'Chennai',
      'dob': '2000-01-01',
      'fitness_goal': 'Weight Loss',
    });
    expect(params.toJson().containsKey('place'), isFalse);
  });
}
