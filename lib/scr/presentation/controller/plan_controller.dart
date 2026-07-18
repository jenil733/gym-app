import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/data/model/packages_model.dart';
import 'package:gym/scr/presentation/controller/transaction_controller.dart';
import 'package:gym/scr/domain/usecase/packages_usecase.dart';

class PlanController extends GetxController {
  PlanController([this._packagesUseCase]);

  final PackagesUseCase? _packagesUseCase;

  final RxInt selectedPlanIndex = 0.obs;
  final RxInt selectedPaymentIndex = 0.obs;
  final RxBool isPackagesLoading = false.obs;
  final RxnString packagesError = RxnString();
  final RxList<PackageItem> apiPackages = <PackageItem>[].obs;

  static const List<PlanOption> _fallbackPlans = [
    PlanOption(
      title: 'Monthly',
      price: 'INR 799',
      period: 'per month',
      badge: 'Flexible',
      benefits: ['Unlimited workouts', 'Diet tracking', 'Water reminders'],
    ),
    PlanOption(
      title: 'Yearly',
      price: 'INR 6,999',
      period: 'per year',
      badge: 'Save 27%',
      benefits: [
        'Everything monthly',
        'Trainer discount',
        'Reward token boosts',
      ],
    ),
  ];

  List<PlanOption> get plans {
    if (_useCase == null) {
      return _fallbackPlans;
    }

    return apiPackages.map(_mapPackage).toList(growable: false);
  }

  final List<String> paymentMethods = const ['Card', 'UPI', 'Wallet'];

  static PlanController resolve() {
    if (Get.isRegistered<PlanController>()) {
      return Get.find<PlanController>();
    }

    PackagesUseCase? useCase;
    try {
      useCase = Get.find<PackagesUseCase>();
    } catch (_) {
      useCase = null;
    }

    return Get.put(PlanController(useCase));
  }

  PackagesUseCase? get _useCase {
    if (_packagesUseCase != null) {
      return _packagesUseCase;
    }
    try {
      return Get.find<PackagesUseCase>();
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getPackages();
  }

  Future<void> getPackages() async {
    final useCase = _useCase;
    if (useCase == null || isPackagesLoading.value) {
      return;
    }

    isPackagesLoading.value = true;
    packagesError.value = null;

    try {
      final response = await useCase();
      final isSuccessful = response.success == true || response.code == 200;

      if (!isSuccessful || response.data == null) {
        packagesError.value = response.message ?? 'Unable to load packages.';
        return;
      }

      apiPackages.assignAll(response.data!.packages);
      selectedPlanIndex.value = 0;
    } on DioException catch (error) {
      final responseData = error.response?.data;
      packagesError.value =
          responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load packages. Please check your connection.';
    } catch (_) {
      packagesError.value = 'Something went wrong while loading packages.';
    } finally {
      isPackagesLoading.value = false;
    }
  }

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  void selectPaymentMethod(int index) {
    selectedPaymentIndex.value = index;
  }

  void payNow() {
    if (plans.isEmpty) {
      return;
    }
    final plan = plans[selectedPlanIndex.value];
    final paymentMethod = paymentMethods[selectedPaymentIndex.value];

    TransactionController.findOrCreate().recordPayment(
      plan: plan.title,
      amount: plan.price,
      paymentMethod: paymentMethod,
    );

    ToastHelper.success(
      'Payment completed',
      '${plan.title} plan purchased with $paymentMethod.',
    );
  }

  PlanOption _mapPackage(PackageItem item) {
    final months = item.durationMonths;
    final duration = item.duration?.trim();
    final displayPrice = item.price?.trim().isNotEmpty == true
        ? item.price!.trim()
        : item.priceRaw?.trim().isNotEmpty == true
        ? item.priceRaw!.trim()
        : 'Price unavailable';

    return PlanOption(
      id: item.id,
      title: item.packageName?.trim().isNotEmpty == true
          ? item.packageName!.trim()
          : 'Membership',
      price: displayPrice,
      period: months == null
          ? duration ?? ''
          : months == 1
          ? 'per month'
          : 'for $months months',
      badge: duration?.isNotEmpty == true ? duration! : 'Membership',
      benefits: item.features.isNotEmpty
          ? item.features
          : const ['Gym membership access'],
    );
  }
}

class PlanOption {
  const PlanOption({
    this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.badge,
    required this.benefits,
  });

  final int? id;
  final String title;
  final String price;
  final String period;
  final String badge;
  final List<String> benefits;
}
