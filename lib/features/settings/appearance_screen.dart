import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/core/providers/theme_provider.dart';

class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  bool reduceMotion = false;
  double textSize = 0.5;
  int selectedAccent = 0;

  final List<Color> accentColors = [
    Colors.black,
    const Color(0xFF4A8BFF),
    const Color(0xFF00C853),
    const Color(0xFFFFAB00),
    const Color(0xFFFF5252),
    const Color(0xFF7C4DFF),
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chevron_left_rounded, color: AppTheme.black),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      letterSpacing: -0.5,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.border, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const _SectionLabel(label: 'THEME'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ThemeOption(
                          label: 'Light',
                          isSelected: themeMode == ThemeMode.light,
                          onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light),
                          child: _ThemePreview(isDark: false),
                        ),
                        _ThemeOption(
                          label: 'Dark',
                          isSelected: themeMode == ThemeMode.dark,
                          onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark),
                          child: _ThemePreview(isDark: true),
                        ),
                        _ThemeOption(
                          label: 'System',
                          isSelected: themeMode == ThemeMode.system,
                          onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system),
                          child: _ThemePreview(isSystem: true),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'ACCENT COLOR'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: accentColors.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final isSelected = selectedAccent == index;
                          return GestureDetector(
                            onTap: () => setState(() => selectedAccent = index),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accentColors[index],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppTheme.black : AppTheme.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: isSelected 
                                ? Icon(Icons.check, color: accentColors[index].computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 20)
                                : null,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'DISPLAY SETTINGS'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _DisplayToggle(
                            label: 'Reduce Motion',
                            desc: 'Minimize UI animations',
                            value: reduceMotion,
                            onChanged: (v) => setState(() => reduceMotion = v),
                          ),
                          const Divider(color: AppTheme.border, height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Text Size', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14)),
                                    Text('Default', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: AppTheme.black,
                                    inactiveTrackColor: AppTheme.background,
                                    thumbColor: AppTheme.black,
                                    overlayColor: AppTheme.black.withValues(alpha: 0.1),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: textSize,
                                    onChanged: (v) => setState(() => textSize = v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'DM Mono',
        fontSize: 10,
        letterSpacing: 1.2,
        color: AppTheme.muted,
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: (MediaQuery.of(context).size.width - 64) / 3,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(
                color: isSelected ? AppTheme.black : AppTheme.border,
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
              color: isSelected ? AppTheme.black : AppTheme.muted,
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
          Expanded(child: Container(color: const Color(0xFFF7F6F2))),
          Expanded(child: Container(color: const Color(0xFF0A0A0A))),
        ],
      );
    }
    return Container(color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF7F6F2));
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.muted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.black,
            activeTrackColor: AppTheme.black.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}
