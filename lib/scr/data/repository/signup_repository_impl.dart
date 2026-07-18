import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/signup_model.dart';
import 'package:gym/scr/domain/repository/signup_repository.dart';

class SignupRepositoryImpl implements SignupRepository {
  const SignupRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<SignupModel> signup(SignupParams params) async {
    final response = await _apiService.post(
      ApiRoutes.signup,
      data: params.toJson(),
      isAuthRequest: true,
    );

    return SignupModel.fromJson(response);
  }
}
