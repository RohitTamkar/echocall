import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echocall/models/call_entry.dart';
import 'package:echocall/providers/call_log_store.dart';
import 'package:echocall/ui/components/buttons.dart';
import 'package:echocall/theme.dart';
import 'package:echocall/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Set<String>> _getEnabledSims() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('enabled_sims') ?? []).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallLogStore>(builder: (context, store, _) {
      return FutureBuilder<Set<String>>(
        future: _getEnabledSims(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final enabledSims = snapshot.data!;
          // 🔹 Filter call logs only for enabled SIMs
          final filtered = store.all.where((e) => enabledSims.contains(e.simLabel)).toList();

          final total = filtered.length;
          final incoming = filtered.where((e) => e.direction == CallDirection.incoming).length;
          final outgoing = filtered.where((e) => e.direction == CallDirection.outgoing).length;
          final missed = filtered.where((e) => e.direction == CallDirection.missed).length;
          final secs = filtered.fold<int>(0, (p, e) => p + e.durationSeconds);
          final mins = (secs / 60).floor();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            children: [
              _Header(),
              const SizedBox(height: AppSpacing.s16),
              Wrap(
                spacing: AppSpacing.s16,
                runSpacing: AppSpacing.s16,
                children: [
                  _StatCard(title: 'Total calls', value: '$total', icon: Icons.call, color: Colors.blue),
                  _StatCard(title: 'Incoming', value: '$incoming', icon: Icons.call_received, color: Colors.green),
                  _StatCard(title: 'Outgoing', value: '$outgoing', icon: Icons.call_made, color: Colors.indigo),
                  _StatCard(title: 'Missed', value: '$missed', icon: Icons.call_missed_outgoing, color: Colors.red),
                  _StatCard(title: 'Talk time', value: '${mins}m', icon: Icons.schedule, color: Colors.orange),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: 'Refresh logs',
                              icon: Icons.refresh,
                              onPressed: () => store.refresh(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Upload all',
                              icon: Icons.cloud_upload_outlined,
                              onPressed: () => store.uploadAllUnsynced(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class _Header extends StatefulWidget {
  @override
  State<_Header> createState() => _HeaderState();
}


class _HeaderState extends State<_Header> {
  String? mobile;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadMobile();
  }

  Future<void> _loadMobile() async {
    final number = await AuthService().getLoggedInMobileNo();
    var name=await AuthService().getLoggedInUserName();
    if (mounted) {
      setState(() {
        mobile = number;
        userName=name;
      });
    }
  }
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
          Row(
            children: [
              Text(
                "$userName",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (mobile != null) ...[
            const SizedBox(width: 8),
            Text(
              "($mobile)",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: cs.primary),
            ),
          ],
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
