import 'package:get/get.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/services/step_tracking_service.dart';
import 'package:gym/scr/core/services/weight_graph_storage.dart';
import 'package:gym/scr/data/repository/category_repository_impl.dart';
import 'package:gym/scr/data/repository/diet_repository_impl.dart';
import 'package:gym/scr/data/repository/diet_by_plan_repository_impl.dart';
import 'package:gym/scr/data/repository/diet_meal_repository_impl.dart';
import 'package:gym/scr/data/repository/exercise_repository_impl.dart';
import 'package:gym/scr/data/repository/height_weight_repository_impl.dart';
import 'package:gym/scr/data/repository/login_repository_impl.dart';
import 'package:gym/scr/data/repository/otp_repository_impl.dart';
import 'package:gym/scr/data/repository/packages_repository_impl.dart';
import 'package:gym/scr/data/repository/profile_repository_impl.dart';
import 'package:gym/scr/data/repository/signup_repository_impl.dart';
import 'package:gym/scr/data/repository/update_profile_repository_impl.dart';
import 'package:gym/scr/data/repository/weight_history_repository_impl.dart';
import 'package:gym/scr/data/repository/workout_history_repository_impl.dart';
import 'package:gym/scr/data/repository/workout_timing_repository_impl.dart';
import 'package:gym/scr/domain/repository/category_repository.dart';
import 'package:gym/scr/domain/repository/diet_repository.dart';
import 'package:gym/scr/domain/repository/diet_by_plan_repository.dart';
import 'package:gym/scr/domain/repository/diet_meal_repository.dart';
import 'package:gym/scr/domain/repository/exercise_repository.dart';
import 'package:gym/scr/domain/repository/height_weight_repository.dart';
import 'package:gym/scr/domain/repository/login_repository.dart';
import 'package:gym/scr/domain/repository/otp_repository.dart';
import 'package:gym/scr/domain/repository/packages_repository.dart';
import 'package:gym/scr/domain/repository/profile_repository.dart';
import 'package:gym/scr/domain/repository/signup_repository.dart';
import 'package:gym/scr/domain/repository/update_profile_repository.dart';
import 'package:gym/scr/domain/repository/weight_history_repository.dart';
import 'package:gym/scr/domain/repository/workout_history_repository.dart';
import 'package:gym/scr/domain/repository/workout_timing_repository.dart';
import 'package:gym/scr/domain/usecase/category_usecase.dart';
import 'package:gym/scr/domain/usecase/diet_usecase.dart';
import 'package:gym/scr/domain/usecase/diet_by_plan_usecase.dart';
import 'package:gym/scr/domain/usecase/diet_meal_usecase.dart';
import 'package:gym/scr/domain/usecase/exercise_usecase.dart';
import 'package:gym/scr/domain/usecase/height_weight_usecase.dart';
import 'package:gym/scr/domain/usecase/login_usecase.dart';
import 'package:gym/scr/domain/usecase/packages_usecase.dart';
import 'package:gym/scr/domain/usecase/profile_usecase.dart';
import 'package:gym/scr/domain/usecase/signup_usecase.dart';
import 'package:gym/scr/domain/usecase/update_profile_usecase.dart';
import 'package:gym/scr/domain/usecase/verify_otp_usecase.dart';
import 'package:gym/scr/domain/usecase/weight_history_usecase.dart';
import 'package:gym/scr/domain/usecase/workout_history_usecase.dart';
import 'package:gym/scr/domain/usecase/workout_timing_usecase.dart';
import 'package:gym/scr/presentation/controller/login_controller.dart';
import 'package:gym/scr/presentation/controller/diet_plan_controller.dart';
import 'package:gym/scr/presentation/controller/home_controller.dart';
import 'package:gym/scr/presentation/controller/otp_controller.dart';
import 'package:gym/scr/presentation/controller/plan_controller.dart';
import 'package:gym/scr/presentation/controller/profile_controller.dart';
import 'package:gym/scr/presentation/controller/progress_controller.dart';
import 'package:gym/scr/presentation/controller/sign_up_controller.dart';
import 'package:gym/scr/presentation/controller/workout_controller.dart';

