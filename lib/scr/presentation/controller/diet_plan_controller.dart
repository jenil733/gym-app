import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/data/model/diet_by_plan_model.dart';
import 'package:gym/scr/data/model/diet_meal_model.dart';
import 'package:gym/scr/data/model/diet_model.dart';
import 'package:gym/scr/domain/usecase/diet_by_plan_usecase.dart';
import 'package:gym/scr/domain/usecase/diet_meal_usecase.dart';
import 'package:gym/scr/domain/usecase/diet_usecase.dart';

class DietPlanController extends GetxController {
  DietPlanController([
    this._dietUseCase,
    this._dietByPlanUseCase,
    this._dietMealUseCase,
  ]);

  final DietUseCase? _dietUseCase;
  final DietByPlanUseCase? _dietByPlanUseCase;
  final DietMealUseCase? _dietMealUseCase;

  final RxList<DietPlan> apiDietPlans = <DietPlan>[].obs;
  final RxList<DietMealItem> apiMeals = <DietMealItem>[].obs;
  final Rxn<DietByPlanData> selectedPlanData = Rxn<DietByPlanData>();
  final RxBool isDietPlanLoading = false.obs;
  final RxBool isMealLoading = false.obs;
  final RxBool isMealDetailLoading = false.obs;
  final RxnString dietPlanError = RxnString();
  final RxnString mealError = RxnString();
  final RxnString mealDetailError = RxnString();
  final Rxn<DietMealData> selectedMealDetail = Rxn<DietMealData>();
  final RxInt selectedApiDietIndex = 0.obs;
  final RxInt selectedDietIndex = 0.obs;
  int _mealRequestId = 0;

  static DietPlanController resolve() {
    if (Get.isRegistered<DietPlanController>()) {
      return Get.find<DietPlanController>();
    }

    DietUseCase? useCase;
    DietByPlanUseCase? byPlanUseCase;
    DietMealUseCase? mealUseCase;
    try {
      useCase = Get.find<DietUseCase>();
    } catch (_) {
      useCase = null;
    }

    try {
      byPlanUseCase = Get.find<DietByPlanUseCase>();
    } catch (_) {
      byPlanUseCase = null;
    }

    try {
      mealUseCase = Get.find<DietMealUseCase>();
    } catch (_) {
      mealUseCase = null;
    }

    return Get.put(DietPlanController(useCase, byPlanUseCase, mealUseCase));
  }

  DietMealUseCase? get _mealDetailUseCase {
    if (_dietMealUseCase != null) {
      return _dietMealUseCase;
    }
    try {
      return Get.find<DietMealUseCase>();
    } catch (_) {
      return null;
    }
  }

  DietByPlanUseCase? get _byPlanUseCase {
    if (_dietByPlanUseCase != null) {
      return _dietByPlanUseCase;
    }
    try {
      return Get.find<DietByPlanUseCase>();
    } catch (_) {
      return null;
    }
  }

