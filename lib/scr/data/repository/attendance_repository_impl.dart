import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/get_attendance_model.dart';
import 'package:gym/scr/data/model/post_attendance_model.dart';
import 'package:gym/scr/domain/repository/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<PostAttendanceModel> postAttendance(String qrCode) async {
    final response = await _apiService.post(
      ApiRoutes.postAttendance,
      data: {'qr_code': qrCode},
    );
    return PostAttendanceModel.fromJson(response);
  }

  @override
  Future<GetAttendanceModel> getAttendance() async {
    final response = await _apiService.get(ApiRoutes.attendanceHistory);
    return GetAttendanceModel.fromJson(response);
  }
}
