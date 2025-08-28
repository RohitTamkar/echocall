import 'package:flutter/material.dart';
import 'package:echocall/theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primaryContainer),
            child: Icon(icon, color: cs.onPrimaryContainer, size: 36),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s8),
          Text(message, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.7)), textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.s16),
            action!,
          ]
        ]),
      ),
    );
  }
}
