import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as g;
import 'package:gym/scr/core/constants/api_routes.dart';
import 'package:gym/scr/core/services/local_storage.dart';
import 'package:gym/scr/core/utils/helper/toast_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';

class ApiService {
  final Dio _dio;
  final _storage = LocalStorageService();

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiRoutes.baseUrl,
          contentType: 'application/json',
          headers: {
            "Accept": "application/json",
            "x-api-key": "dcfvbncvbnmcvbnmdfghjkjhbvxcvbnmsxc",
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _storage.init();
          final isAuthRequest = options.extra['isAuthRequest'] == true;
          if (!isAuthRequest) {
            final token = _storage.getString("auth_token")?.trim();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
              options.extra['authTokenUsed'] = token;
            }
          }
          if (kDebugMode) {
            _logRequest(options);
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            _logResponse(response);
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final statusCode = e.response?.statusCode;
          final isAuthRequest = e.requestOptions.extra['isAuthRequest'] == true;
          final suppressErrorToast =
              e.requestOptions.extra['suppressErrorToast'] == true;
          final responseData = e.response?.data;
          final errorMessage =
              responseData is Map && responseData['message'] != null
              ? responseData['message']
              : (e.message ?? "Something went wrong");
          final isRouteMissing =
              statusCode == 404 &&
              errorMessage.toString().toLowerCase().contains(
                "could not be found",
              );

          if (kDebugMode && !isRouteMissing) {
            log(
              "ERROR ${e.requestOptions.method} ${e.requestOptions.uri}",
              name: "API",
            );
            log("Status: ${e.response?.statusCode}", name: "API");
            log("Error: ${e.response?.data ?? e.message}", name: "API");
          }

          if (statusCode == 401 && !isAuthRequest) {
            final failedToken = e.requestOptions.extra['authTokenUsed']
                ?.toString()
                .trim();
            final currentToken = _storage.getString('auth_token')?.trim();
            if (failedToken != null &&
                failedToken.isNotEmpty &&
                failedToken == currentToken) {
              _handleUnauthorized();
            }
          } else if (!isRouteMissing && !isAuthRequest && !suppressErrorToast) {
            ToastHelper.error('Error', errorMessage.toString());
          }

          return handler.next(e);
        },
      ),
    );
  }

  void _logRequest(RequestOptions options) {
    log("REQUEST ${options.method} ${options.uri}", name: "API");
    log("Headers: ${options.headers}", name: "API");
    log("Query: ${options.queryParameters}", name: "API");
    log("Body: ${_formatBody(options.data)}", name: "API");
  }

  void _logResponse(Response response) {
    if (_isExpectedEmptyResponse(response.data)) {
      return;
    }

    log(
      "RESPONSE ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}",
      name: "API",
    );
    log("Response: ${_formatBody(response.data)}", name: "API");
  }

  bool _isExpectedEmptyResponse(dynamic data) {
    if (data is! Map) {
      return false;
    }

    final code = int.tryParse(data['code']?.toString() ?? '');
    final message = data['message']?.toString().toLowerCase() ?? '';
    final responseData = data['data'];
    final isEmptyData =
        responseData == null ||
        (responseData is List && responseData.isEmpty) ||
        (responseData is Map && responseData.isEmpty);

    return code == 404 &&
        isEmptyData &&
        (message.contains('not found') || message.contains('no '));
  }

  String _formatBody(dynamic body) {
    if (body == null) {
      return "null";
    }

    if (body is FormData) {
      final fields = <String, dynamic>{};
      for (final field in body.fields) {
        fields[field.key] = field.value;
      }

      final files = <String, String>{};
      for (final file in body.files) {
        files[file.key] = file.value.filename ?? "file";
      }

      return "FormData(fields: $fields, files: $files)";
    }

    return body.toString();
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    bool isAuthRequest = false,
  }) async {
    return _handleResponse(
      () => _dio.post(
        endpoint,
        data: data,
        options: Options(
          contentType: data is FormData
              ? 'multipart/form-data'
              : 'application/json',
          extra: {'isAuthRequest': isAuthRequest},
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    return _handleResponse(() => _dio.get(endpoint, queryParameters: params));
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    bool useFormData = false,
  }) async {
    return _handleResponse(
      () => _dio.put(
        endpoint,
        data: useFormData && data is Map
            ? FormData.fromMap(Map<String, dynamic>.from(data))
            : data,
        options: Options(
          contentType: useFormData ? 'multipart/form-data' : 'application/json',
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    return _handleResponse(() => _dio.delete(endpoint, data: data));
  }

  Future<String> downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
    return savePath;
  }

  Future<Map<String, dynamic>> _handleResponse(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();

      if (response.data is Map) {
        return Map<String, dynamic>.from(
          response.data as Map<dynamic, dynamic>,
        );
      }

      return {"data": response.data};
    } on DioException {
      rethrow;
    } catch (e) {
      log("Unknown error: $e");
      throw Exception("Unexpected error occurred");
    }
  }

  void _handleUnauthorized() {
    _storage.remove("auth_token");

    // Prevent multiple redirects if already on login
    if (g.Get.currentRoute != AppRoutes.login) {
      g.Get.offAllNamed(AppRoutes.login);
      ToastHelper.error('Session expired', 'Please login again.');
    }
  }
}
