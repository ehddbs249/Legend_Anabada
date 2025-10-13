import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/themes/app_theme.dart';
import 'app/routes/app_router.dart';
import 'core/constants/app_strings.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/book_provider.dart';
import 'data/providers/transaction_provider.dart';
import 'data/providers/locker_provider.dart';
import 'data/providers/category_provider.dart';
import 'data/providers/point_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Supabase 초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
        // 카테고리 관리
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        // 거래 관리
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        // 사물함 관리
        ChangeNotifierProvider(create: (_) => LockerProvider()),
        // 포인트 관리
        ChangeNotifierProvider(create: (_) => PointProvider()),
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
