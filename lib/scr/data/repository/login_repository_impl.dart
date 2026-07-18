import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/api_services.dart';
import 'package:gym/scr/data/model/login_model.dart';
import 'package:gym/scr/domain/repository/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  const LoginRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<LoginModel> login(LoginParams params) async {
    final response = await _apiService.post(
      ApiRoutes.login,
      data: params.toJson(),
      isAuthRequest: true,
    );

    return LoginModel.fromJson(response);
  }
}
