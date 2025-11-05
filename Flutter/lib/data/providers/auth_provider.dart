import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

/// 인증 상태 관리 Provider
class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// 현재 사용자
  User? get currentUser => _currentUser;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 에러 메시지
  String? get errorMessage => _errorMessage;

  /// 로그인 상태 확인
  bool get isLoggedIn => _currentUser != null;

  /// 대학 이메일 도메인 검증
  bool isValidUniversityEmail(String email) {
    // 주요 대학 이메일 도메인 목록
    final universityDomains = [
      'mokpo.ac.kr',
      'snu.ac.kr',
      'yonsei.ac.kr',
      'korea.ac.kr',
      'skku.edu',
      'hanyang.ac.kr',
      'sogang.ac.kr',
      'cau.ac.kr',
      'kyunghee.ac.kr',
      'konkuk.ac.kr',
      'dankook.ac.kr',
      'ajou.ac.kr',
      'inha.ac.kr',
      'dongguk.edu',
      'hongik.ac.kr',
      'kookmin.ac.kr',
      'ssu.ac.kr',
      'khu.ac.kr',
      // 더 많은 대학 도메인 추가 가능
    ];

    for (final domain in universityDomains) {
      if (email.endsWith('@$domain')) {
        return true;
      }
    }
    return false;
  }

  /// 로그인
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      // Supabase 인증
      final authResponse = await _supabaseService.signIn(email, password);

      if (authResponse.user != null) {
        // 사용자 정보 가져오기
        await _loadCurrentUser(authResponse.user!.id);
        _setLoading(false);
        return true;
      } else {
        _setError('로그인에 실패했습니다.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      // Supabase 에러 메시지 파싱
      final errorMessage = _parseAuthError(e.toString());
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }

  /// Supabase 인증 에러 메시지 파싱
  String _parseAuthError(String error) {
    final lowerError = error.toLowerCase();

    // Invalid login credentials
    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid_credentials')) {
      return '이메일 또는 비밀번호가 일치하지 않습니다.';
    }

    // Email not confirmed
    if (lowerError.contains('email not confirmed') ||
        lowerError.contains('email_not_confirmed')) {
      return '이메일 인증이 완료되지 않았습니다. 이메일을 확인해주세요.';
    }

    // User not found
    if (lowerError.contains('user not found') ||
        lowerError.contains('user_not_found')) {
      return '등록되지 않은 이메일입니다.';
    }

    // Too many requests
    if (lowerError.contains('too many requests') ||
        lowerError.contains('rate limit')) {
      return '너무 많은 시도를 하셨습니다. 잠시 후 다시 시도해주세요.';
    }

    // Network error
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return '네트워크 연결을 확인해주세요.';
    }

    // Invalid email format
    if (lowerError.contains('invalid email') ||
        lowerError.contains('email format')) {
      return '올바른 이메일 형식이 아닙니다.';
    }

    // Password too short
    if (lowerError.contains('password') &&
        (lowerError.contains('short') || lowerError.contains('length'))) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }

    // 기타 에러
    if (lowerError.contains('exception:')) {
      // "Exception: 로그인 실패: ..." 형식에서 실제 에러 메시지만 추출
      final parts = error.split('로그인 실패:');
      if (parts.length > 1) {
        final actualError = parts[1].trim();
        // 추출된 에러를 다시 파싱
        return _parseAuthError(actualError);
      }
    }

    // 알 수 없는 에러
    return '로그인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  /// 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String studentNumber,
    String? department,
    String? grade,
    String role = 'user',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // 대학 이메일 검증
      if (!isValidUniversityEmail(email)) {
        _setError('유효한 대학 이메일을 입력해주세요.');
        _setLoading(false);
        return false;
      }

      // Supabase 회원가입
      final authResponse = await _supabaseService.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // Supabase Database에 사용자 정보 저장
        await _supabaseService.createUserProfile(
          userId: authResponse.user!.id,
          email: email,
          password: password,
          name: name,
          studentNumber: studentNumber,
          department: department,
          grade: grade,
          role: role,
        );

        // 사용자 정보 생성
        final user = User(
          id: authResponse.user!.id,
          email: email,
          name: name,
          studentNumber: studentNumber,
          department: department ?? '',
          createdAt: DateTime.now(),
          role: role,
          grade: grade,
        );

        _currentUser = user;
        _setLoading(false);
        return true;
      } else {
        _setError('회원가입에 실패했습니다.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('회원가입 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabaseService.signOut();
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('로그아웃 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 비밀번호 재설정
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabaseService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('비밀번호 재설정 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 현재 사용자 정보 로드
  Future<void> _loadCurrentUser(String userId) async {
    try {
      final userData = await _supabaseService.getUserProfile(userId);
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      _setError('사용자 정보를 불러오는데 실패했습니다: ${e.toString()}');
    }
  }

  /// 사용자 정보 업데이트
  Future<bool> updateUser(User updatedUser) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabaseService.updateUserProfile(
        userId: updatedUser.id,
        updates: updatedUser.toJson(),
      );

      _currentUser = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('사용자 정보 업데이트 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 포인트 업데이트
  /// NOTE: 포인트는 UserPointBalance 테이블에서 별도 관리됩니다.
  /// 포인트 정보가 필요한 경우 UserPointBalance API를 호출하세요.
  @Deprecated('User 모델에서 points 필드가 제거되었습니다. UserPointBalance를 사용하세요.')
  Future<void> updatePoints(int newPoints) async {
    // points 필드는 User 모델에서 제거되었습니다.
    // 대신 UserPointBalance API를 사용하세요.
    throw UnimplementedError(
      'updatePoints는 더 이상 사용할 수 없습니다. UserPointBalance API를 사용하세요.',
    );
  }

  /// 초기 인증 상태 확인
  Future<void> checkAuthState() async {
    try {
      _setLoading(true);
      final session = _supabaseService.currentSession;

      if (session?.user != null) {
        await _loadCurrentUser(session!.user.id);
      }
      _setLoading(false);
    } catch (e) {
      _setError('인증 상태 확인 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 설정
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 에러 지우기
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 에러 지우기 (외부에서 호출 가능)
  void clearError() {
    _clearError();
  }
}