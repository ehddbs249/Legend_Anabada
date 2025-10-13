import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

/// 카테고리 관련 상태 관리 Provider
class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Getter 들
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 전체 카테고리 목록 가져오기
  Future<void> fetchCategories() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('category')
          .select()
          .order('category_name', ascending: true);

      _categories = (response as List).map((json) => Category.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('카테고리 목록을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 분류 타입별 카테고리 필터링
  List<Category> getCategoriesByType(String type) {
    return _categories.where((cat) => cat.classficationType == type).toList();
  }

  /// 전공 과목 카테고리만 가져오기
  List<Category> get majorCategories => getCategoriesByType('major');

  /// 교양 과목 카테고리만 가져오기
  List<Category> get liberalArtsCategories => getCategoriesByType('liberal_arts');

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
