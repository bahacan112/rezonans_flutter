import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const RezonansApp());
}

class RezonansApp extends StatelessWidget {
  const RezonansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Schumann Rezonansı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.bgSpace,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryGold,
            surface: AppColors.bgDark,
          ),
        ),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    switch (status) {
      case AuthStatus.loading:
        return const Scaffold(
          backgroundColor: AppColors.bgSpace,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
        );
      case AuthStatus.signedIn:
        return const MainScreen();
      case AuthStatus.signedOut:
        return const AuthScreen();
    }
  }
}
