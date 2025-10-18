import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/notification.dart';

/// Supabase 서비스 클래스
/// 인증, 실시간 기능, 파일 저장 담당
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// 현재 세션
  Session? get currentSession => client.auth.currentSession;

  /// 현재 사용자
  User? get currentUser => client.auth.currentUser;

  /// === 인증 관련 메서드 ===

  /// 로그인
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('로그인 실패: ${e.toString()}');
    }
  }

  /// 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'https://chiobject.github.io/Legend_anabada_auth_test/auth_success.html',
      );
      return response;
    } catch (e) {
      throw Exception('회원가입 실패: ${e.toString()}');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('로그아웃 실패: ${e.toString()}');
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('비밀번호 재설정 실패: ${e.toString()}');
    }
  }

  /// 인증 상태 변경 리스너
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// === 실시간 기능 ===

  /// 알림 실시간 구독
  Stream<List<Map<String, dynamic>>> subscribeToNotifications(String userId) {
    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  /// 거래 상태 실시간 구독
  Stream<List<Map<String, dynamic>>> subscribeToTransactions(String userId) {
    return client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('lender_id', userId)
        .order('created_at', ascending: false);
  }

  /// 사물함 상태 실시간 구독
  Stream<List<Map<String, dynamic>>> subscribeToLockers() {
    return client
        .from('lockers')
        .stream(primaryKey: ['id'])
        .order('id', ascending: true);
  }

  /// 책 상태 실시간 구독 (내가 등록한 책들)
  Stream<List<Map<String, dynamic>>> subscribeToMyBooks(String userId) {
    return client
        .from('books')
        .stream(primaryKey: ['id'])
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
  }

  /// === 파일 저장 기능 ===

  /// 책 이미지 업로드
  Future<String> uploadBookImage(XFile imageFile, String fileName) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final path = 'book-images/$fileName';

      await client.storage.from('book-images').uploadBinary(path, bytes);

      return client.storage.from('book-images').getPublicUrl(path);
    } catch (e) {
      throw Exception('이미지 업로드 실패: ${e.toString()}');
    }
  }

  /// 프로필 이미지 업로드
  Future<String> uploadProfileImage(XFile imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.name.split('.').last;
      final path = 'profile-images/$userId.$extension';

      await client.storage.from('profile-images').uploadBinary(path, bytes);

      return client.storage.from('profile-images').getPublicUrl(path);
    } catch (e) {
      throw Exception('프로필 이미지 업로드 실패: ${e.toString()}');
    }
  }

  /// 이미지 삭제
  Future<void> deleteImage(String bucketName, String path) async {
    try {
      await client.storage.from(bucketName).remove([path]);
    } catch (e) {
      throw Exception('이미지 삭제 실패: ${e.toString()}');
    }
  }

  /// === 알림 관련 메서드 ===

  /// 알림 생성
  Future<void> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await client.from('notifications').insert({
        'user_id': userId,
        'type': type.value,
        'title': title,
        'message': message,
        'action_url': actionUrl,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('알림 생성 실패: ${e.toString()}');
    }
  }

  /// 알림 읽음 표시
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('알림 읽음 표시 실패: ${e.toString()}');
    }
  }

  /// 모든 알림 읽음 표시
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('모든 알림 읽음 표시 실패: ${e.toString()}');
    }
  }

  /// === 데이터베이스 직접 접근 (필요한 경우) ===

  /// 사용자 생성 (Supabase 테이블)
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String password,
    required String name,
    required String studentNumber,
    String? department,
    String? grade,
    String role = 'user',
  }) async {
    try {
      // 디버깅용 로그
      print('=== createUserProfile 호출 ===');
      print('userId: $userId');
      print('email: $email');
      print('password: $password');
      print('name: $name');
      print('studentNumber: $studentNumber');
      print('department: $department');
      print('grade: $grade');
      print('role: $role');

      final data = {
        'user_id': userId,
        'email': email,
        'password': password,
        'name': name,
        'student_number': studentNumber,
        'department': department,
        'grade': grade,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Insert data: $data');

      await client.from('User').insert(data);
    } catch (e) {
      throw Exception('사용자 프로필 생성 실패: ${e.toString()}');
    }
  }

  /// 사용자 정보 조회 (Supabase 테이블)
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('User')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('사용자 정보 조회 실패: ${e.toString()}');
    }
  }

  /// 사용자 정보 업데이트 (Supabase 테이블)
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await client.from('User').update({...updates}).eq('user_id', userId);
    } catch (e) {
      throw Exception('사용자 정보 업데이트 실패: ${e.toString()}');
    }
  }

  /// 포인트 업데이트
  Future<void> updateUserPoints(String userId, int points) async {
    try {
      await client
          .from('User')
          .update({'points': points})
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('포인트 업데이트 실패: ${e.toString()}');
    }
  }

  /// RPC 함수 호출 (저장 프로시저)
  Future<dynamic> callFunction(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await client.rpc(functionName, params: params);
      return response;
    } catch (e) {
      throw Exception('함수 호출 실패: ${e.toString()}');
    }
  }

  /// === 유틸리티 메서드 ===

  /// 현재 사용자 ID 가져오기
  String? getCurrentUserId() {
    return currentUser?.id;
  }

  /// 로그인 상태 확인
  bool get isLoggedIn => currentUser != null;

  /// 연결 상태 확인
  Future<bool> checkConnection() async {
    try {
      await client.from('User').select('user_id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
