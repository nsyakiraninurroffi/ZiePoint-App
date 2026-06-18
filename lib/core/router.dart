import 'package:go_router/go_router.dart';
import '../services/token_manager.dart';
import '../viewmodels/login_viewmodel.dart';
import '../screens/login_page.dart';
import '../screens/student_dashboard.dart';
import '../screens/teacher_input_page.dart';

class AppRouter {
  static GoRouter createRouter({
    required TokenManager tokenManager,
    required LoginViewModel loginViewModel,
  }) {
    return GoRouter(
      initialLocation: '/login',
      
      // CRITICAL: GoRouter re-evaluates redirect every time loginViewModel notifies
      refreshListenable: loginViewModel,
      
      redirect: (context, state) {
        final isAuth = tokenManager.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';
        
        if (!isAuth && !isLoginRoute) {
          // Not logged in, trying to access protected route → send to login
          return '/login';
        }
        
        if (isAuth && isLoginRoute) {
          // Already logged in, on login page → redirect to correct dashboard
          final role = tokenManager.userRole;
          if (role == 'guru') return '/teacher';
          return '/student';
        }
        
        // No redirect needed
        return null;
      },
      
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/student',
          builder: (context, state) => const StudentDashboardPage(),
        ),
        GoRoute(
          path: '/teacher',
          builder: (context, state) {
            final guru = loginViewModel.guru;
            if (guru == null) {
              // If we have token but lost profile data, force re-login
              return const LoginPage();
            }
            return TeacherInputPage(guru: guru);
          },
        ),
      ],
    );
  }
}
