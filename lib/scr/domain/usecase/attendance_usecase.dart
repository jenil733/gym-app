import 'package:gym/scr/data/model/get_attendance_model.dart';
import 'package:gym/scr/data/model/post_attendance_model.dart';
import 'package:gym/scr/domain/repository/attendance_repository.dart';

class AttendanceUseCase {
  const AttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<PostAttendanceModel> call(String qrCode) =>
      _repository.postAttendance(qrCode);

  Future<GetAttendanceModel> getAttendance() => _repository.getAttendance();
}
