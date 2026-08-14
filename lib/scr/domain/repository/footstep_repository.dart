import 'package:gym/scr/data/model/footstep_history.dart';
import 'package:gym/scr/data/model/postfootstep_model.dart';

abstract class FootstepRepository {
  Future<PostFootstepModel> postFootstep(int steps);

  Future<FootstepHistoryModel> getFootstepHistory();
}
