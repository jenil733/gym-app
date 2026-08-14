class GetAttendanceModel {
  const GetAttendanceModel({this.success, this.data, this.message, this.code});

  factory GetAttendanceModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return GetAttendanceModel(
      success: json['success'] as bool?,
      data: rawData is Map
          ? AttendanceData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
      message: json['message']?.toString(),
      code: int.tryParse(json['code']?.toString() ?? ''),
    );
  }

  final bool? success;
  final AttendanceData? data;
  final String? message;
  final int? code;

  Map<String, dynamic> toJson() => {
    'success': success,
    if (data != null) 'data': data!.toJson(),
    'message': message,
    'code': code,
  };
}

class AttendanceData {
  const AttendanceData({
    this.todayMarked,
    this.totalAttendance,
    this.history = const [],
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];
    return AttendanceData(
      todayMarked:
          json['today_marked'] == true ||
          json['today_marked']?.toString() == '1',
      totalAttendance: int.tryParse(json['total_attendance']?.toString() ?? ''),
      history: rawHistory is List
          ? rawHistory
                .whereType<Map>()
                .map(
                  (item) => AttendanceHistory.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final bool? todayMarked;
  final int? totalAttendance;
  final List<AttendanceHistory> history;

  Map<String, dynamic> toJson() => {
    'today_marked': todayMarked,
    'total_attendance': totalAttendance,
    'history': history.map((item) => item.toJson()).toList(growable: false),
  };
}

class AttendanceHistory {
  const AttendanceHistory({
    this.label,
    this.status,
    this.checkInTime,
    this.date,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      label: json['label']?.toString(),
      status: json['status']?.toString(),
      checkInTime: json['check_in_time']?.toString(),
      date: json['date']?.toString(),
    );
  }

  final String? label;
  final String? status;
  final String? checkInTime;
  final String? date;

  Map<String, dynamic> toJson() => {
    'label': label,
    'status': status,
    'check_in_time': checkInTime,
    'date': date,
  };
}
