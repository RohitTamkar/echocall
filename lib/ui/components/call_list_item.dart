import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:echocall/theme.dart';
import 'package:echocall/models/call_entry.dart';

class CallListItem extends StatelessWidget {
  final CallEntryModel entry;
  final VoidCallback onTap;
  const CallListItem({super.key, required this.entry, required this.onTap});

  Color _typeColor(BuildContext context) {
    switch (entry.direction) {
      case CallDirection.incoming:
        return Colors.green;
      case CallDirection.outgoing:
        return Colors.blue;
      case CallDirection.missed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _typeIcon() {
    switch (entry.direction) {
      case CallDirection.incoming:
        return Icons.call_received;
      case CallDirection.outgoing:
        return Icons.call_made;
      case CallDirection.missed:
        return Icons.call_missed;
      case CallDirection.rejected:
        return Icons.call_end;
      default:
        return Icons.call;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date = DateFormat('EEE, MMM d • hh:mm a').format(entry.timestamp);
    final dur = Duration(seconds: entry.durationSeconds);
    final durStr = dur.inMinutes > 0 ? '${dur.inMinutes}m ${dur.inSeconds % 60}s' : '${dur.inSeconds}s';
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.r16)),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.r16)),
          border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _typeColor(context).withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(_typeIcon(), color: _typeColor(context)),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.name ?? entry.number, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(date, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.7)), overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          const SizedBox(width: AppSpacing.s16),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: ShapeDecoration(shape: const StadiumBorder(), color: cs.primaryContainer),
              child: Text(entry.simLabel ?? 'SIM', style: Theme.of(context).textTheme.labelSmall!.copyWith(color: cs.onPrimaryContainer)),
            ),
            const SizedBox(height: 8),
            Text(durStr, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.8))),
          ])
        ]),
      ),
    );
  }
}
