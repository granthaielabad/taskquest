import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.5,
                      color: AppTheme.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
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
                    
                    // Profile Header Section
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text('JD', 
                                  style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 32, color: Colors.white)),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.white, width: 2),
                                ),
                                child: const Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Juan dela Cruz', 
                                style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.black)),
                              const Text('@juan', 
                                style: TextStyle(fontFamily: 'DM Mono', fontSize: 12, color: AppTheme.muted)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _ColorOption(color: Colors.black, isSelected: true),
                                  _ColorOption(color: Colors.blueGrey.shade800),
                                  _ColorOption(color: Colors.deepPurple.shade900),
                                  _ColorOption(color: Colors.teal.shade900),
                                  _ColorOption(color: Colors.brown.shade900),
                                  _ColorOption(color: Colors.grey.shade900),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'PERSONAL INFO'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: const [
                          _EditField(label: 'DISPLAY NAME', value: 'Juan dela Cruz'),
                          Divider(color: AppTheme.border, height: 1),
                          _EditField(label: 'USERNAME', value: '@juan'),
                          Divider(color: AppTheme.border, height: 1),
                          _EditField(label: 'EMAIL ADDRESS', value: 'juan@taskquest.app'),
                          Divider(color: AppTheme.border, height: 1),
                          _EditField(label: 'BIO', value: 'Add a short bio...', isPlaceholder: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'LEARNING PROFILE'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: const [
                          _EditField(label: 'SCHOOL / INSTITUTION', value: 'PLM Manila'),
                          Divider(color: AppTheme.border, height: 1),
                          _EditField(label: 'COURSE / PROGRAM', value: 'BS Computer Science'),
                          Divider(color: AppTheme.border, height: 1),
                          _EditField(label: 'YEAR LEVEL', value: '3rd Year', hasArrow: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'DANGER ZONE'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        border: Border.all(color: const Color(0xFFFFE0E0)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Delete Account',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Colors.red, size: 20),
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

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  const _ColorOption({required this.color, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: isSelected ? Border.all(color: AppTheme.black, width: 2) : null,
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

class _EditField extends StatelessWidget {
  final String label;
  final String value;
  final bool isPlaceholder;
  final bool hasArrow;

  const _EditField({
    required this.label,
    required this.value,
    this.isPlaceholder = false,
    this.hasArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              letterSpacing: 1.0,
              color: AppTheme.dimmed,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isPlaceholder ? AppTheme.muted : AppTheme.black,
                ),
              ),
              if (hasArrow)
                const Icon(Icons.chevron_right_rounded, color: AppTheme.dimmed, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
