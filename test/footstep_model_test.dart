import 'package:flutter_test/flutter_test.dart';
import 'package:gym/scr/data/model/footstep_history.dart';
import 'package:gym/scr/data/model/postfootstep_model.dart';

void main() {
  test('post footstep parses numeric steps and string status values', () {
    final model = PostFootstepModel.fromJson({
      'success': 1,
      'code': '201',
      'message': 'Saved',
      'data': {'date': '2026-07-21', 'steps': 1250},
    });

    expect(model.success, isTrue);
    expect(model.code, 201);
    expect(model.data?.steps, 1250);
  });

  test('footstep history parses numeric strings safely', () {
    final model = FootstepHistoryModel.fromJson({
      'success': 'true',
      'code': '200',
      'data': {
        'today_steps': '1250',
        'history': [
          {'label': 'Today', 'steps': '1250'},
        ],
      },
    });

    expect(model.success, isTrue);
    expect(model.data?.todaySteps, 1250);
    expect(model.data?.history?.single.steps, 1250);
  });
}
