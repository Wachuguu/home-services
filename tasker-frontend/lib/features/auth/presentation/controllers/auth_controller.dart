import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user.dart';
import '../../data/datasources/auth_remote_ds.dart';
import '../../../../core/storage/secure_storage_service.dart';

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return await checkAuthStatus();
  }

  Future<User?> checkAuthStatus() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();
    if (token == null) return null;

    try {
      return await ref.read(authRemoteDsProvider).getCurrentUser();
    } catch (_) {
      await storage.deleteToken();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final response = await ref.read(authRemoteDsProvider).login(email, password);
      final token = response['token'] as String?;
      if (token != null) await ref.read(secureStorageProvider).saveToken(token);
      final user = await ref.read(authRemoteDsProvider).getCurrentUser();
      state = AsyncData(user);
    } on DioException catch (e) {
      String errorMessage = "Login failed. Please check your credentials.";
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          final data = e.response?.data as Map;
          if (data.containsKey('message')) {
            errorMessage = data['message'].toString();
          }
        } else {
          errorMessage = e.response?.data.toString() ?? errorMessage;
        }
      }
      state = AsyncError(errorMessage, e.stackTrace);
    } catch (e, st) {
      state = AsyncError("An unexpected error occurred", st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await ref.read(authRemoteDsProvider).register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
      );
      final token = response['token'] as String?;
      if (token != null) await ref.read(secureStorageProvider).saveToken(token);
      final user = await ref.read(authRemoteDsProvider).getCurrentUser();
      state = AsyncData(user);
    } on DioException catch (e) {
      String errorMessage = "Registration failed. Please check your details.";
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          final data = e.response?.data as Map;
          if (data.containsKey('message')) {
            errorMessage = data['message'].toString();
          }
        } else {
          errorMessage = e.response?.data.toString() ?? errorMessage;
        }
      }
      state = AsyncError(errorMessage, e.stackTrace);
    } catch (e, st) {
      state = AsyncError("An unexpected error occurred", st);
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearAll();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(() => AuthController());
