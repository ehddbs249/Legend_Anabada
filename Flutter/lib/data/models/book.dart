/// 책 데이터 모델
/// Spring Boot Entity: Book (book_id, user_id, category_id, title, author, publisher, point_price, condition_grade, dmg_tag, img_url, registered_at)
class Book {
  /// 책 ID (UUID) ← book_id
  final String id;

  /// 소유자 사용자 ID (UUID) ← user_id
  final String userId;

  /// 카테고리 ID (UUID) ← category_id
  final String categoryId;

  /// 책 제목 ← title
  final String title;

  /// 저자 ← author
  final String author;

  /// 출판사 ← publisher
  final String? publisher;

  /// 포인트 가격 ← point_price
  final int pointPrice;

  /// 책 상태 등급 (excellent, good, fair, poor) ← condition_grade
  final String? conditionGrade;

  /// 손상 태그 ← dmg_tag
  final String? dmgTag;

  /// 이미지 URL ← img_url
  final String? imgUrl;

  /// 등록일 ← registered_at
  final DateTime registeredAt;

  const Book({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.author,
    this.publisher,
    required this.pointPrice,
    this.conditionGrade,
    this.dmgTag,
    this.imgUrl,
    required this.registeredAt,
  });

  /// JSON에서 Book 객체 생성
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['book_id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      publisher: json['publisher'] as String?,
      pointPrice: json['point_price'] as int? ?? 0,
      conditionGrade: json['condition_grade'] as String?,
      dmgTag: json['dmg_tag'] as String?,
      imgUrl: json['img_url'] as String?,
      registeredAt: DateTime.parse(json['registered_at'] as String),
    );
  }

  /// Book 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'book_id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'author': author,
      'publisher': publisher,
      'point_price': pointPrice,
      'condition_grade': conditionGrade,
      'dmg_tag': dmgTag,
      'img_url': imgUrl,
      'registered_at': registeredAt.toIso8601String(),
    };
  }

  /// Book 객체 복사 (일부 값 변경 가능)
  Book copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? title,
    String? author,
    String? publisher,
    int? pointPrice,
    String? conditionGrade,
    String? dmgTag,
    String? imgUrl,
    DateTime? registeredAt,
  }) {
    return Book(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      pointPrice: pointPrice ?? this.pointPrice,
      conditionGrade: conditionGrade ?? this.conditionGrade,
      dmgTag: dmgTag ?? this.dmgTag,
      imgUrl: imgUrl ?? this.imgUrl,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  /// 책 상태 등급 한글 표시
  String get conditionGradeDisplayName {
    switch (conditionGrade) {
      case 'excellent':
        return '최상';
      case 'good':
        return '양호';
      case 'fair':
        return '보통';
      case 'poor':
        return '나쁨';
      default:
        return '미지정';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Book{id: $id, title: $title, author: $author, pointPrice: $pointPrice}';
  }
}
