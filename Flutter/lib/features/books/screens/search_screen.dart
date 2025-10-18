import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/book.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = '전체';
  String _selectedCondition = '전체';
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    // 초기 검색 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  final List<String> _departments = [
    '전체',
    '컴퓨터공학과',
    '전자공학과',
    '기계공학과',
    '경영학과',
    '경제학과',
    '심리학과',
    '국어국문학과',
    '영어영문학과',
  ];

  final List<String> _conditions = [
    '전체',
    '최상',
    '양호',
    '보통',
    '하급',
  ];

  /// 검색 실행
  void _performSearch() {
    final bookProvider = context.read<BookProvider>();
    final query = _searchController.text.trim();

    // 필터 설정 - String으로 변경 (enum 제거됨)
    String? condition;
    if (_selectedCondition != '전체') {
      // 한글 -> String 변환
      switch (_selectedCondition) {
        case '최상':
          condition = 'excellent';
          break;
        case '양호':
          condition = 'good';
          break;
        case '보통':
          condition = 'fair';
          break;
        case '하급':
          condition = 'poor';
          break;
      }
    }

    int? minPrice = _priceRange.start > 0 ? _priceRange.start.toInt() : null;
    int? maxPrice = _priceRange.end < 1000 ? _priceRange.end.toInt() : null;
    String? category = _selectedDepartment != '전체' ? _selectedDepartment : null;

    bookProvider.setSearchFilters(
      condition: condition,
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: category,
    );

    bookProvider.searchBooks(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.search),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '교재명, 저자 검색',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    ),
                  ),
                  onSubmitted: (value) => _performSearch(),
                  onChanged: (value) {
                    // 실시간 검색 (디바운싱 필요시 추가)
                    if (value.isEmpty) {
                      _performSearch();
                    }
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: '학과',
                        value: _selectedDepartment,
                        onTap: () => _showDepartmentBottomSheet(),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '상태',
                        value: _selectedCondition,
                        onTap: () => _showConditionBottomSheet(),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '포인트',
                        value: '${_priceRange.start.toInt()}~${_priceRange.end.toInt()}P',
                        onTap: () => _showPriceBottomSheet(),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('초기화'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                if (bookProvider.isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (bookProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bookProvider.errorMessage!,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            bookProvider.clearError();
                            _performSearch();
                          },
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                final searchResults = bookProvider.searchResults;

                if (searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '검색 결과가 없습니다',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '다른 키워드로 검색해보세요',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final book = searchResults[index];
                    return BookCard(
                      title: book.title,
                      author: book.author,
                      publisher: book.publisher,
                      condition: book.conditionGradeDisplayName,
                      price: '${book.pointPrice} P',
                      imageUrl: book.imgUrl,
                      // department 필드는 Book 모델에 없으므로 categoryId 사용 또는 제거
                      // department: book.categoryId, // 카테고리 ID만 있음
                      isHorizontal: true,
                      onTap: () {
                        // TODO: 책 상세 화면으로 이동
                        // context.go('/book/${book.id}');
                        _showBookDetailDialog(book);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 초기화
  void _resetFilters() {
    setState(() {
      _selectedDepartment = '전체';
      _selectedCondition = '전체';
      _priceRange = const RangeValues(0, 1000);
    });
    context.read<BookProvider>().clearSearchFilters();
    _performSearch();
  }

  /// 책 상세 정보 다이얼로그 (임시)
  void _showBookDetailDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('저자: ${book.author}'),
            Text('출판사: ${book.publisher ?? "미상"}'),
            Text('상태: ${book.conditionGradeDisplayName}'),
            Text('가격: ${book.pointPrice} P'),
            if (book.dmgTag != null) ...[
              const SizedBox(height: 8),
              Text('손상 태그: ${book.dmgTag}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestBookTransaction(book);
            },
            child: const Text('대여 요청'),
          ),
        ],
      ),
    );
  }

  /// 대여 요청 처리
  Future<void> _requestBookTransaction(Book book) async {
    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _showSnackBar('로그인이 필요합니다');
      return;
    }

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 거래 생성 요청
    final result = await transactionProvider.createTransaction(
      bookId: book.id,
      borrowerId: currentUser.id,
    );

    // 로딩 다이얼로그 닫기
    if (mounted) Navigator.of(context).pop();

    // 결과 표시
    if (!mounted) return;

    if (result['success'] == true) {
      // 성공
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('거래 신청 완료'),
          content: Text(
            '${result['point_spent']}P가 차감되었습니다.\n'
            '거래가 완료되면 판매자에게 포인트가 지급됩니다.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 실패
      final message = result['message'];
      final required = result['required'];
      final current = result['current'];

      String detailMessage = message ?? '거래 신청에 실패했습니다';
      if (required != null && current != null) {
        detailMessage += '\n\n필요 포인트: ${required}P\n현재 포인트: ${current}P';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('거래 신청 실패'),
          content: Text(detailMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDepartmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '학과 선택',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _departments.length,
                  itemBuilder: (context, index) {
                    final department = _departments[index];
                    return ListTile(
                      title: Text(department),
                      trailing: _selectedDepartment == department
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedDepartment = department;
                        });
                        Navigator.pop(context);
                        _performSearch();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConditionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '상태 선택',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_conditions.length, (index) {
                final condition = _conditions[index];
                return ListTile(
                  title: Text(condition),
                  trailing: _selectedCondition == condition
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCondition = condition;
                    });
                    Navigator.pop(context);
                    _performSearch();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPriceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '포인트 범위',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_priceRange.start.toInt()} P'),
                      Text('${_priceRange.end.toInt()} P'),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_priceRange.start.toInt()}P',
                      '${_priceRange.end.toInt()}P',
                    ),
                    onChanged: (values) {
                      setModalState(() {
                        _priceRange = values;
                      });
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performSearch();
                    },
                    child: const Text('적용'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}