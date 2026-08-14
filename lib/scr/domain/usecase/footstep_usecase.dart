import 'package:gym/scr/data/model/footstep_history.dart';
import 'package:gym/scr/data/model/postfootstep_model.dart';
import 'package:gym/scr/domain/repository/footstep_repository.dart';

class FootstepUseCase {
  const FootstepUseCase(this._repository);

  final FootstepRepository _repository;

  Future<PostFootstepModel> postFootstep(int steps) =>
      _repository.postFootstep(steps);

  Future<FootstepHistoryModel> getHistory() => _repository.getFootstepHistory();
}
