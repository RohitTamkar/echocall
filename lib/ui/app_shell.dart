import 'package:echocall/ui/pages/FirebaseLogsPage.dart';
import 'package:echocall/ui/pages/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:echocall/theme.dart';
import 'package:echocall/ui/pages/dashboard_page.dart';
import 'package:echocall/ui/pages/logs_page.dart';
import 'package:echocall/ui/pages/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int idx = 1;
  late final AnimationController _controller = AnimationController(vsync: this, duration: AppDurations.med)..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _pageFor(int i) {
    switch (i) {
      case 0:
        return const DashboardPage();
      case 1:
        return const LogsPage();
      case 2:
        return const SettingsPage();
      default:
        return const LogsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: idx == 1
            ? GestureDetector(
          onLongPress: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          },
          child: Text(
            "Logs",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        )
            : Text(
          ['Dashboard', 'Logs', 'Settings'][idx],
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: AnimatedSwitcher(
        duration: AppDurations.med,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _pageFor(idx),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.s16),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.light ? Colors.white : cs.surface, borderRadius: const BorderRadius.all(Radius.circular(20)), border: Border.all(color: cs.outline.withValues(alpha: 0.4))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _NavItem(icon: Icons.analytics_outlined, label: 'Dashboard', selected: idx==0, onTap: () => setState(()=>idx=0)),
            _NavItem(icon: Icons.call, label: 'Logs', selected: idx==1, onTap: () => setState(()=>idx=1)),
            _NavItem(icon: Icons.settings_outlined, label: 'Settings', selected: idx==2, onTap: () => setState(()=>idx=2)),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final bool selected; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: selected ? cs.primary.withValues(alpha: 0.12) : Colors.transparent),
        child: Row(children: [
          Icon(icon, color: selected ? cs.primary : Colors.grey),
          const SizedBox(width: 8),
          AnimatedSize(
            duration: AppDurations.fast,
            child: selected ? Text(label, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: cs.primary)) : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}