  DietUseCase? get _useCase {
    if (_dietUseCase != null) {
      return _dietUseCase;
    }
    try {
      return Get.find<DietUseCase>();
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getDietPlans();
  }

  Future<void> getDietPlans() async {
    final useCase = _useCase;
    if (isDietPlanLoading.value) {
      return;
    }
    if (useCase == null) {
      dietPlanError.value = 'Diet plan service is unavailable.';
      return;
    }

    isDietPlanLoading.value = true;
    dietPlanError.value = null;

    try {
      final response = await useCase();
      final isSuccessful = response.success == true || response.code == 200;

      if (!isSuccessful || response.data == null) {
        dietPlanError.value = response.message ?? 'Unable to load diet plans.';
        return;
      }

      apiDietPlans.assignAll(response.data!.plans);
      if (apiDietPlans.isNotEmpty) {
        selectedApiDietIndex.value = 0;
        _syncSuggestedMeals(apiDietPlans.first);
        final planId = apiDietPlans.first.id;
        if (planId != null) {
          await getMealsByPlan(planId);
        }
      }
    } on DioException catch (error) {
      final responseData = error.response?.data;
      dietPlanError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load diet plans. Please check your connection.';
    } catch (_) {
      dietPlanError.value = 'Something went wrong while loading diet plans.';
    } finally {
      isDietPlanLoading.value = false;
    }
  }

  Future<void> getMealsByPlan(int planId) async {
    final useCase = _byPlanUseCase;
    if (useCase == null) {
      mealError.value = 'Diet meal service is unavailable.';
      return;
    }

    final requestId = ++_mealRequestId;
    isMealLoading.value = true;
    mealError.value = null;
    selectedPlanData.value = null;
    apiMeals.clear();

    try {
      final response = await useCase(planId);
      if (requestId != _mealRequestId) {
        return;
      }
      final isSuccessful = response.success == true || response.code == 200;

      if (!isSuccessful || response.data == null) {
        mealError.value = response.message ?? 'Unable to load meals.';
        return;
      }

      selectedPlanData.value = response.data;
      apiMeals.assignAll(response.data!.meals);
    } on DioException catch (error) {
      if (requestId != _mealRequestId) {
        return;
      }
      final responseData = error.response?.data;
      mealError.value = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load meals. Please check your connection.';
    } catch (_) {
      if (requestId != _mealRequestId) {
        return;
      }
      mealError.value = 'Something went wrong while loading meals.';
    } finally {
      if (requestId == _mealRequestId) {
        isMealLoading.value = false;
      }
    }
  }

  Future<DietMeal?> getMealDetail(int mealId) async {
    final useCase = _mealDetailUseCase;
    if (useCase == null) {
      mealDetailError.value = 'Diet meal detail service is unavailable.';
      return null;
    }

    isMealDetailLoading.value = true;
    mealDetailError.value = null;
    selectedMealDetail.value = null;

    try {
      final response = await useCase(mealId);
      final isSuccessful = response.success == true || response.code == 200;

      if (!isSuccessful || response.data == null) {
        mealDetailError.value =
            response.message ?? 'Unable to load meal details.';
        return null;
      }

      selectedMealDetail.value = response.data;
      return _mapMealDetail(response.data!);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      mealDetailError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load meal details. Please check your connection.';
      return null;
    } catch (_) {
      mealDetailError.value =
          'Something went wrong while loading meal details.';
      return null;
    } finally {
      isMealDetailLoading.value = false;
    }
  }

  final List<DietPlanData> dietPlans = const [
    DietPlanData(
      name: 'Weight Loss',
      icon: Icons.monitor_weight_rounded,
      meals: [
        DietMeal(
          mealType: 'Breakfast',
          title: 'Oatmeal with Fruits',
          calories: '400 kcal',
          protein: '16 g',
          description:
              'A filling bowl of oats topped with fresh fruits for steady energy, fiber, and a light protein boost to start the day.',
          icon: Icons.breakfast_dining_rounded,
          color: AppColors.secondary,
        ),
        DietMeal(
          mealType: 'Lunch',
          title: 'Grilled Chicken Salad',
          calories: '550 kcal',
          protein: '42 g',
          description:
              'Lean grilled chicken with crisp vegetables gives high protein, vitamins, and a balanced meal without feeling heavy.',
          icon: Icons.lunch_dining_rounded,
          color: AppColors.primary,
        ),
        DietMeal(
          mealType: 'Dinner',
          title: 'Salmon with Quinoa',
          calories: '450 kcal',
          protein: '34 g',
          description:
              'Salmon and quinoa combine quality protein, healthy fats, and slow-release carbs for a lighter recovery dinner.',
          icon: Icons.dinner_dining_rounded,
          color: AppColors.statWorkoutTime,
        ),
        DietMeal(
          mealType: 'Snack',
          title: 'Protein Shake',
          calories: '200 kcal',
          protein: '25 g',
          description:
              'A quick shake for muscle support between meals, keeping calories controlled while adding extra protein.',
          icon: Icons.local_drink_rounded,
          color: AppColors.statWater,
        ),
      ],
    ),
    DietPlanData(
      name: 'Muscle Gain',
      icon: Icons.fitness_center_rounded,
      meals: [
        DietMeal(
          mealType: 'Breakfast',
          title: 'Protein Smoothie',
          calories: '520 kcal',
          protein: '32 g',
          description:
              'A calorie-rich smoothie with protein, fruit, and dairy to support muscle gain and morning recovery.',
          icon: Icons.local_drink_rounded,
          color: AppColors.statWater,
        ),
        DietMeal(
          mealType: 'Lunch',
          title: 'Chicken Pasta Bowl',
          calories: '720 kcal',
          protein: '48 g',
          description:
              'Chicken and pasta provide a strong protein and carb mix for training days and muscle-building energy.',
          icon: Icons.set_meal_rounded,
          color: AppColors.statCalories,
        ),
        DietMeal(
          mealType: 'Dinner',
          title: 'Rice and Dal Combo',
          calories: '650 kcal',
          protein: '24 g',
          description:
              'Rice and dal make a comforting balanced plate with plant protein, carbs, and minerals for recovery.',
          icon: Icons.rice_bowl_rounded,
          color: AppColors.secondary,
        ),
        DietMeal(
          mealType: 'Snack',
          title: 'Greek Yogurt Bowl',
          calories: '300 kcal',
          protein: '22 g',
          description:
              'Greek yogurt with toppings adds creamy protein and a satisfying snack option between larger meals.',
          icon: Icons.icecream_rounded,
          color: AppColors.statWorkoutTime,
        ),
      ],
    ),
    DietPlanData(
      name: 'Keto Diet',
      icon: Icons.food_bank_rounded,
      meals: [
        DietMeal(
          mealType: 'Breakfast',
          title: 'Veg Omelette',
          calories: '420 kcal',
          protein: '28 g',
          description:
              'Eggs and vegetables keep carbs low while giving a protein-rich breakfast with healthy fats.',
          icon: Icons.egg_rounded,
          color: AppColors.statBodyFat,
        ),
        DietMeal(
          mealType: 'Lunch',
          title: 'Tandoori Bowl',
          calories: '560 kcal',
          protein: '40 g',
          description:
              'A spiced tandoori protein bowl with low-carb sides to keep the meal flavorful and keto-friendly.',
          icon: Icons.kebab_dining_rounded,
          color: AppColors.primary,
        ),
        DietMeal(
          mealType: 'Dinner',
          title: 'Protein Stir Fry',
          calories: '500 kcal',
          protein: '38 g',
          description:
              'Protein and vegetables cooked together for a low-carb dinner that still feels warm and filling.',
          icon: Icons.dinner_dining_rounded,
          color: AppColors.secondary,
        ),
        DietMeal(
          mealType: 'Snack',
          title: 'Avocado Bites',
          calories: '260 kcal',
          protein: '6 g',
          description:
              'Avocado bites add healthy fats and a small amount of protein for a light keto snack.',
          icon: Icons.eco_rounded,
          color: AppColors.statWater,
        ),
      ],
    ),
    DietPlanData(
      name: 'Maintenance',
      icon: Icons.track_changes_rounded,
      meals: [
        DietMeal(
          mealType: 'Breakfast',
          title: 'Egg Toast Plate',
          calories: '430 kcal',
          protein: '24 g',
          description:
              'Eggs and toast create an easy balanced breakfast with protein, carbs, and steady morning energy.',
          icon: Icons.egg_alt_rounded,
          color: AppColors.statWorkoutTime,
        ),
        DietMeal(
          mealType: 'Lunch',
          title: 'Paneer Veg Plate',
          calories: '600 kcal',
          protein: '30 g',
          description:
              'Paneer with vegetables gives a balanced vegetarian plate with protein, fats, and micronutrients.',
          icon: Icons.restaurant_rounded,
          color: AppColors.primary,
        ),
        DietMeal(
          mealType: 'Dinner',
          title: 'Rice Bowl',
          calories: '520 kcal',
          protein: '18 g',
          description:
              'A simple rice bowl for maintenance calories, pairing carbs with enough protein for daily balance.',
          icon: Icons.dinner_dining_rounded,
          color: AppColors.statCalories,
        ),
        DietMeal(
          mealType: 'Snack',
          title: 'Fruit and Nuts',
          calories: '240 kcal',
          protein: '8 g',
          description:
              'Fruit and nuts bring natural sweetness, healthy fats, and a small protein boost for a light snack.',
          icon: Icons.breakfast_dining_rounded,
          color: AppColors.statWater,
        ),
      ],
    ),
  ];

  DietPlanData get selectedDiet => dietPlans[selectedDietIndex.value];

  DietPlan? get selectedApiDietPlan {
    if (apiDietPlans.isEmpty ||
        selectedApiDietIndex.value >= apiDietPlans.length) {
      return null;
    }
    return apiDietPlans[selectedApiDietIndex.value];
  }

  Future<void> selectApiDietPlan(int index) async {
    if (index < 0 || index >= apiDietPlans.length) {
      return;
    }
    selectedApiDietIndex.value = index;
    _syncSuggestedMeals(apiDietPlans[index]);
    final planId = apiDietPlans[index].id;
    if (planId != null) {
      await getMealsByPlan(planId);
    }
  }

  Future<void> retryMeals() async {
    final planId = selectedApiDietPlan?.id;
    if (planId != null) {
      await getMealsByPlan(planId);
    }
  }

  List<DietMeal> get selectedMeals {
    return apiMeals.map(_mapApiMeal).toList(growable: false);
  }

  DietMeal _mapApiMeal(DietMealItem meal) {
    final type = meal.mealType?.trim() ?? 'Meal';
    final normalizedType = type.toLowerCase();
    final icon = normalizedType.contains('breakfast')
        ? Icons.breakfast_dining_rounded
        : normalizedType.contains('dinner')
        ? Icons.dinner_dining_rounded
        : normalizedType.contains('snack')
        ? Icons.local_dining_rounded
        : Icons.lunch_dining_rounded;

    return DietMeal(
      id: meal.id,
      mealType: type,
      title: meal.foodName?.trim().isNotEmpty == true
          ? meal.foodName!.trim()
          : 'Meal',
      calories: '${meal.calories ?? 0} kcal',
      protein: '${meal.protein ?? 0} g',
      description: meal.description?.trim().isNotEmpty == true
          ? meal.description!.trim()
          : 'Description is not available for this meal.',
      icon: icon,
      color: AppColors.primary,
      imageUrl: meal.image,
    );
  }

  DietMeal _mapMealDetail(DietMealData meal) {
    final type = meal.mealType?.trim() ?? 'Meal';
    final normalizedType = type.toLowerCase();
    final icon = normalizedType.contains('breakfast')
        ? Icons.breakfast_dining_rounded
        : normalizedType.contains('dinner')
        ? Icons.dinner_dining_rounded
        : normalizedType.contains('snack')
        ? Icons.local_dining_rounded
        : Icons.lunch_dining_rounded;

    return DietMeal(
      id: meal.id,
      mealType: type,
      title: meal.foodName?.trim().isNotEmpty == true
          ? meal.foodName!.trim()
          : 'Meal',
      calories: '${meal.calories ?? 0} kcal',
      protein: '${meal.protein ?? 0} g',
      description: meal.description?.trim().isNotEmpty == true
          ? meal.description!.trim()
          : 'Description is not available for this meal.',
      icon: icon,
      color: AppColors.primary,
      imageUrl: meal.image,
    );
  }

  void _syncSuggestedMeals(DietPlan plan) {
    final name = plan.planName?.toLowerCase() ?? '';
    if (name.contains('gain') || name.contains('muscle')) {
      selectedDietIndex.value = 1;
    } else if (name.contains('keto')) {
      selectedDietIndex.value = 2;
    } else if (name.contains('maintain')) {
      selectedDietIndex.value = 3;
    } else {
      selectedDietIndex.value = 0;
    }
  }

  void selectDiet(int index) {
    selectedDietIndex.value = index;
  }
}

class DietPlanData {
  const DietPlanData({
    required this.name,
    required this.icon,
    required this.meals,
  });

  final String name;
  final IconData icon;
  final List<DietMeal> meals;
}

class DietMeal {
  const DietMeal({
    this.id,
    required this.mealType,
    required this.title,
    required this.calories,
    required this.protein,
    required this.description,
    required this.icon,
    required this.color,
    this.imageAsset,
    this.imageUrl,
  });

  final int? id;
  final String mealType;
  final String title;
  final String calories;
  final String protein;
  final String description;
  final IconData icon;
  final Color color;
  final String? imageAsset;
  final String? imageUrl;
}
