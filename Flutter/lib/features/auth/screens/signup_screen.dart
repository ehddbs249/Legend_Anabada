import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../app/routes/app_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreedToTerms = false;

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

  final List<String> _grades = [
    '1학년',
    '2학년',
    '3학년',
    '4학년',
    '대학원생',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.signUp),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기본 정보',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '이름 *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _studentIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '학번 *',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '학번을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // value: _selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: '학과 *',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: _departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // TODO: 백엔드 연동 시 선택된 학과 처리
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: '학년 *',
                    prefixIcon: Icon(Icons.grade_outlined),
                  ),
                  items: _grades.map((grade) {
                    return DropdownMenuItem(
                      value: grade,
                      child: Text(grade),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // TODO: 백엔드 연동 시 선택된 학년 처리
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  '계정 정보',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '대학교 이메일 *',
                    hintText: 'student@university.ac.kr',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!value.contains('@') || !value.contains('.ac.kr')) {
                      return '대학교 이메일을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '대학교 이메일로 인증 메일이 발송됩니다',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: '비밀번호 *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인 *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 다시 입력해주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                  title: const Text('이용약관 및 개인정보 처리방침에 동의합니다'),
                  subtitle: TextButton(
                    onPressed: () {
                      _showTermsDialog();
                    },
                    child: const Text('약관 보기'),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_isLoading || !_agreedToTerms) ? null : _handleSignup,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('회원가입'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('회원가입 완료'),
              content: const Text('인증 메일이 발송되었습니다.\n메일을 확인해주세요.'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.go(AppRoutes.home);
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('이용약관'),
          content: const SingleChildScrollView(
            child: Text(
              '아나바다 서비스 이용약관\n\n'
              '제1조 (목적)\n'
              '본 약관은 아나바다 서비스 이용에 관한 조건 및 절차를 규정함을 목적으로 합니다.\n\n'
              '제2조 (서비스 이용)\n'
              '1. 대학생 인증을 완료한 회원만 서비스를 이용할 수 있습니다.\n'
              '2. 교재 거래 시 포인트 시스템을 사용합니다.\n'
              '3. 사물함 이용 시간은 24시간으로 제한됩니다.\n\n'
              '제3조 (개인정보 보호)\n'
              '회원의 개인정보는 서비스 제공 목적으로만 사용되며, 안전하게 보호됩니다.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }
}