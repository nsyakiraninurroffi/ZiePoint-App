import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/local_db.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/student_repository_impl.dart';
import 'services/token_manager.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/student_dashboard_viewmodel.dart';
import 'viewmodels/teacher_input_viewmodel.dart';
import 'viewmodels/manage_siswa_viewmodel.dart';
import 'viewmodels/manage_jenis_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDb.init();

  // CRITICAL: restore token to memory BEFORE anything else
  final tokenManager = TokenManager();
  await tokenManager.restoreSession();
  
  final authRepo = AuthRepositoryImpl();
  final loginVM = LoginViewModel(authRepo);
  await loginVM.checkAuthStatus(); // Load guru/siswa from Hive synchronously so router has it

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenManager>.value(value: tokenManager),
        ChangeNotifierProvider.value(value: loginVM),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudentDashboardViewModel(StudentRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => TeacherInputViewModel(StudentRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => ManageSiswaViewModel(StudentRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => ManageJenisViewModel(StudentRepositoryImpl())),
      ],
      child: const ZiePointApp(),
    ),
  );
}

class ZiePointApp extends StatelessWidget {
  const ZiePointApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenManager = context.read<TokenManager>();
    final loginVM = context.read<LoginViewModel>();
    final themeProvider = context.watch<ThemeProvider>();

    final router = AppRouter.createRouter(
      tokenManager: tokenManager,
      loginViewModel: loginVM,
    );

    return MaterialApp.router(
      title: 'ZiePoint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: router,
    );
  }
}
