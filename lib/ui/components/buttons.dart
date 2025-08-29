import 'package:flutter/material.dart';
import 'package:echocall/theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool busy;
  final bool fullWidth;
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.busy = false, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final child = AnimatedContainer(
      duration: AppDurations.med,
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
      decoration: ShapeDecoration(
        color: busy ? cs.primary.withValues(alpha: 0.6) : cs.primary,
        shape: const StadiumBorder(),
        shadows: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        if (busy) ...[
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary)),
          const SizedBox(width: AppSpacing.s12),
        ] else if (icon != null) ...[
          Icon(icon, color: cs.onPrimary, size: 18),
          const SizedBox(width: AppSpacing.s8),
        ],
        Text(label, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: cs.onPrimary, letterSpacing: 0.3)),
      ]),
    );

    final btn = InkWell(
      onTap: busy ? null : onPressed,
      borderRadius: const BorderRadius.all(Radius.circular(32)),
      splashColor: Colors.white.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.06),
      child: child,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: Center(child: btn)) : btn;
  }
}

class SecondaryChip extends StatefulWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final ValueChanged<bool> onChanged;
  const SecondaryChip({super.key, required this.label, required this.selected, required this.onChanged, this.icon});

  @override
  State<SecondaryChip> createState() => _SecondaryChipState();
}

class _SecondaryChipState extends State<SecondaryChip> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseColor = widget.selected ? cs.primary : cs.surface;
    final onBase = widget.selected ? cs.onPrimary : cs.onSurface;
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.selected),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          decoration: ShapeDecoration(
            color: hovering && !widget.selected ? cs.surface.withValues(alpha: 0.8) : baseColor,
            shape: StadiumBorder(
                side: BorderSide(color: widget.selected ? baseColor : cs.outline.withValues(alpha: 0.6))
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 16, color: onBase),
              const SizedBox(width: 8),
            ],
            Text(widget.label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: onBase)),
          ]),
        ),
      ),
    );
  }
}

class InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  const InfoPill({super.key, required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = color ?? cs.primaryContainer;
    final on = cs.onPrimaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(shape: const StadiumBorder(), color: bg),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: on),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: on)),
      ]),
    );
  }
}
