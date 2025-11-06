import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedGrade;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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

  final List<String> _grades = ['1학년', '2학년', '3학년', '4학년', '대학원생'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _selectedDepartment = user.department;

      debugPrint('데이터베이스에서 가져온 grade 값: ${user.grade}');
      _selectedGrade = user.grade; // 변환하지 않고 그대로 사용
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 수정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PremiumCard(
                elevation: 2,
                child: Column(
                  children: [
                    _buildTextField(
                      label: '이름',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: '학과',
                      value: _selectedDepartment,
                      items: _departments,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '학과를 선택해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: '학년',
                      value: _selectedGrade,
                      items: _grades,
                      onChanged: (value) {
                        setState(() {
                          _selectedGrade = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '학년을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('비밀번호 변경', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              PremiumCard(
                elevation: 2,
                child: Column(
                  children: [
                    _buildPasswordField(
                      label: '새 비밀번호',
                      controller: _passwordController,
                      isVisible: _isPasswordVisible,
                      onVisibilityChanged: (value) {
                        setState(() {
                          _isPasswordVisible = value;
                        });
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 8) {
                            return '비밀번호는 8자 이상이어야 합니다';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      label: '새 비밀번호 확인',
                      controller: _confirmPasswordController,
                      isVisible: _isConfirmPasswordVisible,
                      onVisibilityChanged: (value) {
                        setState(() {
                          _isConfirmPasswordVisible = value;
                        });
                      },
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty &&
                            value != _passwordController.text) {
                          return '비밀번호가 일치하지 않습니다';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () => onVisibilityChanged(!isVisible),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user != null) {
        debugPrint('=== 프로필 업데이트 시작 ===');
        debugPrint('현재 사용자: ${user.toJson()}');
        debugPrint('입력된 이름: ${_nameController.text}');
        debugPrint('선택된 학과: $_selectedDepartment');
        debugPrint('선택된 학년: $_selectedGrade');
        debugPrint('비밀번호 변경 여부: ${_passwordController.text.isNotEmpty}');

        // 사용자 정보 업데이트 객체 생성
        final updatedUser = user.copyWith(
          name: _nameController.text,
          department: _selectedDepartment,
          grade: _selectedGrade,
        );

        debugPrint('업데이트될 사용자 정보: ${updatedUser.toJson()}');

        // 프로필 정보 업데이트
        final success = await authProvider.updateUser(updatedUser);

        // 비밀번호가 입력된 경우에만 업데이트
        if (_passwordController.text.isNotEmpty) {
          await SupabaseService.client.auth.updateUser(
            UserAttributes(password: _passwordController.text),
          );
        }

        debugPrint('업데이트 결과: $success');

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('프로필이 업데이트되었습니다')));
            context.pop();
          } else {
            final error = authProvider.errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error ?? '프로필 업데이트에 실패했습니다')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('업데이트 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }
}
