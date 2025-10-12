/// 카테고리 데이터 모델
/// Spring Boot Entity: Category (category_id, category_name, parent_category_id, classfication_type)
class Category {
  /// 카테고리 ID (UUID) ← category_id
  final String id;

  /// 카테고리 이름 ← category_name
  final String categoryName;

  /// 상위 카테고리 ID (nullable, 계층 구조) ← parent_category_id
  final String? parentCategoryId;

  /// 분류 타입 ← classfication_type (오타 그대로 유지)
  final String classficationType;

  const Category({
    required this.id,
    required this.categoryName,
    this.parentCategoryId,
    required this.classficationType,
  });

  /// JSON에서 Category 객체 생성
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      parentCategoryId: json['parent_category_id'] as String?,
      classficationType: json['classfication_type'] as String,
    );
  }

  /// Category 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'category_name': categoryName,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      'classfication_type': classficationType,
    };
  }

  /// Category 객체 복사 (일부 값 변경 가능)
  Category copyWith({
    String? id,
    String? categoryName,
    String? parentCategoryId,
    String? classficationType,
  }) {
    return Category(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      classficationType: classficationType ?? this.classficationType,
    );
  }

  /// 최상위 카테고리 여부 확인
  bool get isTopLevel => parentCategoryId == null;

  /// 하위 카테고리 여부 확인
  bool get hasParent => parentCategoryId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category{id: $id, categoryName: $categoryName, classficationType: $classficationType}';
  }
}
