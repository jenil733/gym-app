class ApiRoutes {
  static const String baseUrl =
      'http://64.227.170.206/max_fitness.com/public/api';
  static const String signup = '/register';
  static const String verifyOtp = '/verify_otp';
  static const String resendOtp = '/resend_otp';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String updateProfile = '/update_profile';
  static const String category = '/categories';
  static String exercises(int categoryId) => '/exercises/$categoryId';
  static const String diet = '/diet_plans';
  static String dietByPlan(int planId) => '/diet_plans/$planId/meals';
  static String dietMeal(int mealId) => '/diet_meals/$mealId';
  static const String workoutHistory = '/workout_history';
  static const String height = '/log_height_weight';
  static const String weight = '/weight_history';
  static const String timing = '/log_workout';
  static const String gettiming = '/workout_history';
  static const String footstepHistory = '/footstep_history';
  static const String postFootstep = '/log_footstep';
  static const String postAttendance = '/mark_attendance';
  static const String attendanceHistory = '/attendance_history';
  static const String fcm = '/fcm_token';
}
