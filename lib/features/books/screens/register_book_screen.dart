import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../app/routes/app_router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/models/book.dart';

class RegisterBookScreen extends StatefulWidget {
  const RegisterBookScreen({super.key});

  @override
  State<RegisterBookScreen> createState() => _RegisterBookScreenState();
}

class _RegisterBookScreenState extends State<RegisterBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _isbnController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();

  String _selectedDepartment = '컴퓨터공학과';
  String _selectedCondition = '양호';
  int _suggestedPoints = 0;
  final List<File> _images = [];
  bool _isSubmitting = false;

  final List<String> _departments = [
    '컴퓨터공학과',
    '전자공학과',
    '기계공학과',
    '경영학과',
    '경제학과',
    '심리학과',
    '국어국문학과',
    '영어영문학과',
  ];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerBook),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '교재 정보',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  hintText: '예: 978-89-12345-67-8',
                ),
                keyboardType: TextInputType.number,
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
              TextFormField(
                controller: _originalPriceController,
                decoration: const InputDecoration(
                  labelText: '원가 (선택)',
                  hintText: '예: 25000',
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: '학과 *',
                ),
                items: _departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(dept),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: '과목명 *',
                  hintText: '예: 자료구조',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '과목명을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                '상태 평가',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
                        color: AppColors.primaryLight.withValues(alpha:0.1),
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
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
              Text(
                '사진 첨부',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '추가 설명',
                  hintText: '교재 상태에 대한 추가 설명을 입력해주세요',
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
        _images.add(File(image.path));
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
      // BookCondition enum으로 변환
      BookCondition condition;
      switch (_selectedCondition) {
        case '최상':
          condition = BookCondition.excellent;
          break;
        case '양호':
          condition = BookCondition.good;
          break;
        case '보통':
          condition = BookCondition.fair;
          break;
        case '하급':
          condition = BookCondition.poor;
          break;
        default:
          condition = BookCondition.good;
      }

      // 원가 파싱
      int? originalPrice;
      if (_originalPriceController.text.isNotEmpty) {
        originalPrice = int.tryParse(_originalPriceController.text);
      }

      // TODO: 이미지 업로드 구현 (Supabase Storage)
      String? imageUrl;
      if (_images.isNotEmpty) {
        // 첫 번째 이미지만 업로드 (추후 여러 이미지 지원 가능)
        // imageUrl = await SupabaseService().uploadBookImage(_images.first, 'book_${DateTime.now().millisecondsSinceEpoch}');
      }

      // Book 객체 생성
      final book = Book(
        id: '', // 서버에서 생성
        title: _titleController.text.trim(),
        author: _authorController.text.trim().isNotEmpty ? _authorController.text.trim() : null,
        publisher: _publisherController.text.trim().isNotEmpty ? _publisherController.text.trim() : null,
        isbn: _isbnController.text.trim().isNotEmpty ? _isbnController.text.trim() : null,
        originalPrice: originalPrice,
        rentalPrice: _suggestedPoints,
        condition: condition,
        ownerId: currentUser.id,
        status: BookStatus.available,
        imageUrl: imageUrl,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        category: _selectedDepartment,
        subject: _subjectController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 책 등록
      final success = await bookProvider.registerBook(book);

      if (success) {
        _showSnackBar('교재가 성공적으로 등록되었습니다!');
        context.go(AppRoutes.home);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _isbnController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
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
            Text(
              '사진 추가',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _PhotoItem({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
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
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}