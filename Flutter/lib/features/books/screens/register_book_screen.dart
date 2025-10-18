import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../app/routes/app_router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/models/book.dart';

class RegisterBookScreen extends StatefulWidget {
  final Map<String, dynamic>? ocrData;

  const RegisterBookScreen({super.key, this.ocrData});

  @override
  State<RegisterBookScreen> createState() => _RegisterBookScreenState();
}

class _RegisterBookScreenState extends State<RegisterBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  // NOTE: ISBN, subject, originalPrice 필드는 새 Book 모델에서 제거되었습니다.
  final _descriptionController = TextEditingController(); // dmgTag로 매핑됨

  String? _selectedCategoryId; // 실제 카테고리 ID (UUID)
  String _selectedCondition = '양호';
  int _suggestedPoints = 0;
  final List<XFile> _images = [];
  bool _isSubmitting = false;

  final Map<String, int> _conditionPoints = {
    '최상': 500,
    '양호': 300,
    '보통': 200,
    '하급': 100,
  };

  @override
  void initState() {
    super.initState();
    _suggestedPoints = _conditionPoints[_selectedCondition] ?? 0;

    // OCR 데이터가 있으면 자동으로 채우기
    if (widget.ocrData != null) {
      _titleController.text = widget.ocrData!['title'] ?? '';
      _authorController.text = widget.ocrData!['author'] ?? '';
      _publisherController.text = widget.ocrData!['publisher'] ?? '';

      if (widget.ocrData!['condition_grade'] != null) {
        final conditionStatus = widget.ocrData!['condition_grade'] as String?;

        if (conditionStatus != null &&
            _conditionPoints.containsKey(conditionStatus)) {
          _selectedCondition = conditionStatus;
          _suggestedPoints = _conditionPoints[_selectedCondition] ?? 0;
        }
      }

      // dmg_tag 리스트가 있으면 자동으로 손상 태그 설정
      if (widget.ocrData!['dmg_tag'] != null) {
        final dmgTagList = widget.ocrData!['dmg_tag'];
        if (dmgTagList is List && dmgTagList.isNotEmpty) {
          // 리스트를 쉼표로 구분된 문자열로 변환
          _descriptionController.text = dmgTagList.join(', ');
        }
      }

      // OCR 촬영 이미지가 있으면 자동으로 추가
      if (widget.ocrData!['capturedImage'] != null) {
        final capturedImage = widget.ocrData!['capturedImage'] as XFile;
        _images.add(capturedImage);
      }
    }

    // 카테고리 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.registerBook)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('교재 정보', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '교재명 *',
                  hintText: '예: 자료구조와 알고리즘',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '교재명을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: '저자 *',
                  hintText: '예: 홍길동',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '저자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _publisherController,
                decoration: const InputDecoration(
                  labelText: '출판사',
                  hintText: '예: 교육출판사',
                ),
              ),
              const SizedBox(height: 16),
              // 카테고리 선택 (실제 Supabase category 테이블 사용)
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final categories = categoryProvider.categories;

                  if (categoryProvider.isLoading) {
                    return const LinearProgressIndicator();
                  }

                  if (categories.isEmpty) {
                    return const Text('카테고리를 불러오는 중...');
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: '카테고리 *',
                      helperText: '교재 카테고리를 선택해주세요',
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(
                          '${category.categoryName} (${category.classficationType == 'major' ? '전공' : '교양'})',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '카테고리를 선택해주세요';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('상태 평가', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '교재 상태 선택',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _conditionPoints.keys.map((condition) {
                        final isSelected = _selectedCondition == condition;
                        return ChoiceChip(
                          label: Text(condition),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCondition = condition;
                              _suggestedPoints = _conditionPoints[condition]!;
                            });
                          },
                          selectedColor: AppColors.primaryLight,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getConditionDescription(_selectedCondition),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '예상 획득 포인트',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '$_suggestedPoints P',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('사진 첨부', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _images.length) {
                      return _AddPhotoButton(onTap: _pickImage);
                    }
                    return _PhotoItem(
                      image: _images[index],
                      onRemove: () {
                        setState(() {
                          _images.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // NOTE: dmgTag로 매핑됨 (손상 태그)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '손상/상태 태그',
                  hintText: '교재의 손상 상태나 특이사항을 간단히 입력해주세요',
                  helperText: '예: 앞표지 약간 구겨짐, 3페이지 낙서',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('등록 중...'),
                          ],
                        )
                      : const Text('교재 등록'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getConditionDescription(String condition) {
    switch (condition) {
      case '최상':
        return '새 책과 같은 상태. 필기나 접힌 흔적이 전혀 없음';
      case '양호':
        return '약간의 사용 흔적이 있으나 전반적으로 깨끗함';
      case '보통':
        return '일반적인 사용 흔적이 있음. 필기나 밑줄이 일부 있을 수 있음';
      case '하급':
        return '사용 흔적이 많이 있으나 내용 확인에는 문제없음';
      default:
        return '';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final bookProvider = context.read<BookProvider>();

    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      _showSnackBar('로그인이 필요합니다');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 상태 등급을 String으로 변환 (enum 제거됨)
      // NOTE: BookCondition enum이 제거되고 String을 사용합니다.
      // 가능한 값: "excellent", "good", "fair", "poor"
      String conditionGrade;
      switch (_selectedCondition) {
        case '최상':
          conditionGrade = 'excellent';
          break;
        case '양호':
          conditionGrade = 'good';
          break;
        case '보통':
          conditionGrade = 'fair';
          break;
        case '하급':
          conditionGrade = 'poor';
          break;
        default:
          conditionGrade = 'good';
      }

      // NOTE: 이미지 업로드는 ApiService.createBook()에서 FormData로 처리됩니다.
      // 첫 번째 이미지만 전송 (추후 여러 이미지 지원 가능)

      // 카테고리 ID 확인
      if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
        _showSnackBar('카테고리를 선택해주세요');
        return;
      }

      // Book 모델 생성
      final book = Book(
        id: '', // 서버에서 생성
        userId: currentUser.id,
        categoryId: _selectedCategoryId!, // 실제 카테고리 UUID 사용
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        publisher: _publisherController.text.trim().isNotEmpty
            ? _publisherController.text.trim()
            : null,
        pointPrice: _suggestedPoints,
        conditionGrade: conditionGrade,
        dmgTag: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        imgUrl: null, // 서버에서 이미지 업로드 후 URL 생성
        registeredAt: DateTime.now(),
      );

      // 책 등록 (이미지 파일 포함)
      final success = await bookProvider.registerBook(
        book,
        imageFile: _images.isNotEmpty ? _images.first : null,
      );

      if (success) {
        _showSnackBar('교재가 성공적으로 등록되었습니다!');
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } else {
        _showSnackBar(bookProvider.errorMessage ?? '교재 등록에 실패했습니다');
      }
    } catch (e) {
      _showSnackBar('교재 등록 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text('사진 추가', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _PhotoItem({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: MemoryImage(snapshot.data!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else {
              return Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
