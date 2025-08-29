import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:echocall/models/call_group.dart';
import 'package:echocall/models/call_entry.dart';
import 'package:echocall/theme.dart';

class CallGroupItem extends StatelessWidget {
  final CallGroup group;
  final VoidCallback? onTap;

  const CallGroupItem({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            children: [
              Row(
                children: [
                  // Direction icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getDirectionColor(group.lastDirection).withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      _getDirectionIcon(group.lastDirection),
                      color: _getDirectionColor(group.lastDirection),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),

                  // Contact info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.contactName ?? group.number,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (group.contactName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            group.number,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (group.simLabel != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  group.simLabel!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              DateFormat('MMM d, HH:mm').format(group.lastCallTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Call count badge
                  if (group.callCount > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${group.callCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              if (group.callCount > 1) ...[
                const SizedBox(height: AppSpacing.s12),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (group.incomingCount > 0)
                        _StatChip(
                          icon: Icons.call_received,
                          count: group.incomingCount,
                          color: Colors.green,
                        ),
                      if (group.outgoingCount > 0)
                        _StatChip(
                          icon: Icons.call_made,
                          count: group.outgoingCount,
                          color: Colors.blue,
                        ),
                      if (group.missedCount > 0)
                        _StatChip(
                          icon: Icons.call_missed_outgoing,
                          count: group.missedCount,
                          color: Colors.red,
                        ),
                      if (group.totalDuration > 0)
                        _StatChip(
                          icon: Icons.schedule,
                          count: (group.totalDuration / 60).ceil(),
                          color: Colors.orange,
                          suffix: 'm',
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDirectionIcon(CallDirection direction) {
    switch (direction) {
      case CallDirection.incoming:
        return Icons.call_received;
      case CallDirection.outgoing:
        return Icons.call_made;
      case CallDirection.missed:
      case CallDirection.rejected:
        return Icons.call_missed_outgoing;
      case CallDirection.voicemail:
        return Icons.voicemail;
      case CallDirection.unknown:
      default:
        return Icons.call;
    }
  }

  Color _getDirectionColor(CallDirection direction) {
    switch (direction) {
      case CallDirection.incoming:
        return Colors.green;
      case CallDirection.outgoing:
        return Colors.blue;
      case CallDirection.missed:
      case CallDirection.rejected:
        return Colors.red;
      case CallDirection.voicemail:
        return Colors.purple;
      case CallDirection.unknown:
      default:
        return Colors.grey;
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final String suffix;

  const _StatChip({
    required this.icon,
    required this.count,
    required this.color,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$count$suffix',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}