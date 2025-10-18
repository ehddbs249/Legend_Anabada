import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/books/screens/search_screen.dart';
import '../../features/books/screens/register_book_screen.dart';
import '../../features/transactions/screens/transaction_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/locker/screens/locker_screen.dart';
import '../../features/locker/screens/locker_detail_screen.dart';
import '../../features/ocr/screens/ocr_camera_screen.dart';
import '../../screens/main_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routerNeglect: false,
    routes: [
      // 로그인 화면
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 회원가입 화면
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // 홈 화면
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScreen(child: HomeScreen()),
      ),

      // 검색 화면
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const MainScreen(child: SearchScreen()),
      ),

      // 거래 내역 화면
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const MainScreen(child: TransactionScreen()),
      ),

      // 프로필 화면
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const MainScreen(child: ProfileScreen()),
      ),

      // 교재 등록 화면 (독립적인 화면)
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          final ocrData = state.extra as Map<String, dynamic>?;
          return RegisterBookScreen(ocrData: ocrData);
        },
      ),

      // OCR 촬영 화면 (독립적인 화면)
      GoRoute(
        path: '/ocr-camera',
        name: 'ocr-camera',
        builder: (context, state) => const OcrCameraScreen(),
      ),

      // 사물함 관리 화면
      GoRoute(
        path: '/locker',
        name: 'locker',
        builder: (context, state) => const LockerScreen(),
      ),

      // 사물함 상세 화면
      GoRoute(
        path: '/locker/:lockerId',
        name: 'locker-detail',
        builder: (context, state) {
          final lockerId = state.pathParameters['lockerId']!;
          final bookTitle = state.uri.queryParameters['bookTitle'] ?? '';
          final transactionId = state.uri.queryParameters['transactionId'] ?? '';
          final pinCode = state.uri.queryParameters['pinCode'] ?? '1234'; // 기본값 또는 실제 PIN

          return LockerDetailScreen(
            lockerId: lockerId,
            bookTitle: bookTitle,
            transactionId: transactionId,
            pinCode: pinCode,
          );
        },
      ),
    ],

    // 404 에러 처리
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '요청하신 페이지를 찾을 수 없습니다.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '경로: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로 이동'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}

// 라우터 헬퍼 클래스
class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String search = '/search';
  static const String register = '/register';
  static const String ocrCamera = '/ocr-camera';
  static const String transactions = '/transactions';
  static const String profile = '/profile';
  static const String locker = '/locker';

  static String lockerDetail(String lockerId, {String? bookTitle, String? transactionId, String? pinCode}) {
    final uri = Uri(
      path: '/locker/$lockerId',
      queryParameters: {
        if (bookTitle != null) 'bookTitle': bookTitle,
        if (transactionId != null) 'transactionId': transactionId,
        if (pinCode != null) 'pinCode': pinCode,
      },
    );
    return uri.toString();
  }
}