import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echocall/constants/app_constants.dart';
import 'package:echocall/constants/firebase_collections.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echocall/providers/sync_store.dart';
import 'package:echocall/providers/settings_store.dart';
import 'package:echocall/providers/call_log_store.dart';
import 'package:echocall/services/permission_service.dart';
import 'package:echocall/theme.dart';
import 'package:echocall/auth_service.dart';
import 'package:echocall/ui/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool checking = false;
  bool phoneGranted = false;
  final List<String> _departments = [
    '',
    "Software",
    "Account",
    "Sales",
    "Software Support",
    "Hardware Support",
    "HR",
  ];

  List<String> _names = ['']; // Will be fetched from Firestore

  String _name = '';
  String _department = '';
  bool _loadingPrefs = true;
  bool _loadingNames = true;

  @override
  void initState() {
    super.initState();
    _check();
    _loadPrefs();
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    try {
      // 🔹 Fetch only active team members
      final query = await FirebaseFirestore.instance
          .collection(FirebaseCollectionsConstants.outlet)
          .doc(AppConstants.outletId)
          .collection(FirebaseCollectionsConstants.teamTree)
          .where('isActive', isEqualTo: true)
          .get();

      final names = query.docs
          .map((doc) => doc.data()['userName']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet() // remove duplicates
          .toList()
        ..sort();

      setState(() {
        _names = [''] + names; // include an empty option
        _loadingNames = false;
      });
    } catch (e) {
      debugPrint('Error fetching active team members: $e');
      setState(() => _loadingNames = false);
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString("name") ?? '';
      _department = prefs.getString("department") ?? '';
      _loadingPrefs = false;
    });
  }

  Future<void> _updatePrefs({String? name, String? department}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString("name", name);
    if (department != null) await prefs.setString("department", department);
  }

  Future<void> _check() async {
    setState(() => checking = true);
    phoneGranted = await PermissionService().hasPhonePermission();
    setState(() => checking = false);
  }

  Future<void> _logout(BuildContext context) async {
    // Example: clear session if using SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    final auth = AuthService();
    await auth.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    // If you manage auth state via Provider:
    // context.read<AuthStore>().logout();

    // Navigate back to login screen
    // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncStore>();
    final settings = context.watch<SettingsStore>();
    final callStore = context.watch<CallLogStore>();
    final cs = Theme.of(context).colorScheme;

    // Get available SIM cards
    final availableSims = callStore.all
        .map((e) => e.simLabel ?? 'Unknown')
        .toSet()
        .toList()
      ..sort();

    return ListView(padding: const EdgeInsets.all(AppSpacing.s16), children: [
      if (!Platform.isAndroid)
        _TileCard(
          title: 'Platform not supported',
          subtitle:
              'iOS does not allow accessing call logs. Android is required for call log features.',
          leading: Icons.info_outline,
          color: Colors.orange,
        ),
      _TileCard(
        title: 'Permissions',
        subtitle: phoneGranted
            ? 'Phone permissions granted'
            : 'Phone permissions are required to read call logs and detect call events.',
        leading: phoneGranted ? Icons.verified_user : Icons.lock_outline,
        action: TextButton(
            onPressed: () async {
              await PermissionService().ensureCorePermissions();
              _check();
            },
            child: Text(phoneGranted ? 'Re-check' : 'Grant')),
      ),
      const SizedBox(height: AppSpacing.s16),

      // SIM Card Selection
      if (availableSims.isNotEmpty && settings.loaded) ...[
        _CardWrap(children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            title: Text('SIM Card Settings',
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
                '${settings.enabledSims.isEmpty ? availableSims.length : settings.enabledSims.length} of ${availableSims.length} SIMs enabled'),
            leading: const Icon(Icons.sim_card),
          ),
          ...availableSims.map((sim) => _SwitchTile(
                title: sim,
                value: settings.isSimEnabled(sim),
                onChanged: (_) => settings.toggleSim(sim),
              )),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => settings.enableAllSims(availableSims),
                    child: const Text('Enable All'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => settings.disableAllSims(),
                    child: const Text('Disable All'),
                  ),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.s16),
      ],

      _CardWrap(children: [
        _SwitchTile(
          title: 'Group calls by number',
          value: settings.groupByNumber,
          onChanged: settings.setGroupByNumber,
        ),
        _SwitchTile(
            title: 'Auto-sync on call end',
            value: sync.autoSync,
            onChanged: sync.setAutoSync),
        _SwitchTile(
            title: 'Sync on Wi-Fi only',
            value: sync.wifiOnly,
            onChanged: sync.setWifiOnly),
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          title: const Text('Last sync time'),
          subtitle: Text(sync.lastSync?.toLocal().toString() ?? 'Never'),
          leading: const Icon(Icons.history),
        )
      ]),
      const SizedBox(height: AppSpacing.s16),
      _CardWrap(children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          title: Text('User Information',
              style: Theme.of(context).textTheme.titleMedium),
          leading: const Icon(Icons.person_outline),
        ),
        if (_loadingPrefs || _loadingNames)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.s16),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _names.contains(_name) ? _name : '',
              items: _names
                  .map((n) => DropdownMenuItem(
                        value: n,
                        child: Text(n.isEmpty ? 'Select User' : n),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _name = value);
                  _updatePrefs(name: value);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _departments.contains(_department) ? _department : '',
              items: _departments
                  .map((dept) => DropdownMenuItem(
                        value: dept,
                        child: Text(dept.isEmpty ? 'Select Department' : dept),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _department = value);
                  _updatePrefs(department: value);
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ]),

      const SizedBox(height: AppSpacing.s16),
      // 🔹 Logout Button
      _TileCard(
        title: 'Logout',
        subtitle: 'Sign out from this device',
        leading: Icons.logout,
        color: Colors.red,
        action: TextButton(
          onPressed: () => _logout(context),
          child: const Text('Logout'),
        ),
      ),
    ]);
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile(
      {required this.title, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
      );
}

class _TileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leading;
  final Widget? action;
  final Color? color;
  const _TileCard(
      {required this.title,
      required this.subtitle,
      required this.leading,
      this.action,
      this.color});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : cs.surface,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: cs.outline.withValues(alpha: 0.4))),
      child: Row(children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (color ?? cs.primary).withValues(alpha: 0.12)),
            child: Icon(leading, color: color ?? cs.primary)),
        const SizedBox(width: AppSpacing.s16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
        ])),
        if (action != null) action!,
      ]),
    );
  }
}

class _CardWrap extends StatelessWidget {
  final List<Widget> children;
  const _CardWrap({required this.children});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : cs.surface,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: cs.outline.withValues(alpha: 0.4))),
      child: Column(children: children),
    );
  }
}