class ServiceLocator {
  static void init() {
    Get.lazyPut<ApiService>(ApiService.new, fenix: true);
    Get.lazyPut<LocalStorageService>(LocalStorageService.new, fenix: true);
    Get.lazyPut<StepTrackingService>(
      () => StepTrackingService(Get.find<LocalStorageService>()),
      fenix: true,
    );
    Get.lazyPut<WeightGraphStorage>(
      () => WeightGraphStorage(Get.find<LocalStorageService>()),
      fenix: true,
    );
    Get.lazyPut<DietRepository>(
      () => DietRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<DietUseCase>(
      () => DietUseCase(Get.find<DietRepository>()),
      fenix: true,
    );
    Get.lazyPut<DietByPlanRepository>(
      () => DietByPlanRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<DietByPlanUseCase>(
      () => DietByPlanUseCase(Get.find<DietByPlanRepository>()),
      fenix: true,
    );
    Get.lazyPut<DietMealRepository>(
      () => DietMealRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<DietMealUseCase>(
      () => DietMealUseCase(Get.find<DietMealRepository>()),
      fenix: true,
    );
    Get.lazyPut<DietPlanController>(
      () => DietPlanController(
        Get.find<DietUseCase>(),
        Get.find<DietByPlanUseCase>(),
        Get.find<DietMealUseCase>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CategoryUseCase>(
      () => CategoryUseCase(Get.find<CategoryRepository>()),
      fenix: true,
    );
    Get.lazyPut<ExerciseRepository>(
      () => ExerciseRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<ExerciseUseCase>(
      () => ExerciseUseCase(Get.find<ExerciseRepository>()),
      fenix: true,
    );
    Get.lazyPut<WorkoutTimingRepository>(
      () => WorkoutTimingRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<WorkoutTimingUseCase>(
      () => WorkoutTimingUseCase(Get.find<WorkoutTimingRepository>()),
      fenix: true,
    );
    Get.put<WorkoutController>(
      WorkoutController(
        Get.find<CategoryUseCase>(),
        Get.find<ExerciseUseCase>(),
        Get.find<WorkoutTimingUseCase>(),
      ),
      permanent: true,
    );
    Get.lazyPut<LoginRepository>(
      () => LoginRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(Get.find<LoginRepository>()),
      fenix: true,
    );
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<LoginUseCase>()),
      fenix: true,
    );
    Get.lazyPut<SignupRepository>(
      () => SignupRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<SignupUseCase>(
      () => SignupUseCase(Get.find<SignupRepository>()),
      fenix: true,
    );
    Get.lazyPut<SignUpController>(
      () => SignUpController(Get.find<SignupUseCase>()),
      fenix: true,
    );
    Get.lazyPut<OtpRepository>(
      () => OtpRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<VerifyOtpUseCase>(
      () => VerifyOtpUseCase(Get.find<OtpRepository>()),
      fenix: true,
    );
    Get.lazyPut<OtpController>(
      () => OtpController(
        Get.find<VerifyOtpUseCase>(),
        Get.find<LocalStorageService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<ProfileUseCase>(
      () => ProfileUseCase(Get.find<ProfileRepository>()),
      fenix: true,
    );
    Get.lazyPut<UpdateProfileRepository>(
      () => UpdateProfileRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(Get.find<UpdateProfileRepository>()),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<ProfileUseCase>(),
        Get.find<UpdateProfileUseCase>(),
        Get.find<HeightWeightUseCase>(),
        Get.find<WeightGraphStorage>(),
        Get.find<LocalStorageService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<PackagesRepository>(
      () => PackagesRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<PackagesUseCase>(
      () => PackagesUseCase(Get.find<PackagesRepository>()),
      fenix: true,
    );
    Get.lazyPut<PlanController>(
      () => PlanController(Get.find<PackagesUseCase>()),
      fenix: true,
    );
    Get.lazyPut<WorkoutHistoryRepository>(
      () => WorkoutHistoryRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<WorkoutHistoryUseCase>(
      () => WorkoutHistoryUseCase(Get.find<WorkoutHistoryRepository>()),
      fenix: true,
    );
    Get.lazyPut<WeightHistoryRepository>(
      () => WeightHistoryRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<WeightHistoryUseCase>(
      () => WeightHistoryUseCase(Get.find<WeightHistoryRepository>()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<WorkoutHistoryUseCase>(),
        Get.find<WeightHistoryUseCase>(),
        Get.find<StepTrackingService>(),
        Get.find<ProfileUseCase>(),
        Get.find<WorkoutTimingUseCase>(),
      ),
      fenix: true,
    );
    Get.lazyPut<HeightWeightRepository>(
      () => HeightWeightRepositoryImpl(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<HeightWeightUseCase>(
      () => HeightWeightUseCase(Get.find<HeightWeightRepository>()),
      fenix: true,
    );
    Get.lazyPut<ProgressController>(
      () => ProgressController(
        Get.find<HeightWeightUseCase>(),
        Get.find<WeightHistoryUseCase>(),
        Get.find<WeightGraphStorage>(),
      ),
      fenix: true,
    );
  }
}
