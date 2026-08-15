import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/client_home_screen.dart';
import '../features/home/presentation/screens/provider_home_screen.dart';
import '../features/categories/presentation/screens/category_grid_screen.dart';
import '../features/jobs/presentation/screens/create_job_screen.dart';
import '../features/jobs/presentation/screens/job_detail_screen.dart';
import '../features/jobs/presentation/screens/job_list_screen.dart';
import '../features/jobs/presentation/screens/provider_match_screen.dart';
import '../features/payment/presentation/screens/payment_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/';
      
      if (authState.isLoading || isSplash) return null;
      
      final user = authState.value;
      if (user == null && !isAuthRoute) {
        return '/login';
      }
      
      if (user != null && isAuthRoute) {
        return user.role == 'CLIENT' ? '/client-home' : '/provider-home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/client-home',
        builder: (context, state) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: '/provider-home',
        builder: (context, state) => const ProviderHomeScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryGridScreen(),
      ),
      GoRoute(
        path: '/jobs/create/:categoryId',
        builder: (context, state) => CreateJobScreen(categoryId: state.pathParameters['categoryId']!),
      ),
      GoRoute(
        path: '/jobs/:jobId',
        builder: (context, state) => JobDetailScreen(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: '/jobs',
        builder: (context, state) => const JobListScreen(),
      ),
      GoRoute(
        path: '/providers/nearby/:categoryId',
        builder: (context, state) => ProviderMatchScreen(categoryId: state.pathParameters['categoryId']!),
      ),
      GoRoute(
        path: '/payment/:jobId',
        builder: (context, state) => PaymentScreen(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
