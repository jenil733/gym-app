import 'package:get/get.dart';
import 'package:gym/scr/presentation/controller/diet_plan_controller.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/view/auth/login.dart';
import 'package:gym/scr/presentation/view/auth/otp.dart';
import 'package:gym/scr/presentation/view/auth/sign_up.dart';
import 'package:gym/scr/presentation/view/diet/diet_plan.dart';
import 'package:gym/scr/presentation/view/diet/meal_detail.dart';
import 'package:gym/scr/presentation/view/home/body_history.dart';
import 'package:gym/scr/presentation/view/home/stat_history.dart';
import 'package:gym/scr/presentation/view/notifications/notifications.dart';
import 'package:gym/scr/presentation/view/onboarding/onboarding.dart';
import 'package:gym/scr/presentation/view/plan/choose_plan.dart';
import 'package:gym/scr/presentation/view/profile/personal_information.dart';
import 'package:gym/scr/presentation/view/profile/privacy_policy.dart';
import 'package:gym/scr/presentation/view/profile/transaction_history.dart';
import 'package:gym/scr/presentation/view/splash_screen/splash.dart';
import 'package:gym/scr/presentation/view/workout/exercise_detail.dart';
import 'package:gym/scr/presentation/view/workout/my_workout.dart';
import 'package:gym/scr/presentation/view/workout/workout_timer.dart';
import 'package:gym/scr/presentation/widgets/main/main_navigation.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String main = '/main';
  static const String timer = '/timer';
  static const String choosePlan = '/choose-plan';
  static const String notifications = '/notifications';
  static const String trainer = '/trainer';
  static const String exerciseDetail = '/exercise-detail';
  static const String myWorkout = '/my-workout';
  static const String statHistory = '/stat-history';
  static const String bodyHistory = '/body-history';
  static const String dietPlan = '/diet-plan';
  static const String mealDetail = '/meal-detail';
  static const String personalInformation = '/personal-information';
  static const String transactionHistory = '/transaction-history';
  static const String privacyPolicy = '/privacy-policy';
  static List<GetPage> routes = [
    GetPage(
      transition: Transition.fade,
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: signUp,
      page: () => const SignUpScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: otp,
      page: () => const OtpScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: main,
      page: () => const MainNavigationScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: timer,
      page: () => const WorkoutTimerScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: choosePlan,
      page: () => const ChoosePlanScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: notifications,
      page: () => const NotificationsScreen(),
    ),

    GetPage(
      transition: Transition.fade,
      name: exerciseDetail,
      page: () => const ExerciseDetailScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: myWorkout,
      page: () => const MyWorkoutScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: statHistory,
      page: () {
        final argument = Get.arguments;
        final fallbackStat = HomeController().stats.first;

        return StatHistoryScreen(
          stat: argument is HomeStatItem ? argument : fallbackStat,
        );
      },
    ),
    GetPage(
      transition: Transition.fade,
      name: bodyHistory,
      page: () {
        final argument = Get.arguments;
        final fallbackMetric = HomeController().bodyMetrics.first;

        return BodyHistoryScreen(
          metric: argument is HomeBodyMetric ? argument : fallbackMetric,
        );
      },
    ),
    GetPage(
      transition: Transition.fade,
      name: dietPlan,
      page: () => const DietPlanScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: mealDetail,
      page: () {
        final argument = Get.arguments;
        final fallbackMeal = DietPlanController().dietPlans.first.meals.first;

        return MealDetailScreen(
          meal: argument is DietMeal ? argument : fallbackMeal,
        );
      },
    ),
    GetPage(
      transition: Transition.fade,
      name: personalInformation,
      page: () => const PersonalInformationScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: transactionHistory,
      page: () => const TransactionHistoryScreen(),
    ),
    GetPage(
      transition: Transition.fade,
      name: privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
    ),
  ];
}
