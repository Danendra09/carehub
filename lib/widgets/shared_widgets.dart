import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── CareHub Logo Widget ──────────────────────────────────────────────────────
class CareHubLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const CareHubLogo({super.key, this.size = 40, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Care',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: 'Hub',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyle.h3),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  factory StatusBadge.sehat() => const StatusBadge(
        label: 'SEHAT',
        color: AppColors.success,
        bgColor: AppColors.successLight,
      );

  factory StatusBadge.pemulihan() => const StatusBadge(
        label: 'PEMULIHAN',
        color: Color(0xFFF59E0B),
        bgColor: Color(0xFFFEF3C7),
      );

  factory StatusBadge.perhatian() => const StatusBadge(
        label: 'PERHATIAN',
        color: AppColors.danger,
        bgColor: AppColors.dangerLight,
      );

  factory StatusBadge.prioritas() => const StatusBadge(
        label: 'PRIORITAS',
        color: AppColors.danger,
        bgColor: AppColors.dangerLight,
      );

  factory StatusBadge.perluRestock() => const StatusBadge(
        label: 'PERLU RESTOCK',
        color: AppColors.danger,
        bgColor: AppColors.dangerLight,
      );

  factory StatusBadge.aman() => const StatusBadge(
        label: 'AMAN',
        color: AppColors.success,
        bgColor: AppColors.successLight,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── App Card ─────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Icon Box ─────────────────────────────────────────────────────────────────
class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;

  const IconBox({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

// ─── Custom App Bar ───────────────────────────────────────────────────────────
class CareHubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showAvatar;
  final String? avatarUrl;
  final Widget? leading;
  final List<Widget>? actions;
  final String? titleText;

  const CareHubAppBar({
    super.key,
    this.showAvatar = false,
    this.avatarUrl,
    this.leading,
    this.actions,
    this.titleText,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 20,
        right: 20,
      ),
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      child: Row(
        children: [
          leading ??
              Row(
                children: [
                  const CareHubLogo(size: 32),
                  if (titleText != null) ...[
                    const SizedBox(width: 8),
                    Text(titleText!, style: AppTextStyle.h3),
                  ],
                ],
              ),
          const Spacer(),
          ...?actions,
          if (showAvatar) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
          const SizedBox(width: 12),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary, size: 24),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon: icon, color: iconColor, bgColor: iconBg),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyle.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyle.h3.copyWith(fontSize: 20)),
        ],
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                  if (icon == null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─── Avatar Widget ────────────────────────────────────────────────────────────
class ChildAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  final Color? bgColor;

  const ChildAvatar({
    super.key,
    required this.initials,
    this.radius = 28,
    this.bgColor,
  });

  static const List<Color> _colors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
  ];

  Color _getColor() {
    if (bgColor != null) return bgColor!;
    int idx = initials.codeUnitAt(0) % _colors.length;
    return _colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _getColor().withOpacity(0.15),
      child: Text(
        initials,
        style: TextStyle(
          color: _getColor(),
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.5,
        ),
      ),
    );
  }
}
