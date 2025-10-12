import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../constants/app_animations.dart';

/// 향상된 폼 위젯들
/// 일관된 디자인과 향상된 사용자 경험을 제공

/// 프리미엄 텍스트 필드
class PremiumTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final FocusNode? focusNode;

  const PremiumTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: AppColors.divider,
      end: AppColors.primary,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: AppAnimations.easeOut),
    );

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.withColor(
              hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        // 텍스트 필드
        AnimatedBuilder(
          animation: _borderColorAnimation,
          builder: (context, child) {
            return TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              onFieldSubmitted: widget.onSubmitted,
              validator: widget.validator,
              autofocus: widget.autofocus,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.placeholder,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        size: 20,
                      )
                    : null,
                suffixIcon: widget.suffixIcon,
                filled: true,
                fillColor: widget.enabled
                    ? (hasError ? AppColors.errorSoft : AppColors.surfaceVariant)
                    : AppColors.textQuaternary.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.error : AppColors.divider,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.error : _borderColorAnimation.value!,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: const BorderSide(color: AppColors.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                counterText: '', // 카운터 텍스트 숨김
              ),
            );
          },
        ),
        // 헬퍼 텍스트 또는 에러 메시지
        if (widget.helperText != null || widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.errorText ?? widget.helperText!,
            style: AppTypography.bodySmall.withColor(
              hasError ? AppColors.error : AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// 드롭다운 선택 위젯
class PremiumDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final String? errorText;
  final IconData? prefixIcon;

  const PremiumDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.withColor(
              hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? (hasError ? AppColors.errorSoft : AppColors.surfaceVariant)
                : AppColors.textQuaternary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.divider,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.placeholder,
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.textTertiary,
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
            ),
            style: AppTypography.bodyMedium,
            dropdownColor: AppColors.surface,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorText!,
            style: AppTypography.bodySmall.withColor(AppColors.error),
          ),
        ],
      ],
    );
  }
}

/// 체크박스 위젯
class PremiumCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final String? subtitle;
  final bool enabled;

  const PremiumCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      child: Padding(
        padding: AppPadding.small,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.withColor(
                      enabled ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.withColor(
                        enabled ? AppColors.textSecondary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 라디오 버튼 그룹
class PremiumRadioGroup<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<PremiumRadioOption<T>> options;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final Axis direction;

  const PremiumRadioGroup({
    super.key,
    this.label,
    this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.withColor(AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        direction == Axis.vertical
            ? Column(
                children: options
                    .map((option) => _buildRadioItem(option))
                    .toList(),
              )
            : Row(
                children: options
                    .map((option) => Expanded(
                          child: _buildRadioItem(option),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildRadioItem(PremiumRadioOption<T> option) {
    final isSelected = value == option.value;

    return InkWell(
      onTap: enabled ? () => onChanged(option.value) : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      child: Padding(
        padding: AppPadding.small,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: AppTypography.bodyMedium.withColor(
                      enabled ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle!,
                      style: AppTypography.bodySmall.withColor(
                        enabled ? AppColors.textSecondary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumRadioOption<T> {
  final T value;
  final String label;
  final String? subtitle;

  const PremiumRadioOption({
    required this.value,
    required this.label,
    this.subtitle,
  });
}

/// 슬라이더 위젯
class PremiumSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double> onChanged;
  final String Function(double)? valueFormatter;

  const PremiumSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    required this.onChanged,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: AppTypography.labelMedium.withColor(AppColors.textSecondary),
              ),
              Text(
                valueFormatter?.call(value) ?? value.round().toString(),
                style: AppTypography.labelMedium.withColor(AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            trackHeight: 6,
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: AppTypography.bodySmall.withColor(Colors.white),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            label: valueFormatter?.call(value) ?? value.round().toString(),
          ),
        ),
      ],
    );
  }
}

/// 파일 선택 위젯
class FilePickerWidget extends StatelessWidget {
  final String? label;
  final String? selectedFileName;
  final VoidCallback onTap;
  final IconData icon;
  final String buttonText;
  final String? helperText;

  const FilePickerWidget({
    super.key,
    this.label,
    this.selectedFileName,
    required this.onTap,
    this.icon = Icons.upload_file,
    this.buttonText = '파일 선택',
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.withColor(AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: AppPadding.medium,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                if (selectedFileName != null)
                  Text(
                    selectedFileName!,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    buttonText,
                    style: AppTypography.bodyMedium.withColor(AppColors.primary),
                  ),
                if (helperText != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    helperText!,
                    style: AppTypography.bodySmall.withColor(AppColors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}