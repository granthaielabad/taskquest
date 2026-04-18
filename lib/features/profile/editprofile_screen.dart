import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  
  // Local states for instant preview
  String? _currentPhotoUrl; 
  Uint8List? _previewImageBytes;
  String _selectedBackground = '#111111';

  final List<String> _backgroundOptions = [
    '#111111', // Black
    '#757575', // Grey
    '#424242', // Grey 800
    '#BDBDBD', // Grey 400
    '#000000', // Deep Black
    '#EEEEEE', // Grey 200
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).value;

    _displayNameController = TextEditingController(text: user?.displayName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _schoolController = TextEditingController(text: user?.school ?? '');
    _courseController = TextEditingController(text: user?.course ?? '');
    _yearLevelController = TextEditingController(text: user?.yearLevel ?? '');
    _currentPhotoUrl = user?.photoUrl;
    _selectedBackground = user?.photoBackground ?? '#111111';

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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      
      // Firestore limit check (1MB)
      if (bytes.length > 800000) { // Using 800kb as a safe margin for base64 overhead
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image is too large! Please pick a smaller photo (under 800KB).')),
          );
        }
        return;
      }

      setState(() {
        _previewImageBytes = bytes;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String photoUrlToSave = _currentPhotoUrl ?? '';

      // If we have new bytes, convert to Base64 since Storage is unavailable
      if (_previewImageBytes != null) {
        final base64String = base64Encode(_previewImageBytes!);
        photoUrlToSave = 'data:image/jpeg;base64,$base64String';
      }

      final Map<String, dynamic> updates = {
        'displayName': _displayNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'school': _schoolController.text.trim(),
        'course': _courseController.text.trim(),
        'yearLevel': _yearLevelController.text.trim(),
        'photoUrl': photoUrlToSave,
        'photoBackground': _selectedBackground,
      };

      await ref.read(userServiceProvider).updateFullProfile(user.uid, updates);

      if (mounted) {
        setState(() {
          _currentPhotoUrl = photoUrlToSave;
          _previewImageBytes = null;
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Discard Changes?', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800)),
        content: const Text('You have unsaved changes. Are you sure you want to leave?', style: TextStyle(fontFamily: 'DM Mono', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('KEEP EDITING', style: TextStyle(fontFamily: 'DM Mono'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DISCARD', style: TextStyle(fontFamily: 'DM Mono', color: Colors.red, fontWeight: FontWeight.bold))),
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
        ? user!.displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'S';

    final displayPhotoUrl = _currentPhotoUrl ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (await _confirmDiscard() && context.mounted) Navigator.pop(context);
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurface),
                      ),
                    ),
                    const Text('Edit Profile', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)),
                    GestureDetector(
                      onTap: _isLoading || !_hasChanges ? null : _saveProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _hasChanges ? colorScheme.onSurface : colorScheme.outline,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isLoading
                            ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.surface))
                            : Text('Save', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 12, color: _hasChanges ? colorScheme.surface : colorScheme.onSurfaceVariant)),
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(_selectedBackground.replaceFirst('#', '0xFF'))),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: _previewImageBytes != null
                                        ? Image.memory(_previewImageBytes!, fit: BoxFit.cover)
                                        : displayPhotoUrl.isNotEmpty
                                            ? (displayPhotoUrl.startsWith('data:image') 
                                                ? Image.memory(base64Decode(displayPhotoUrl.split(',').last), fit: BoxFit.cover)
                                                : CachedNetworkImage(
                                                    imageUrl: displayPhotoUrl,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                    errorWidget: (context, url, error) => Center(child: Text(initials, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white))),
                                                  ))
                                            : Center(child: Text(initials, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white))),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: colorScheme.onSurface, shape: BoxShape.circle, border: Border.all(color: colorScheme.surface, width: 2)),
                                    child: Icon(Icons.camera_alt_outlined, color: colorScheme.surface, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.displayName ?? 'Scholar', style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 20)),
                                Text(user?.username.isNotEmpty == true ? '@${user!.username}' : '@scholar', style: TextStyle(fontFamily: 'DM Mono', fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 12),
                                Row(
                                  children: _backgroundOptions.map((hex) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedBackground = hex;
                                        _hasChanges = true;
                                      });
                                    },
                                    child: _ColorOption(
                                      color: Color(int.parse(hex.replaceFirst('#', '0xFF'))),
                                      isSelected: _selectedBackground == hex,
                                    ),
                                  )).toList(),
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
                        decoration: BoxDecoration(color: colorScheme.surface, border: Border.all(color: colorScheme.outline), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            _EditField(label: 'DISPLAY NAME', controller: _displayNameController, hint: 'Your Full Name'),
                            Divider(color: colorScheme.outline, height: 1),
                            _EditField(label: 'USERNAME', controller: _usernameController, hint: 'charlie_quest'),
                            Divider(color: colorScheme.outline, height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('EMAIL ADDRESS', style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, letterSpacing: 1.0, color: colorScheme.onSurfaceVariant.withOpacity(0.7))),
                                  const SizedBox(height: 4),
                                  Text(user?.email ?? '', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 15, color: colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Divider(color: colorScheme.outline, height: 1),
                            _EditField(label: 'BIO', controller: _bioController, hint: 'Add a short bio...', maxLines: 3),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const _SectionLabel(label: 'LEARNING PROFILE'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(color: colorScheme.surface, border: Border.all(color: colorScheme.outline), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            _EditField(label: 'SCHOOL / INSTITUTION', controller: _schoolController, hint: 'e.g. PLM Manila'),
                            Divider(color: colorScheme.outline, height: 1),
                            _EditField(label: 'COURSE / PROGRAM', controller: _courseController, hint: 'e.g. BS Computer Science'),
                            Divider(color: colorScheme.outline, height: 1),
                            _EditField(label: 'YEAR LEVEL', controller: _yearLevelController, hint: 'e.g. 3rd Year'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: _isLoading || !_hasChanges ? null : _saveProfile,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(color: _hasChanges ? colorScheme.onSurface : colorScheme.outline, borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: colorScheme.surface, size: 20),
                              const SizedBox(width: 8),
                              Text(_isLoading ? 'Saving...' : 'Save Changes', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 16, color: colorScheme.surface)),
                            ],
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
        border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2) : null,
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
      style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _EditField({required this.label, required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, letterSpacing: 1.0, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7))),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 15, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, hintText: hint, hintStyle: TextStyle(color: theme.colorScheme.outline), border: InputBorder.none),
          ),
        ],
      ),
    );
  }
}
