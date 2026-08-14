import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gym/scr/data/model/post_attendance_model.dart';
import 'package:gym/scr/data/model/get_attendance_model.dart';
import 'package:gym/scr/domain/repository/attendance_repository.dart';
import 'package:gym/scr/domain/usecase/attendance_usecase.dart';
import 'package:gym/scr/presentation/controller/attendance_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('scanned QR is submitted and successful attendance is stored', () async {
    final repository = _FakeAttendanceRepository();
    final controller = AttendanceController(AttendanceUseCase(repository));

    await controller.submitQr('  gym-qr-123  ');

    expect(repository.lastQrCode, 'gym-qr-123');
    expect(controller.isSubmitting.value, isFalse);
    expect(controller.latestAttendance.value?.date, '2026-07-21');
    expect(controller.todayMarked, isTrue);
    expect(controller.history.single.label, 'Today');
  });

  test('current streak restarts after one absent day', () {
    final controller = AttendanceController();
    controller.attendance.value = const AttendanceData(
      todayMarked: true,
      history: [
        AttendanceHistory(date: '2026-07-20', status: 'Present'),
        AttendanceHistory(date: '2026-07-21', status: 'Absent'),
        AttendanceHistory(date: '2026-07-22', status: 'Present'),
        AttendanceHistory(date: '2026-07-23', status: 'Present'),
      ],
    );

    expect(controller.currentStreak(now: DateTime(2026, 7, 23)), 2);
  });

  test('week uses ticks, crosses, fire, and upcoming states', () {
    final controller = AttendanceController();
    controller.attendance.value = const AttendanceData(
      todayMarked: false,
      history: [
        AttendanceHistory(date: '2026-07-20', status: 'Present'),
        AttendanceHistory(date: '2026-07-21', status: 'Absent'),
      ],
    );

    final week = controller.currentWeek(now: DateTime(2026, 7, 22));

    expect(week.map((day) => day.state), [
      AttendanceDayState.completed,
      AttendanceDayState.absent,
      AttendanceDayState.active,
      AttendanceDayState.upcoming,
      AttendanceDayState.upcoming,
      AttendanceDayState.upcoming,
      AttendanceDayState.upcoming,
    ]);
  });
}

class _FakeAttendanceRepository implements AttendanceRepository {
  String? lastQrCode;

  @override
  Future<PostAttendanceModel> postAttendance(String qrCode) async {
    lastQrCode = qrCode;
    return const PostAttendanceModel(
      success: true,
      code: 200,
      message: 'Attendance marked',
      data: PostAttendanceData(date: '2026-07-21', steps: '0'),
    );
  }

  @override
  Future<GetAttendanceModel> getAttendance() async {
    return const GetAttendanceModel(
      success: true,
      code: 200,
      data: AttendanceData(
        todayMarked: true,
        totalAttendance: 1,
        history: [
          AttendanceHistory(
            label: 'Today',
            status: 'Present',
            checkInTime: '07:12 AM',
            date: '2026-07-21',
          ),
        ],
      ),
    );
  }
}
