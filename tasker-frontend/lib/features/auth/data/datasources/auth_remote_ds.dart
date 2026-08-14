import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/user.dart';

final authRemoteDsProvider = Provider<AuthRemoteDs>((ref) {
  return AuthRemoteDs(ref.watch(dioClientProvider));
});

class AuthRemoteDs {
  final Dio _dio;

  AuthRemoteDs(this._dio);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
  }) async {
    final response = await _dio.post(ApiEndpoints.register, data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.usersMe);
    return User.fromJson(response.data);
  }
}
