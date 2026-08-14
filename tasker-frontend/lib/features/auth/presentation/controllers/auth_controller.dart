import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../../data/datasources/auth_remote_ds.dart';
import '../../../../core/storage/secure_storage_service.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() async {
    return await checkAuthStatus();
  }

  Future<User?> checkAuthStatus() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();
    if (token == null) return null;

    try {
      final user = await ref.read(authRemoteDsProvider).getCurrentUser();
      return user;
    } catch (e) {
      await storage.deleteToken();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(authRemoteDsProvider).login(email, password);
      final token = response['token'];
      if (token != null) {
        await ref.read(secureStorageProvider).saveToken(token);
      }
      return await ref.read(authRemoteDsProvider).getCurrentUser();
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(authRemoteDsProvider).register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
      );
      final token = response['token'];
      if (token != null) {
        await ref.read(secureStorageProvider).saveToken(token);
      }
      return await ref.read(authRemoteDsProvider).getCurrentUser();
    });
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearAll();
    state = const AsyncData(null);
  }
}
