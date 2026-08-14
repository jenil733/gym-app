import 'package:gym/scr/data/model/get_attendance_model.dart';
import 'package:gym/scr/data/model/post_attendance_model.dart';

abstract class AttendanceRepository {
  Future<PostAttendanceModel> postAttendance(String qrCode);

  Future<GetAttendanceModel> getAttendance();
}
