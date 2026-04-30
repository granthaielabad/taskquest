import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/core/providers/theme_provider.dart';
import 'package:taskquest/core/providers/tutorial_provider.dart';

class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  bool _testAlignment = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final textScale = ref.watch(textScaleProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final fontStyle = ref.watch(fontStyleProvider);
    final themePreset = ref.watch(themePresetProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String scaleLabel = 'Default';
    if (textScale < 0.95) scaleLabel = 'Small';
    if (textScale > 1.05) scaleLabel = 'Large';

    double sliderValue = 1.0; // Default
    if (textScale < 0.95) sliderValue = 0.0; // Small
    if (textScale > 1.05) sliderValue = 2.0; // Large

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Appearance',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: colorScheme.outline, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const _SectionLabel(label: 'THEME MODE'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ThemeOption(
                          label: 'Light',
                          isSelected: themeMode == ThemeMode.light,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(ThemeMode.light),
                          child: const _ThemePreview(isDark: false),
                        ),
                        _ThemeOption(
                          label: 'Dark',
                          isSelected: themeMode == ThemeMode.dark,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(ThemeMode.dark),
                          child: const _ThemePreview(isDark: true),
                        ),
                        _ThemeOption(
                          label: 'System',
                          isSelected: themeMode == ThemeMode.system,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(ThemeMode.system),
                          child: const _ThemePreview(isSystem: true),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'THEME PALETTE'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _PaletteOption(
                            label: 'TaskQuest',
                            preset: ThemePreset.taskQuest,
                            colors: const [
                              AppTheme.white,
                              AppTheme.black,
                              AppTheme.backgroundDark,
                            ],
                            isSelected: themePreset == ThemePreset.taskQuest,
                            onTap: () => ref
                                .read(themePresetProvider.notifier)
                                .setPreset(ThemePreset.taskQuest),
                          ),
                          _PaletteOption(
                            label: 'Dracula',
                            preset: ThemePreset.dracula,
                            colors: const [
                              AppTheme.draculaPrimary,
                              AppTheme.draculaAccent,
                              AppTheme.draculaBg,
                            ],
                            isSelected: themePreset == ThemePreset.dracula,
                            onTap: () => ref
                                .read(themePresetProvider.notifier)
                                .setPreset(ThemePreset.dracula),
                          ),
                          _PaletteOption(
                            label: 'Monokai',
                            preset: ThemePreset.monokai,
                            colors: const [
                              AppTheme.monokaiPrimary,
                              AppTheme.monokaiAccent,
                              AppTheme.monokaiBg,
                            ],
                            isSelected: themePreset == ThemePreset.monokai,
                            onTap: () => ref
                                .read(themePresetProvider.notifier)
                                .setPreset(ThemePreset.monokai),
                          ),
                          _PaletteOption(
                            label: 'Cyberpunk',
                            preset: ThemePreset.cyberpunk,
                            colors: const [
                              AppTheme.cyberpunkPrimary,
                              AppTheme.cyberpunkAccent,
                              AppTheme.cyberpunkBg,
                            ],
                            isSelected: themePreset == ThemePreset.cyberpunk,
                            onTap: () => ref
                                .read(themePresetProvider.notifier)
                                .setPreset(ThemePreset.cyberpunk),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'FONT STYLE'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _FontOption(
                            label: 'Syne / DM Mono',
                            isSelected: fontStyle == 'Syne / DM Mono',
                            onTap: () => ref
                                .read(fontStyleProvider.notifier)
                                .setFontStyle('Syne / DM Mono'),
                          ),
                          Divider(color: colorScheme.outline, height: 1),
                          _FontOption(
                            label: 'System Default',
                            isSelected: fontStyle == 'System Default',
                            onTap: () => ref
                                .read(fontStyleProvider.notifier)
                                .setFontStyle('System Default'),
                          ),
                          Divider(color: colorScheme.outline, height: 1),
                          _FontOption(
                            label: 'Serif',
                            isSelected: fontStyle == 'Serif',
                            onTap: () => ref
                                .read(fontStyleProvider.notifier)
                                .setFontStyle('Serif'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'DISPLAY SETTINGS'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _DisplayToggle(
                            label: 'Reduce Motion',
                            desc: 'Minimize UI animations',
                            value: reduceMotion,
                            onChanged: (v) {
                              ref
                                  .read(reduceMotionProvider.notifier)
                                  .setReduceMotion(v);
                            },
                          ),
                          Divider(color: colorScheme.outline, height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Text Size',
                                      style: TextStyle(
                                        fontFamily: 'Syne',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      scaleLabel,
                                      style: TextStyle(
                                        fontFamily: 'DM Mono',
                                        fontSize: 10,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: colorScheme.primary,
                                    inactiveTrackColor: colorScheme.outline,
                                    thumbColor: colorScheme.primary,
                                    overlayColor: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: sliderValue,
                                    min: 0,
                                    max: 2,
                                    divisions: 2,
                                    onChanged: (v) {
                                      double newScale = 1.0;
                                      if (v == 0) newScale = 0.85;
                                      if (v == 2) newScale = 1.2;
                                      ref
                                          .read(textScaleProvider.notifier)
                                          .setTextScale(newScale);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'ANIMATION PREVIEW'),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _testAlignment = !_testAlignment),
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: reduceMotion
                                  ? Duration.zero
                                  : const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                              alignment: _testAlignment
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.bolt,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const Center(
                              child: Text(
                                'TAP TO TEST MOTION',
                                style: TextStyle(
                                  fontFamily: 'DM Mono',
                                  fontSize: 9,
                                  letterSpacing: 1.0,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'APP GUIDE'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () async {
                          await ref
                              .read(walkthroughProvider.notifier)
                              .resetWalkthrough();
                          ref
                              .read(navigationIndexProvider.notifier)
                              .setIndex(0);
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Walkthrough reset! Returning home...',
                                ),
                                backgroundColor: Colors.black,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.refresh_rounded, size: 20),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Restart User Walkthrough',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteOption extends StatelessWidget {
  final String label;
  final ThemePreset preset;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteOption({
    required this.label,
    required this.preset,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: colors[2], // Background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors[0] : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[0],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[1],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'DM Mono',
        fontSize: 10,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: (MediaQuery.of(context).size.width - 64) / 3,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: child,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final bool isDark;
  final bool isSystem;

  const _ThemePreview({this.isDark = false, this.isSystem = false});

  @override
  Widget build(BuildContext context) {
    if (isSystem) {
      return Row(
        children: [
          Expanded(child: Container(color: AppTheme.backgroundLight)),
          Expanded(child: Container(color: AppTheme.backgroundDark)),
        ],
      );
    }
    return Container(
      color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
    );
  }
}

class _DisplayToggle extends StatelessWidget {
  final String label;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DisplayToggle({
    required this.label,
    required this.desc,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _FontOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
