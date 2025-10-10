import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'app/themes/app_theme.dart';
import 'app/routes/app_router.dart';
import 'core/constants/app_strings.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/book_provider.dart';
import 'data/providers/transaction_provider.dart';
import 'data/providers/locker_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // URL strategy를 path-based로 설정 (hash 제거)
  usePathUrlStrategy();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AnabadaApp());
}

class AnabadaApp extends StatelessWidget {
  const AnabadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 인증 관리
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // 책 관리
        ChangeNotifierProvider(create: (_) => BookProvider()),
        // 거래 관리
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        // 사물함 관리
        ChangeNotifierProvider(create: (_) => LockerProvider()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
