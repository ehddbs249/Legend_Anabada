/// 책 상태 열거형
enum BookStatus {
  available,   // 대여 가능
  reserved,    // 예약됨
  rented,      // 대여 중
  unavailable  // 사용 불가
}

/// 책 상태 관리 확장
extension BookStatusExtension on BookStatus {
  String get displayName {
    switch (this) {
      case BookStatus.available:
        return '대여 가능';
      case BookStatus.reserved:
        return '예약됨';
      case BookStatus.rented:
        return '대여 중';
      case BookStatus.unavailable:
        return '사용 불가';
    }
  }

  String get value {
    switch (this) {
      case BookStatus.available:
        return 'available';
      case BookStatus.reserved:
        return 'reserved';
      case BookStatus.rented:
        return 'rented';
      case BookStatus.unavailable:
        return 'unavailable';
    }
  }

  static BookStatus fromString(String value) {
    switch (value) {
      case 'available':
        return BookStatus.available;
      case 'reserved':
        return BookStatus.reserved;
      case 'rented':
        return BookStatus.rented;
      case 'unavailable':
        return BookStatus.unavailable;
      default:
        return BookStatus.available;
    }
  }
}

/// 책 상태 조건 열거형
enum BookCondition {
  excellent, // 최상
  good,      // 양호
  fair,      // 보통
  poor       // 나쁨
}

/// 책 상태 조건 확장
extension BookConditionExtension on BookCondition {
  String get displayName {
    switch (this) {
      case BookCondition.excellent:
        return '최상';
      case BookCondition.good:
        return '양호';
      case BookCondition.fair:
        return '보통';
      case BookCondition.poor:
        return '나쁨';
    }
  }

  String get value {
    switch (this) {
      case BookCondition.excellent:
        return 'excellent';
      case BookCondition.good:
        return 'good';
      case BookCondition.fair:
        return 'fair';
      case BookCondition.poor:
        return 'poor';
    }
  }

  static BookCondition fromString(String value) {
    switch (value) {
      case 'excellent':
        return BookCondition.excellent;
      case 'good':
        return BookCondition.good;
      case 'fair':
        return BookCondition.fair;
      case 'poor':
        return BookCondition.poor;
      default:
        return BookCondition.good;
    }
  }
}

/// 책 데이터 모델
class Book {
  final String id;
  final String? isbn;
  final String title;
  final String? author;
  final String? publisher;
  final int? publicationYear;
  final int? originalPrice;
  final int rentalPrice;
  final BookCondition condition;
  final String ownerId;
  final BookStatus status;
  final String? imageUrl;
  final String? description;
  final List<String> tags;
  final String? category;
  final String? subject;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Book({
    required this.id,
    this.isbn,
    required this.title,
    this.author,
    this.publisher,
    this.publicationYear,
    this.originalPrice,
    required this.rentalPrice,
    required this.condition,
    required this.ownerId,
    required this.status,
    this.imageUrl,
    this.description,
    this.tags = const [],
    this.category,
    this.subject,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 Book 객체 생성
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      isbn: json['isbn'] as String?,
      title: json['title'] as String,
      author: json['author'] as String?,
      publisher: json['publisher'] as String?,
      publicationYear: json['publication_year'] as int?,
      originalPrice: json['original_price'] as int?,
      rentalPrice: json['rental_price'] as int,
      condition: BookConditionExtension.fromString(json['condition'] as String),
      ownerId: json['owner_id'] as String,
      status: BookStatusExtension.fromString(json['status'] as String),
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String?,
      subject: json['subject'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Book 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': publisher,
      'publication_year': publicationYear,
      'original_price': originalPrice,
      'rental_price': rentalPrice,
      'condition': condition.value,
      'owner_id': ownerId,
      'status': status.value,
      'image_url': imageUrl,
      'description': description,
      'tags': tags,
      'category': category,
      'subject': subject,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Book 객체 복사 (일부 값 변경 가능)
  Book copyWith({
    String? id,
    String? isbn,
    String? title,
    String? author,
    String? publisher,
    int? publicationYear,
    int? originalPrice,
    int? rentalPrice,
    BookCondition? condition,
    String? ownerId,
    BookStatus? status,
    String? imageUrl,
    String? description,
    List<String>? tags,
    String? category,
    String? subject,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      originalPrice: originalPrice ?? this.originalPrice,
      rentalPrice: rentalPrice ?? this.rentalPrice,
      condition: condition ?? this.condition,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 할인율 계산 (원가 대비)
  double get discountRate {
    if (originalPrice == null || originalPrice! <= 0) return 0.0;
    return ((originalPrice! - rentalPrice) / originalPrice!) * 100;
  }

  /// 대여 가능 여부
  bool get isAvailable => status == BookStatus.available;

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
    return 'Book{id: $id, title: $title, author: $author, status: ${status.displayName}}';
  }
}