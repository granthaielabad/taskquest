import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String selectedTheme = 'Light';
  bool syncWithSystem = false;
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
    return Scaffold(
      backgroundColor: AppTheme.background,
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
                          isSelected: selectedTheme == 'Light',
                          onTap: () => setState(() => selectedTheme = 'Light'),
                          child: _ThemePreview(isDark: false),
                        ),
                        _ThemeOption(
                          label: 'Dark',
                          isSelected: selectedTheme == 'Dark',
                          onTap: () => setState(() => selectedTheme = 'Dark'),
                          child: _ThemePreview(isDark: true),
                        ),
                        _ThemeOption(
                          label: 'System',
                          isSelected: selectedTheme == 'System',
                          onTap: () => setState(() => selectedTheme = 'System'),
                          child: _ThemePreview(isSystem: true),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _SettingsGroup(
                      children: [
                        _SwitchTile(
                          title: 'Sync with System',
                          subtitle: 'Auto-switch with device dark mode',
                          value: syncWithSystem,
                          onChanged: (v) => setState(() => syncWithSystem = v),
                        ),
                        const Divider(color: AppTheme.border, height: 1),
                        _SwitchTile(
                          title: 'Reduce Motion',
                          subtitle: 'Minimize animations and transitions',
                          value: reduceMotion,
                          onChanged: (v) => setState(() => reduceMotion = v),
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'TEXT SIZE'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('A', style: TextStyle(fontSize: 12, color: AppTheme.dimmed)),
                              Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.black)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.black,
                              inactiveTrackColor: AppTheme.border,
                              thumbColor: AppTheme.black,
                              overlayColor: AppTheme.black.withOpacity(0.1),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: textSize,
                              onChanged: (v) => setState(() => textSize = v),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Small', style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.muted)),
                              Text('Medium', style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.black, fontWeight: FontWeight.bold)),
                              Text('Large', style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'ACCENT COLOUR'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(accentColors.length, (i) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedAccent = i),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: accentColors[i],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedAccent == i ? AppTheme.black : AppTheme.border,
                                  width: selectedAccent == i ? 2 : 1,
                                ),
                              ),
                            ),
                          );
                        }),
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

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.black)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.black,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _ThemeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppTheme.black : AppTheme.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: child,
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppTheme.black, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontFamily: 'Syne', fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 13, color: AppTheme.black)),
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
          Expanded(child: Container(color: const Color(0xFF262626))),
        ],
      );
    }
    return Container(
      color: isDark ? const Color(0xFF262626) : const Color(0xFFF7F6F2),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 6, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(3))),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 20, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.white, borderRadius: BorderRadius.circular(4))),
          const Spacer(),
          Row(
            children: [
              Container(width: 30, height: 16, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.white, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 8),
              Container(width: 30, height: 16, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black, borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ],
      ),
    );
  }
}
