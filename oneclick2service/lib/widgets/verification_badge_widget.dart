import 'package:flutter/material.dart';

enum VerificationLevel {
  basic,
  verified,
  premium,
  expert;

  String getLevelDescription() {
    switch (this) {
      case VerificationLevel.basic:
        return 'Basic verification completed';
      case VerificationLevel.verified:
        return 'Background check verified';
      case VerificationLevel.premium:
        return 'Premium service provider';
      case VerificationLevel.expert:
        return 'Expert level certified';
    }
  }

  String getLevelRequirements() {
    switch (this) {
      case VerificationLevel.basic:
        return '• Phone verification\n• Basic profile completion';
      case VerificationLevel.verified:
        return '• Background check passed\n• ID verification\n• Address verification';
      case VerificationLevel.premium:
        return '• 4.5+ average rating\n• 50+ completed services\n• Premium certification';
      case VerificationLevel.expert:
        return '• 4.8+ average rating\n• 100+ completed services\n• Expert certification\n• Specialized training';
    }
  }
}

class VerificationBadgeWidget extends StatelessWidget {
  final VerificationLevel level;
  final String? badgeText;
  final VoidCallback? onTap;
  final bool showDetails;

  const VerificationBadgeWidget({
    Key? key,
    required this.level,
    this.badgeText,
    this.onTap,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getBadgeColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getBorderColor(), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getBadgeIcon(), size: 16, color: _getIconColor()),
            if (badgeText != null) ...[
              const SizedBox(width: 4),
              Text(
                badgeText!,
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (showDetails) ...[
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 12, color: _getIconColor()),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor() {
    switch (level) {
      case VerificationLevel.basic:
        return Colors.grey.shade100;
      case VerificationLevel.verified:
        return Colors.blue.shade50;
      case VerificationLevel.premium:
        return Colors.amber.shade50;
      case VerificationLevel.expert:
        return Colors.purple.shade50;
    }
  }

  Color _getBorderColor() {
    switch (level) {
      case VerificationLevel.basic:
        return Colors.grey.shade300;
      case VerificationLevel.verified:
        return Colors.blue.shade300;
      case VerificationLevel.premium:
        return Colors.amber.shade300;
      case VerificationLevel.expert:
        return Colors.purple.shade300;
    }
  }

  Color _getIconColor() {
    switch (level) {
      case VerificationLevel.basic:
        return Colors.grey.shade600;
      case VerificationLevel.verified:
        return Colors.blue.shade600;
      case VerificationLevel.premium:
        return Colors.amber.shade600;
      case VerificationLevel.expert:
        return Colors.purple.shade600;
    }
  }

  Color _getTextColor() {
    switch (level) {
      case VerificationLevel.basic:
        return Colors.grey.shade700;
      case VerificationLevel.verified:
        return Colors.blue.shade700;
      case VerificationLevel.premium:
        return Colors.amber.shade700;
      case VerificationLevel.expert:
        return Colors.purple.shade700;
    }
  }

  IconData _getBadgeIcon() {
    switch (level) {
      case VerificationLevel.basic:
        return Icons.check_circle_outline;
      case VerificationLevel.verified:
        return Icons.verified;
      case VerificationLevel.premium:
        return Icons.star;
      case VerificationLevel.expert:
        return Icons.workspace_premium;
    }
  }
}
