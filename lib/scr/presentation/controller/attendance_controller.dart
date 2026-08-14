import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/data/model/get_attendance_model.dart';
import 'package:gym/scr/data/model/post_attendance_model.dart';
import 'package:gym/scr/domain/usecase/attendance_usecase.dart';

enum AttendanceDayState { completed, absent, active, upcoming }

class AttendanceStreakDay {
  const AttendanceStreakDay({
    required this.label,
    required this.date,
    required this.state,
  });

  final String label;
  final DateTime date;
  final AttendanceDayState state;
}

class AttendanceController extends GetxController {
  AttendanceController([this._attendanceUseCase]);

  final AttendanceUseCase? _attendanceUseCase;

  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxnString historyError = RxnString();
  final Rxn<PostAttendanceData> latestAttendance = Rxn<PostAttendanceData>();
  final Rxn<AttendanceData> attendance = Rxn<AttendanceData>();

  List<AttendanceHistory> get history => attendance.value?.history ?? const [];
  bool get todayMarked =>
      attendance.value?.todayMarked == true || latestAttendance.value != null;

  int currentStreak({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final completedDates = _completedDateKeys(today);
    final absentDates = _absentDateKeys();
    final todayKey = _dateKey(today);

    if (absentDates.contains(todayKey)) {
      return 0;
    }

    var cursor = completedDates.contains(todayKey)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (completedDates.contains(_dateKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<AttendanceStreakDay> currentWeek({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final completedDates = _completedDateKeys(today);
    final absentDates = _absentDateKeys();
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return List<AttendanceStreakDay>.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final key = _dateKey(date);
      final state = completedDates.contains(key)
          ? AttendanceDayState.completed
          : absentDates.contains(key) || date.isBefore(today)
          ? AttendanceDayState.absent
          : date == today
          ? AttendanceDayState.active
          : AttendanceDayState.upcoming;
      return AttendanceStreakDay(
        label: labels[index],
        date: date,
        state: state,
      );
    }, growable: false);
  }

  Set<String> _completedDateKeys(DateTime today) {
    final dates = <String>{};
    for (final item in history) {
      final date = _parseDate(item.date);
      if (date != null && _isCompletedStatus(item.status)) {
        dates.add(_dateKey(date));
      }
    }

    final latestDate = _parseDate(latestAttendance.value?.date);
    if (latestDate != null) {
      dates.add(_dateKey(latestDate));
    }
    if (todayMarked) {
      dates.add(_dateKey(today));
    }
    return dates;
  }

  Set<String> _absentDateKeys() {
    final dates = <String>{};
    for (final item in history) {
      final date = _parseDate(item.date);
      if (date != null && _isAbsentStatus(item.status)) {
        dates.add(_dateKey(date));
      }
    }
    return dates;
  }

  bool _isCompletedStatus(String? status) {
    final value = status?.trim().toLowerCase() ?? '';
    return value.isEmpty ||
        value == 'present' ||
        value == 'marked' ||
        value == 'completed' ||
        value == 'attended';
  }

  bool _isAbsentStatus(String? status) {
    final value = status?.trim().toLowerCase() ?? '';
    return value == 'absent' || value == 'missed' || value == 'not present';
  }

  DateTime? _parseDate(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    final datePart = RegExp(r'^\d{4}-\d{2}-\d{2}').stringMatch(normalized);
    final parsed = DateTime.tryParse(datePart ?? normalized);
    return parsed == null ? null : _dateOnly(parsed);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _dateKey(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static AttendanceController resolve() {
    if (Get.isRegistered<AttendanceController>()) {
      return Get.find<AttendanceController>();
    }
    final useCase = Get.isRegistered<AttendanceUseCase>()
        ? Get.find<AttendanceUseCase>()
        : null;
    return Get.put(AttendanceController(useCase));
  }

  @override
  void onInit() {
    super.onInit();
    getAttendance();
  }

  Future<void> getAttendance({bool showError = true}) async {
    final useCase = _attendanceUseCase;
    if (useCase == null || isLoadingHistory.value) {
      return;
    }

    isLoadingHistory.value = true;
    historyError.value = null;
    try {
      final response = await useCase.getAttendance();
      final isSuccessful = response.success == true || response.code == 200;
      if (!isSuccessful || response.data == null) {
        final message = response.message ?? 'Unable to load attendance.';
        historyError.value = message;
        if (showError) {
          ToastHelper.error('Attendance', message);
        }
        return;
      }
      attendance.value = response.data;
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final message = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Unable to load attendance. Please check your connection.';
      historyError.value = message;
      if (showError) {
        ToastHelper.error('Attendance', message);
      }
    } catch (_) {
      const message = 'Something went wrong while loading attendance.';
      historyError.value = message;
      if (showError) {
        ToastHelper.error('Attendance', message);
      }
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> submitQr(String qrCode) async {
    final value = qrCode.trim();
    if (value.isEmpty || isSubmitting.value) {
      return;
    }

    final useCase = _attendanceUseCase;
    if (useCase == null) {
      ToastHelper.error('Attendance', 'Attendance service is unavailable.');
      return;
    }

    isSubmitting.value = true;
    try {
      final response = await useCase(value);
      final isSuccessful =
          response.success == true ||
          response.code == 200 ||
          response.code == 201;
      if (!isSuccessful) {
        ToastHelper.error(
          'Attendance',
          response.message ?? 'Unable to mark attendance.',
        );
        return;
      }

      latestAttendance.value = response.data;
      await getAttendance(showError: false);
      ToastHelper.success(
        'Attendance marked',
        response.message ?? 'Your attendance was recorded successfully.',
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;
      ToastHelper.error(
        'Attendance',
        responseData is Map && responseData['message'] != null
            ? responseData['message'].toString()
            : 'Unable to mark attendance. Please check your connection.',
      );
    } catch (_) {
      ToastHelper.error(
        'Attendance',
        'Something went wrong while marking attendance.',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
