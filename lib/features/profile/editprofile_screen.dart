import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _schoolController;
  late TextEditingController _courseController;
  late TextEditingController _yearLevelController;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).value;

    _displayNameController = TextEditingController(
      text: user?.displayName ?? '',
    );
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _schoolController = TextEditingController(text: user?.school ?? '');
    _courseController = TextEditingController(text: user?.course ?? '');
    _yearLevelController = TextEditingController(text: user?.yearLevel ?? '');

    _displayNameController.addListener(_onChanged);
    _usernameController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
    _schoolController.addListener(_onChanged);
    _courseController.addListener(_onChanged);
    _yearLevelController.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    _courseController.dispose();
    _yearLevelController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> updates = {
        'displayName': _displayNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'school': _schoolController.text.trim(),
        'course': _courseController.text.trim(),
        'yearLevel': _yearLevelController.text.trim(),
      };

      await ref.read(userServiceProvider).updateFullProfile(user.uid, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;

    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Discard Changes?',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'KEEP EDITING',
              style: TextStyle(
                fontFamily: 'DM Mono',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DISCARD',
              style: TextStyle(
                fontFamily: 'DM Mono',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final initials = user?.displayName.isNotEmpty == true
        ? user!.displayName
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'S';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (await _confirmDiscard() && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
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
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading || !_hasChanges ? null : _saveProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _hasChanges
                              ? colorScheme.onSurface
                              : colorScheme.outline,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.surface,
                                ),
                              )
                            : Text(
                                'Save',
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: _hasChanges
                                      ? colorScheme.surface
                                      : colorScheme.onSurfaceVariant,
                                ),
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

                      // Profile Header Section
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          fontFamily: 'Syne',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 24,
                                          color: colorScheme.surface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    color: colorScheme.surface,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'Scholar',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  user?.username.isNotEmpty == true
                                      ? '@${user!.username}'
                                      : '@scholar',
                                  style: TextStyle(
                                    fontFamily: 'DM Mono',
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _ColorOption(
                                      color: colorScheme.onSurface,
                                      isSelected: true,
                                    ),
                                    _ColorOption(
                                      color: Colors.blueGrey.shade800,
                                    ),
                                    _ColorOption(
                                      color: Colors.deepPurple.shade900,
                                    ),
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
                          color: colorScheme.surface,
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _EditField(
                              label: 'DISPLAY NAME',
                              controller: _displayNameController,
                              hint: 'Your Full Name',
                            ),
                            Divider(color: colorScheme.outline, height: 1),
                            _EditField(
                              label: 'USERNAME',
                              controller: _usernameController,
                              hint: 'charlie_quest',
                            ),
                            Divider(color: colorScheme.outline, height: 1),
                            // Email is usually read-only or handled via re-auth
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EMAIL ADDRESS',
                                    style: TextStyle(
                                      fontFamily: 'DM Mono',
                                      fontSize: 9,
                                      letterSpacing: 1.0,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Syne',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: colorScheme.outline, height: 1),
                            _EditField(
                              label: 'BIO',
                              controller: _bioController,
                              hint: 'Add a short bio...',
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      const _SectionLabel(label: 'LEARNING PROFILE'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _EditField(
                              label: 'SCHOOL / INSTITUTION',
                              controller: _schoolController,
                              hint: 'e.g. PLM Manila',
                            ),
                            Divider(color: colorScheme.outline, height: 1),
                            _EditField(
                              label: 'COURSE / PROGRAM',
                              controller: _courseController,
                              hint: 'e.g. BS Computer Science',
                            ),
                            Divider(color: colorScheme.outline, height: 1),
                            _EditField(
                              label: 'YEAR LEVEL',
                              controller: _yearLevelController,
                              hint: 'e.g. 3rd Year',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: _isLoading || !_hasChanges ? null : _saveProfile,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _hasChanges
                                ? colorScheme.onSurface
                                : colorScheme.outline,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check,
                                color: colorScheme.surface,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isLoading ? 'Saving...' : 'Save Changes',
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const _SectionLabel(label: 'DANGER ZONE'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withOpacity(0.1),
                          border: Border.all(color: colorScheme.errorContainer),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delete Account',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: colorScheme.error,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colorScheme.error,
                              size: 20,
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
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 2,
              )
            : null,
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

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _EditField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              letterSpacing: 1.0,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: TextStyle(color: theme.colorScheme.outline),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
