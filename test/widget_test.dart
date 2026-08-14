import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/data/model/category_model.dart';
import 'package:gym/scr/data/model/diet_by_plan_model.dart';
import 'package:gym/scr/data/model/diet_model.dart';
import 'package:gym/scr/data/model/exercise_model.dart';
import 'package:gym/scr/domain/repository/category_repository.dart';
import 'package:gym/scr/domain/repository/diet_by_plan_repository.dart';
import 'package:gym/scr/domain/repository/diet_repository.dart';
import 'package:gym/scr/domain/repository/exercise_repository.dart';
import 'package:gym/scr/domain/usecase/category_usecase.dart';
import 'package:gym/scr/domain/usecase/diet_by_plan_usecase.dart';
import 'package:gym/scr/domain/usecase/diet_usecase.dart';
import 'package:gym/scr/domain/usecase/exercise_usecase.dart';
import 'package:gym/scr/presentation/view/auth/login.dart';
import 'package:gym/scr/presentation/view/auth/otp.dart';
import 'package:gym/scr/presentation/view/auth/sign_up.dart';
import 'package:gym/scr/presentation/view/diet/diet_plan.dart';
import 'package:gym/scr/presentation/view/home/widget/homescreen.dart';
import 'package:gym/scr/presentation/view/onboarding/onboarding.dart';
import 'package:gym/scr/presentation/view/progress/progress.dart';
import 'package:gym/scr/presentation/view/workout/my_workout.dart';
import 'package:gym/scr/presentation/view/workout/workout.dart';
import 'package:gym/scr/presentation/view/profile/personal_information.dart';
import 'package:gym/scr/presentation/view/profile/profile.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/controller/sign_up_controller.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/controller/diet_plan_controller.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';
import 'package:gym/scr/presentation/widgets/main/main_navigation.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('Onboarding automatically changes background image', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pump();

    expect(find.text('Train with intent'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.byKey(const ValueKey(onboardingImageOne)), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.byKey(const ValueKey(onboardingImageTwo)), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.byKey(const ValueKey(onboardingImageThree)), findsOneWidget);
  });

  testWidgets('Login screen shows form without social options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login to continue your fitness journey'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('+91 '), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.byKey(const ValueKey(login)), findsOneWidget);
    expect(find.byKey(const ValueKey('login-content-slide')), findsOneWidget);

    expect(find.text('or continue with'), findsNothing);
    expect(find.text('Google'), findsNothing);
    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('Replacing Login keeps its phone controller active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const LoginScreen()),
    );

    Get.offAllNamed<void>(
      AppRoutes.login,
      arguments: const {'phone': '9876543210'},
    );
    await tester.pumpAndSettle();

    final phoneField = find.byType(TextField).first;
    expect(find.text('9876543210'), findsOneWidget);
    await tester.enterText(phoneField, '917379612427');
    await tester.pump();
    expect(find.text('7379612427'), findsOneWidget);
  });

  testWidgets('Sign up screen shows red registration form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    expect(
      find.byKey(const ValueKey('signup-login-background')),
      findsOneWidget,
    );
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byKey(const ValueKey('signup-subtitle')), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Fitness Goal'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('signup-fitness-goal-dropdown')),
      findsOneWidget,
    );
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('DOB'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Gender'), findsNWidgets(2));
    expect(find.text('City or address'), findsOneWidget);
    expect(find.text('YYYY-MM-DD', skipOffstage: false), findsOneWidget);
    expect(find.text('Continue', skipOffstage: false), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Sign up validates phone and accepts a plain DOB value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    final textFields = find.byType(TextFormField);

    await tester.enterText(textFields.at(1), '1234567890123');
    expect(find.text('1234567890'), findsOneWidget);

    final signUpController = Get.find<SignUpController>();
    signUpController.updateDob(DateTime(2004, 9, 8));
    await tester.pump();
    expect(find.text('2004-09-08'), findsOneWidget);

    await tester.ensureVisible(textFields.at(3));
    await tester.pumpAndSettle();
    await tester.tap(textFields.at(3));
    await tester.pumpAndSettle();
    expect(find.text('Select date of birth'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final continueButton = find.text('Continue', skipOffstage: false);

    await tester.scrollUntilVisible(
      continueButton.last,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(continueButton.last);
    await tester.pump();

    expect(find.text('Name is required', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Gender is required', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Location is required', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Fitness goal is required', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('OTP screen shows four digit inputs and validates code', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OtpScreen()));

    expect(find.byKey(const ValueKey('otp-login-background')), findsOneWidget);
    expect(find.text('OTP Verification'), findsOneWidget);
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.byKey(const ValueKey('otp-digit-box')), findsNWidgets(4));
    expect(find.byKey(const ValueKey('otp-input')), findsOneWidget);
    expect(find.text('Verify OTP'), findsOneWidget);
    expect(find.text('Resend in 00:30'), findsOneWidget);

    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Resend'), findsOneWidget);

    await tester.tap(find.text('Verify OTP'));
    await tester.pump();

    expect(find.text('Enter the 4 digit OTP'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('otp-input')), '1234');
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Enter the 4 digit OTP'), findsNothing);
  });

  testWidgets('Home screen shows workout dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const HomeScreen()),
    );

    expect(find.text('Hello, Rahul'), findsOneWidget);
    expect(find.text("Let's smash your goals today!"), findsOneWidget);
    expect(find.text("Today's Workout"), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-today-workout-total')),
      findsNothing,
    );
    expect(find.text('No exercises added'), findsOneWidget);
    expect(find.text('Browse Exercises'), findsOneWidget);
    expect(find.text('Today Plan'), findsNothing);
    expect(find.byKey(const ValueKey('home-workout-image')), findsOneWidget);
    expect(find.text('Calories'), findsNothing);
    expect(find.text('Workout Time'), findsOneWidget);
    expect(find.text('0 min', findRichText: true), findsOneWidget);
    expect(find.text('Water'), findsNothing);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    expect(find.text("today's activity"), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Diet Plan'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-diet-card')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-card-artwork-workout-time')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-card-artwork-steps')),
      findsOneWidget,
    );
    expect(find.text('Body Overview'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-card-artwork-body-overview')),
      findsOneWidget,
    );
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.byKey(const ValueKey('current-streak-days')), findsOneWidget);
    expect(find.text('Height'), findsNothing);
    expect(find.text('BMI'), findsNothing);
    expect(find.text('Body Fat'), findsNothing);
  });

  testWidgets('Home browse action opens the exercise catalog', (
    WidgetTester tester,
  ) async {
    Get.put(_apiWorkoutController());
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, initialRoute: AppRoutes.main),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Browse Exercises'));
    await tester.pumpAndSettle();

    expect(find.text('Workout categories'), findsOneWidget);
    expect(find.text('Strength Training'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsNothing);
  });

  testWidgets('Home start workout opens My Workout when an exercise exists', (
    WidgetTester tester,
  ) async {
    final workoutController = Get.put(WorkoutController());
    workoutController.addExercise(workoutController.allExercises.first);

    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const HomeScreen()),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Start Workout'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('My Workout'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);
  });

  testWidgets('Workout timer finish marks exercise completed', (
    WidgetTester tester,
  ) async {
    final workoutController = Get.put(WorkoutController());
    workoutController.addExercise(workoutController.allExercises.first);

    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const MyWorkoutScreen()),
    );

    await tester.tap(
      find.byKey(const ValueKey('start-exercise-chest-bench-press')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Workout Timer'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Calories Burned'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('workout-calories-value')),
      findsOneWidget,
    );
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('My Workout'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.textContaining('Completed'), findsOneWidget);
  });

  test('Completed exercise times accumulate in today workout total', () {
    final controller = WorkoutController();
    final first = controller.allExercises[0];
    final second = controller.allExercises[1];
    controller.addExercise(first);
    controller.addExercise(second);

    controller.startExercise(first);
    controller.pauseWorkoutTimer();
    controller.workoutElapsedSeconds.value = 65;
    controller.finishWorkout();

    controller.startExercise(second);
    controller.pauseWorkoutTimer();
    controller.workoutElapsedSeconds.value = 125;
    controller.finishWorkout();

    expect(controller.exerciseDuration(first), 65);
    expect(controller.exerciseDuration(second), 125);
    expect(controller.todayWorkoutElapsedSeconds.value, 190);
    expect(controller.formattedTodayWorkoutElapsed, '00:03:10');
  });

  testWidgets('Exercise catalog supports details, search, and adding', (
    WidgetTester tester,
  ) async {
    Get.put(_apiWorkoutController());
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const WorkoutScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Workout categories'), findsOneWidget);
    expect(find.text('Strength Training'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('category-3')));
    await tester.pump();
    expect(find.text('Workout categories'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('category-1')));
    await tester.pumpAndSettle();

    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('exercise-search-1')),
      'bench',
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('exercise-card-api-10')));
    await tester.pumpAndSettle();

    expect(find.text('How to do'), findsOneWidget);
    expect(
      find.textContaining('Lie with your eyes beneath the bar'),
      findsOneWidget,
    );
    expect(find.text('Add to Workout'), findsOneWidget);
    expect(find.byKey(const ValueKey('exercise-video-play')), findsOneWidget);

    await tester.tap(find.text('Add to Workout'));
    await tester.pump();
    expect(find.text('Added to My Workout'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('Workout screen recreates an API-connected controller', (
    WidgetTester tester,
  ) async {
    Get.lazyPut<CategoryUseCase>(
      () => CategoryUseCase(_FakeCategoryRepository()),
      fenix: true,
    );
    Get.lazyPut<ExerciseUseCase>(
      () => ExerciseUseCase(_FakeExerciseRepository()),
      fenix: true,
    );

    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const WorkoutScreen()),
    );
    await tester.pumpAndSettle();

    final recreatedController = Get.find<WorkoutController>();
    expect(
      recreatedController.categories,
      isNotEmpty,
      reason:
          'loading=${recreatedController.isCategoryLoading.value}, '
          'error=${recreatedController.categoryError.value}',
    );
    await tester.tap(find.byKey(const ValueKey('category-1')));
    await tester.pumpAndSettle();

    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(Get.find<WorkoutController>().categoryExercises, isNotEmpty);
  });

  testWidgets('Workout category flow fits a compact phone screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Get.put(_apiWorkoutController());
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const WorkoutScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('category-1')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('category-1')));
    await tester.pumpAndSettle();

    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('My Workout prevents duplicates and caps the queue at ten', () {
    final controller = WorkoutController();

    expect(controller.addExercise(controller.allExercises.first), isTrue);
    expect(controller.addExercise(controller.allExercises.first), isFalse);

    for (final exercise in controller.allExercises.skip(1).take(9)) {
      expect(controller.addExercise(exercise), isTrue);
    }

    expect(controller.selectedExercises, hasLength(10));
    expect(controller.addExercise(controller.allExercises[10]), isFalse);
  });

  test('Completing an exercise advances to the next queued exercise', () {
    final controller = WorkoutController();
    final first = controller.allExercises[0];
    final second = controller.allExercises[1];
    controller.addExercise(first);
    controller.addExercise(second);

    expect(controller.nextExercise?.id, first.id);
    controller.markExerciseCompleted(first);
    expect(controller.nextExercise?.id, second.id);
    controller.markExerciseCompleted(second);
    expect(controller.nextExercise, isNull);
    expect(controller.hasCompletedWorkout, isTrue);
  });

  testWidgets('Home does not expose placeholder workout history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const HomeScreen()),
    );

    await tester.tap(find.text('Workout Time'));
    await tester.pumpAndSettle();

    expect(find.text('Workout Time History'), findsNothing);
    expect(find.text('Chest workout completed'), findsNothing);
    expect(find.text('45 min'), findsNothing);
    expect(find.text('Water'), findsNothing);
    expect(find.text('Water History'), findsNothing);
  });

  testWidgets('Home shows weight history without height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const HomeScreen()),
    );

    await tester.scrollUntilVisible(
      find.text('Weight'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weight'));
    await tester.pumpAndSettle();

    expect(find.text('Weight History'), findsOneWidget);
    expect(find.text('Morning check-in'), findsOneWidget);
    expect(find.text('72.5 kg'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Body Overview'), findsOneWidget);
    expect(find.text('Height'), findsNothing);
  });

  testWidgets('Main navigation shows compact bottom bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppRoutes.routes,
        home: const MainNavigationScreen(),
      ),
    );

    expect(find.text('Hello, Rahul'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Progress'), findsNothing);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle();

    expect(find.text('Workouts'), findsWidgets);

    await tester.tap(find.text('Attendance'));
    await tester.pumpAndSettle();

    expect(
      find.text('Scan the gym QR to mark today\'s visit.'),
      findsOneWidget,
    );
  });

  testWidgets('Diet meal cards open food detail screen', (
    WidgetTester tester,
  ) async {
    Get.put(
      DietPlanController(
        DietUseCase(_FakeDietRepository()),
        DietByPlanUseCase(_FakeDietByPlanRepository()),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const DietPlanScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Weight Gain'), findsWidgets);
    expect(find.text('Weight Loss'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('diet-plan-1')));
    await tester.pump();

    await tester.tap(find.text('Oatmeal with Fruits'));
    await tester.pumpAndSettle();

    expect(find.text('Food Details'), findsOneWidget);
    expect(find.text('Oatmeal with Fruits'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('400 kcal'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('16 g'), findsOneWidget);
    expect(find.textContaining('A filling bowl of oats'), findsOneWidget);
  });

  test('Diet controller loads plans through the use case', () async {
    final controller = DietPlanController(
      DietUseCase(_FakeDietRepository()),
      DietByPlanUseCase(_FakeDietByPlanRepository()),
    );

    await controller.getDietPlans();

    expect(controller.apiDietPlans, hasLength(2));
    expect(controller.apiDietPlans.first.planName, 'Weight Gain');
    expect(controller.apiMeals, hasLength(1));
    expect(controller.apiMeals.first.foodName, 'Protein Smoothie');
    expect(controller.dietPlanError.value, isNull);
  });

  testWidgets('Progress shows only weight tracking', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: ProgressScreen()));

    expect(find.text('Current Weight'), findsOneWidget);
    expect(find.text('Weight Graph'), findsNothing);
    expect(find.text("Log Today's Weight"), findsNothing);
    expect(find.text('Days'), findsNothing);
    expect(find.text('Weeks'), findsNothing);
    expect(find.text('Months'), findsNothing);
    expect(find.text('Annual'), findsNothing);
    expect(find.text('Water Level'), findsNothing);
    expect(find.byKey(const ValueKey('water-level-input')), findsNothing);
  });

  testWidgets('Profile account items open detail screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(getPages: AppRoutes.routes, home: const ProfileScreen()),
    );

    expect(find.text('Physical Detail'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('0 days'), findsOneWidget);
    expect(find.text('Tokens'), findsNothing);
    expect(find.text('Plan'), findsNothing);
    expect(find.text('Transaction History'), findsNothing);
    expect(find.text('Diet'), findsNothing);
    expect(find.text('Rewards'), findsNothing);
    expect(find.text('Fitness Goal'), findsNothing);
    expect(find.text('176 cm'), findsOneWidget);
    expect(find.text('72.5 kg'), findsOneWidget);

    await tester.tap(find.text('Height'));
    await tester.pumpAndSettle();

    expect(find.text('Update Height'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '180');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('180 cm'), findsOneWidget);

    await tester.tap(find.text('Personal Information'));
    await tester.pumpAndSettle();

    expect(find.text('Basic Details'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Privacy Policy'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('Your Data'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Terms & Conditions'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Terms & Conditions'));
    await tester.pumpAndSettle();

    expect(find.text('Using the App'), findsOneWidget);
    expect(find.text('Health & Safety'), findsOneWidget);
  });

  testWidgets('Personal information edits details and offers gallery image', (
    WidgetTester tester,
  ) async {
    final homeController = Get.put(HomeController());
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppRoutes.routes,
        home: const PersonalInformationScreen(),
      ),
    );

    expect(find.text('Basic Details'), findsOneWidget);
    expect(find.text('Physical Detail'), findsNothing);
    expect(find.text('Height (cm)'), findsNothing);
    expect(find.text('Weight (kg)'), findsNothing);
    expect(find.text('Age'), findsNothing);
    expect(find.text('DOB'), findsNothing);
    expect(find.text('Email'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-email-input')), findsOneWidget);
    expect(find.text('Blood Group'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile-blood-group-input')),
      findsOneWidget,
    );
    expect(find.text('Fitness Goal'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile-fitness-goal-input')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-photo-upload-button')),
      findsOneWidget,
    );
    expect(find.text('Change Photo'), findsNothing);
    expect(find.byIcon(Icons.edit_rounded), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('profile-name-input')),
      'Meena Raj',
    );

    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile-save-button')));
    for (var attempt = 0; attempt < 20; attempt += 1) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Personal information updated').evaluate().isNotEmpty) {
        break;
      }
    }

    final controller = Get.find<ProfileController>();
    expect(controller.userName, 'Meena Raj');
    expect(homeController.userName.value, 'Meena Raj');
    expect(find.text('Personal information updated'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}

WorkoutController _apiWorkoutController() {
  return WorkoutController(
    CategoryUseCase(_FakeCategoryRepository()),
    ExerciseUseCase(_FakeExerciseRepository()),
  );
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<CategoryModel> getCategories() async {
    return const CategoryModel(
      success: true,
      code: 200,
      data: [
        CategoryData(
          id: 1,
          categoryName: 'Strength Training',
          description: 'Build power and confidence',
          exerciseCount: 1,
        ),
        CategoryData(
          id: 3,
          categoryName: 'Muscle Builder',
          description: 'More exercises are coming soon',
          exerciseCount: 0,
        ),
      ],
    );
  }
}

class _FakeExerciseRepository implements ExerciseRepository {
  @override
  Future<ExerciseModel> getExercises(int categoryId) async {
    return ExerciseModel(
      success: true,
      code: 200,
      data: ExerciseData(
        categoryId: categoryId,
        categoryName: 'Strength Training',
        count: 1,
        exercises: const [
          ExerciseItem(
            id: 10,
            exerciseName: 'Barbell Bench Press',
            videoUrl: 'https://youtu.be/-hSma-BRzoo',
            sets: 4,
            reps: 10,
            restSeconds: 60,
            calories: 120,
            howTo: ['Lie with your eyes beneath the bar and plant both feet.'],
          ),
        ],
      ),
    );
  }
}

class _FakeDietRepository implements DietRepository {
  @override
  Future<DietModel> getDietPlans() async {
    return const DietModel(
      success: true,
      code: 200,
      data: DietData(
        count: 2,
        plans: [
          DietPlan(id: 2, planName: 'Weight Gain'),
          DietPlan(id: 1, planName: 'Weight Loss'),
        ],
      ),
    );
  }
}

class _FakeDietByPlanRepository implements DietByPlanRepository {
  @override
  Future<DietByPlanModel> getMeals(int planId) async {
    final isWeightGain = planId == 2;
    return DietByPlanModel(
      success: true,
      code: 200,
      data: DietByPlanData(
        planId: planId,
        planName: isWeightGain ? 'Weight Gain' : 'Weight Loss',
        count: 1,
        meals: [
          DietMealItem(
            id: isWeightGain ? 2 : 1,
            mealType: 'Breakfast',
            foodName: isWeightGain ? 'Protein Smoothie' : 'Oatmeal with Fruits',
            calories: isWeightGain ? 520 : 400,
            protein: isWeightGain ? 32 : 16,
            description: isWeightGain
                ? 'A calorie-rich smoothie for muscle recovery.'
                : 'A filling bowl of oats topped with fresh fruits.',
          ),
        ],
      ),
    );
  }
}
