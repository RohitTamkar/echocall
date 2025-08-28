import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:echocall/models/call_entry.dart';
import 'package:echocall/providers/call_log_store.dart';
import 'package:echocall/providers/filter_store.dart';
import 'package:echocall/providers/sync_store.dart';
import 'package:echocall/ui/components/buttons.dart';
import 'package:echocall/ui/components/call_list_item.dart';
import 'package:echocall/ui/components/empty_state.dart';
import 'package:echocall/theme.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool syncing = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CallLogStore, FilterStore, SyncStore>(
      builder: (context, store, filter, sync, _) {
        final sims = {for (final e in store.all) (e.simLabel ?? 'SIM')}.toList();
        final filtered = store.all.where(filter.matches).toList();
        return RefreshIndicator.adaptive(
          onRefresh: () => store.refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            children: [
              _SearchBar(ctrl: _searchCtrl, onChanged: (v) => filter.setQuery(v)),
              const SizedBox(height: AppSpacing.s12),
              _FilterRow(sims: sims),
              const SizedBox(height: AppSpacing.s16),
              if (store.loading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (filtered.isEmpty)
                EmptyState(
                  icon: Icons.call_outlined,
                  title: 'No calls match your filters',
                  message: 'Adjust your SIM/direction filters or clear search to see more calls.',
                  action: PrimaryButton(label: 'Clear filters', onPressed: () { filter.setSim(null); filter.setDirection(null); filter.setQuery(''); _searchCtrl.clear(); }),
                )
              else
                ...filtered.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                      child: CallListItem(entry: e, onTap: () => _showDetails(context, e)),
                    )),
              const SizedBox(height: AppSpacing.s32),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${filtered.length} calls', style: Theme.of(context).textTheme.labelMedium),
                PrimaryButton(
                  label: syncing ? 'Syncing…' : 'Sync to Firebase',
                  icon: Icons.cloud_upload_outlined,
                  busy: syncing,
                  onPressed: syncing ? () {} : () async {
                    setState(() => syncing = true);
                    final uploaded = await store.uploadAllUnsynced();
                    if (uploaded > 0) await context.read<SyncStore>().markSyncedNow();
                    setState(() => syncing = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded $uploaded records to Firebase')));
                    }
                  },
                )
              ])
            ],
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, CallEntryModel e) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('yyyy-MM-dd HH:mm');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.s16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primaryContainer), child: const Icon(Icons.call, color: Colors.blue)),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: Text(e.name ?? e.number, style: Theme.of(context).textTheme.titleLarge)),
            ]),
            const SizedBox(height: AppSpacing.s16),
            _kv('Number', e.number),
            _kv('Direction', e.direction.name),
            _kv('When', df.format(e.timestamp)),
            _kv('Duration', '${e.durationSeconds}s'),
            _kv('SIM', e.simLabel ?? 'Unknown'),
            _kv('Account Id', e.phoneAccountId ?? '-'),
            const SizedBox(height: AppSpacing.s16),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')))
          ]),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [SizedBox(width: 120, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))), Expanded(child: Text(v, softWrap: true))]),
      );
}

class _FilterRow extends StatelessWidget {
  final List<String> sims;
  const _FilterRow({required this.sims});

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<FilterStore>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        SecondaryChip(label: 'All SIMs', selected: filter.simLabel == null, onChanged: (s) => filter.setSim(null), icon: Icons.sim_card),
        const SizedBox(width: 8),
        ...sims.map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SecondaryChip(label: s, selected: filter.simLabel == s, onChanged: (v) => filter.setSim(v ? s : null), icon: Icons.sim_card_outlined),
            )),
        const SizedBox(width: AppSpacing.s16),
        SecondaryChip(label: 'All', selected: filter.direction == null, onChanged: (v) => context.read<FilterStore>().setDirection(null), icon: Icons.all_inclusive),
        const SizedBox(width: 8),
        SecondaryChip(label: 'Incoming', selected: filter.direction == CallDirection.incoming, onChanged: (v) => context.read<FilterStore>().setDirection(v ? CallDirection.incoming : null), icon: Icons.call_received),
        const SizedBox(width: 8),
        SecondaryChip(label: 'Outgoing', selected: filter.direction == CallDirection.outgoing, onChanged: (v) => context.read<FilterStore>().setDirection(v ? CallDirection.outgoing : null), icon: Icons.call_made),
        const SizedBox(width: 8),
        SecondaryChip(label: 'Missed', selected: filter.direction == CallDirection.missed, onChanged: (v) => context.read<FilterStore>().setDirection(v ? CallDirection.missed : null), icon: Icons.call_missed_outgoing),
      ]),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDurations.fast,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
      decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.light ? Colors.white : cs.surface, border: Border.all(color: cs.outline.withValues(alpha: 0.5)), borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Row(children: [
        const Icon(Icons.search, color: Colors.grey),
        const SizedBox(width: AppSpacing.s12),
        Expanded(child: TextField(controller: ctrl, onChanged: onChanged, decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search number or name'), textInputAction: TextInputAction.search)),
        GestureDetector(onTap: () { ctrl.clear(); onChanged(''); }, child: const Icon(Icons.clear, color: Colors.grey, size: 18)),
      ]),
    );
  }
}
