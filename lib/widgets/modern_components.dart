import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Modern Button with gradient and loading state
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isPrimary;
  final bool isFullWidth;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isPrimary = true,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ..[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text, style: AppTheme.labelLarge.copyWith(color: Colors.white)),
            ],
          );

    if (isPrimary) {
      return Container(
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.shadowSm,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ),
          child: content,
        ),
      );
    } else {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: AppTheme.secondaryButton,
          child: content,
        ),
      );
    }
  }
}

/// Modern Card with hover effects
class ModernCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool isHoverable;

  const ModernCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.isHoverable = true,
  }) : super(key: key);

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: _isHovered && widget.isHoverable
              ? AppTheme.cardDecorationHover
              : AppTheme.cardDecoration,
          padding: widget.padding ?? const EdgeInsets.all(AppTheme.space6),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Stats Card with icon and number
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? trend;
  final bool isPositiveTrend;

  const StatsCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
    this.isPositiveTrend = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryPurple;

    return ModernCard(
      isHoverable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, color: effectiveColor, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositiveTrend
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: isPositiveTrend ? AppTheme.success : AppTheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: AppTheme.labelSmall.copyWith(
                          color: isPositiveTrend ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          Text(value, style: AppTheme.displaySmall),
          const SizedBox(height: AppTheme.space1),
          Text(label, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Progress Bar
class ModernProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  const ModernProgressBar({
    Key? key,
    required this.progress,
    this.height = 8,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color ?? AppTheme.primaryPurple,
                (color ?? AppTheme.primaryPurple).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: (color ?? AppTheme.primaryPurple).withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge/Chip
class ModernBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onDelete;

  const ModernBadge({
    Key? key,
    required this.label,
    this.color,
    this.icon,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryPurple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: effectiveColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ..[
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(color: effectiveColor),
          ),
          if (onDelete != null) ..[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 14, color: effectiveColor),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty State
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.primaryPurple.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppTheme.space6),
            Text(title, style: AppTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.space3),
            Text(
              description,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            if (actionText != null && onAction != null) ..[
              const SizedBox(height: AppTheme.space6),
              ModernButton(
                text: actionText!,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section Header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.headlineSmall),
                if (subtitle != null) ..[
                  const SizedBox(height: AppTheme.space1),
                  Text(subtitle!, style: AppTheme.bodyMedium),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Loading Overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: ModernCard(
                padding: const EdgeInsets.all(AppTheme.space6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ..[
                      const SizedBox(height: AppTheme.space4),
                      Text(message!, style: AppTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
