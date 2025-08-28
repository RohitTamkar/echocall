import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echocall/providers/call_log_store.dart';
import 'package:echocall/ui/components/buttons.dart';
import 'package:echocall/theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CallLogStore>(builder: (context, store, _) {
      final total = store.all.length;
      final incoming = store.all.where((e) => e.direction.name == 'incoming').length;
      final outgoing = store.all.where((e) => e.direction.name == 'outgoing').length;
      final missed = store.all.where((e) => e.direction.name == 'missed').length;
      final secs = store.all.fold<int>(0, (p, e) => p + e.durationSeconds);
      final mins = (secs / 60).floor();

      return ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          _Header(),
          const SizedBox(height: AppSpacing.s16),
          Wrap(spacing: AppSpacing.s16, runSpacing: AppSpacing.s16, children: [
            _StatCard(title: 'Total calls', value: '$total', icon: Icons.call, color: Colors.blue),
            _StatCard(title: 'Incoming', value: '$incoming', icon: Icons.call_received, color: Colors.green),
            _StatCard(title: 'Outgoing', value: '$outgoing', icon: Icons.call_made, color: Colors.indigo),
            _StatCard(title: 'Missed', value: '$missed', icon: Icons.call_missed_outgoing, color: Colors.red),
            _StatCard(title: 'Talk time', value: '${mins}m', icon: Icons.schedule, color: Colors.orange),
          ]),
          const SizedBox(height: AppSpacing.s24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s12),
                Row(children: [
                  Expanded(child: PrimaryButton(label: 'Refresh logs', icon: Icons.refresh, onPressed: () => store.refresh())),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(child: PrimaryButton(label: 'Upload all', icon: Icons.cloud_upload_outlined, onPressed: () => store.uploadAllUnsynced())),
                ])
              ]),
            ),
          ),
        ],
      );
    });
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Theme.of(context).brightness == Brightness.light ? Colors.white : cs.surface,
        border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primaryContainer), child: Icon(Icons.analytics, color: cs.onPrimaryContainer)),
        const SizedBox(width: AppSpacing.s16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EchoCall', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Track and sync your call activity with ease', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
        ])),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title; final String value; final IconData icon; final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDurations.fast,
      padding: const EdgeInsets.all(AppSpacing.s16),
      width: (MediaQuery.of(context).size.width - (AppSpacing.s16 * 3)) / 2,
      decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.light ? Colors.white : cs.surface, borderRadius: const BorderRadius.all(Radius.circular(16)), border: Border.all(color: cs.outline.withValues(alpha: 0.4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(icon, color: color)),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
        ]),
        const SizedBox(height: AppSpacing.s8),
        Text(title, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
      ]),
    );
  }
}
