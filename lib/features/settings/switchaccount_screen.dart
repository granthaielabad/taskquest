import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';

class SwitchAccountScreen extends StatelessWidget {
  const SwitchAccountScreen({super.key});

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
                  const Expanded(
                    child: Text(
                      'Switch Account',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: AppTheme.black,
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
                    const _SectionLabel(label: 'ACTIVE ACCOUNT'),
                    const SizedBox(height: 12),
                    
                    // Active Account Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF333333)),
                            ),
                            child: const Center(
                              child: Text('JD', style: TextStyle(fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Juan dela Cruz', style: TextStyle(fontFamily: 'Syne',
                                    fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
                                const Text('juan@taskquest.app', style: TextStyle(fontFamily: 'DM Mono',
                                    fontSize: 11, color: Color(0x66FFFFFF))),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF333333)),
                                  ),
                                  child: const Text('★ LEVEL 4 · APPRENTICE QUESTER', style: TextStyle(
                                      fontFamily: 'DM Mono', fontSize: 8,
                                      letterSpacing: 0.5, color: Color(0x99FFFFFF))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C853),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'OTHER ACCOUNTS'),
                    const SizedBox(height: 12),
                    
                    // Other Accounts Group
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: const [
                          _AccountTile(
                            initials: 'JD',
                            name: 'Juan (School)',
                            email: 'juan.school@plm.edu.ph',
                            color: Color(0xFF2C4364),
                          ),
                          Divider(color: AppTheme.border, height: 1),
                          _AccountTile(
                            initials: 'MR',
                            name: 'Maria Reyes',
                            email: 'maria@taskquest.app',
                            color: Color(0xFF3F3D56),
                          ),
                          Divider(color: AppTheme.border, height: 1),
                          _AccountTile(
                            initials: 'CP',
                            name: 'Carlo Pascual',
                            email: 'carlo@taskquest.app',
                            color: Color(0xFF2D5C43),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Add Account Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: AppTheme.dimmed, size: 20),
                          SizedBox(width: 8),
                          Text('Add Another Account', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.dimmed)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Sign Out Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5252),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Sign Out of All Accounts', 
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 10.5, color: Color(0xFFFF5252))),
                                const Text('You\'ll need to log back in', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFFE2E1DC)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Switching accounts saves your current progress automatically. Each account has its own XP, badges, and streak.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.dimmed, height: 1.6),
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

class _AccountTile extends StatelessWidget {
  final String initials;
  final String name;
  final String email;
  final Color color;
  final bool isLast;

  const _AccountTile({
    required this.initials,
    required this.name,
    required this.email,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.black)),
                Text(email, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('SWITCH', style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppTheme.muted)),
          ),
        ],
      ),
    );
  }
}
