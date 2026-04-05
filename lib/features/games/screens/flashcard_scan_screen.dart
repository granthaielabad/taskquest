import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/games/services/ai_scan_service.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/games/screens/study_flashcard_screen.dart';
import 'package:taskquest/features/games/screens/manual_flashcard_screen.dart';
import 'package:taskquest/features/badges/providers/badge_provider.dart';

class FlashcardScanScreen extends ConsumerStatefulWidget {
  const FlashcardScanScreen({super.key});

  @override
  ConsumerState<FlashcardScanScreen> createState() => _FlashcardScanScreenState();
}

class _FlashcardScanScreenState extends ConsumerState<FlashcardScanScreen> {
  final AIScanService _aiService = AIScanService();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  
  bool _isScanning = false;
  double _progress = 0.0;
  String? _selectedFileName;
  String? _selectedFileSize;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _pickAndScanFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final fileSize = '${(result.files.single.size / 1024 / 1024).toStringAsFixed(1)} MB';

    setState(() {
      _isScanning = true;
      _progress = 0.1;
      _selectedFileName = fileName;
      _selectedFileSize = fileSize;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _progress = 0.3);

      final flashcards = await _aiService.generateFlashcardsFromFile(file);
      setState(() => _progress = 0.7);

      final user = ref.read(currentUserProvider);
      if (user != null) {
        final deck = FlashcardDeckModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          title: fileName.split('.').first,
          type: 'AI',
          category: 'AI Generated', // AI decks get this category by default
          cards: flashcards,
          createdAt: DateTime.now(),
        );
        await ref.read(flashcardServiceProvider).createDeck(deck);
        await ref.read(badgeServiceProvider).checkFlashAI(user.uid);
      }

      setState(() => _progress = 1.0);
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved ${flashcards.length} cards to "${fileName.split('.').first}"')),
        );
        setState(() => _isScanning = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDecksAsync = ref.watch(userDecksProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _isScanning ? _buildScanningView() : _buildUploadView(userDecksAsync),
        ),
      ),
    );
  }

  Widget _buildUploadView(AsyncValue<List<FlashcardDeckModel>> userDecksAsync) {
    return SingleChildScrollView(
      key: const ValueKey('upload'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI\nFlashcards',
                    style: AppTheme.headingXL.copyWith(
                      fontSize: 32,
                      height: 0.9,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan a doc, get a full deck instantly',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
              _buildAIBadge(),
            ],
          ),
          const SizedBox(height: 32),
          _buildUploadBox(),
          const SizedBox(height: 24),
          _buildManualDivider(),
          const SizedBox(height: 24),
          _buildManualButton(),
          const SizedBox(height: 40),
          
          _buildSearchBar(),
          const SizedBox(height: 24),

          _buildMyDecksHeader(),
          const SizedBox(height: 16),
          
          userDecksAsync.when(
            data: (decks) {
              final filtered = decks.where((d) => 
                d.title.toLowerCase().contains(_query) || 
                d.category.toLowerCase().contains(_query)
              ).toList();
              
              if (filtered.isEmpty && _query.isNotEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No matching decks found.', style: AppTheme.bodyMono),
                ));
              }
              return Column(
                children: filtered.map((d) => _buildDeckItem(context, d)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: const TextStyle(fontFamily: 'DM Mono', fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search decks or categories...',
          hintStyle: const TextStyle(fontFamily: 'DM Mono', color: AppTheme.muted, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.muted, size: 20),
          suffixIcon: _query.isNotEmpty 
              ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () => _searchController.clear())
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  Widget _buildScanningView() {
    return Container(
      key: const ValueKey('scanning'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.file_present_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 32),
                const Text(
                  'AI IS WORKING',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    letterSpacing: 1.8,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scanning your\ndocument...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reading content, identifying key\nconcepts, and generating flashcards for\nyou.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    height: 1.6,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PROCESSING',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 9,
                        color: Color(0xFF777777),
                      ),
                    ),
                    Text(
                      '${(_progress * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                _buildStatusRow('Document uploaded', _progress >= 0.3),
                const SizedBox(height: 12),
                _buildStatusRow('Text extracted', _progress >= 0.7),
                const SizedBox(height: 12),
                _buildStatusRow('Generating flashcards...', _progress >= 1.0, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFileFooter(),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isDone, {bool isLast = false}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isDone ? Colors.white : Colors.transparent,
            border: Border.all(color: isDone ? Colors.white : const Color(0xFF444444)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: isDone ? const Icon(Icons.check, size: 12, color: AppTheme.black) : null,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 11,
            color: isDone ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildFileFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: AppTheme.black, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFileName ?? 'Document.pdf',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_selectedFileSize ?? '0.0 MB'} · Uploaded just now',
                  style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _selectedFileName?.split('.').last.toUpperCase() ?? 'FILE',
              style: const TextStyle(fontFamily: 'DM Mono', fontSize: 8, color: AppTheme.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            'AI',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return CustomPaint(
      painter: _DashedRectPainter(color: AppTheme.dimmed),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFEA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.file_upload_outlined, size: 28, color: AppTheme.black),
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload your document',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PDF, DOCX, TXT, or image files.\nOur AI will scan and build your deck.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 10,
                height: 1.5,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFileTypeChip('PDF'),
                const SizedBox(width: 8),
                _buildFileTypeChip('DOCX'),
                const SizedBox(width: 8),
                _buildFileTypeChip('TXT'),
                const SizedBox(width: 8),
                _buildFileTypeChip('PNG / JPG'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 240,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _pickAndScanFile,
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text('Choose File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFEA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 8,
          fontWeight: FontWeight.w500,
          color: AppTheme.muted,
        ),
      ),
    );
  }

  Widget _buildManualDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.border)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CREATE MANUALLY',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 8,
              letterSpacing: 1.2,
              color: AppTheme.muted,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.border)),
      ],
    );
  }

  Widget _buildManualButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManualFlashcardScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.style_outlined, size: 18, color: AppTheme.black),
              SizedBox(width: 12),
              Text(
                'Create Cards Manually',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyDecksHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'MY DECKS',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 10,
            letterSpacing: 1.8,
            color: AppTheme.muted,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'SEE ALL',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.0,
              color: AppTheme.muted,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeckItem(BuildContext context, FlashcardDeckModel deck) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyFlashcardScreen(deck: deck),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                deck.type == 'AI' ? Icons.auto_awesome_motion_rounded : Icons.style_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.title,
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${deck.cards.length} cards · ${deck.category}',
                    style: const TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${deck.masteryProgress}%',
                    style: const TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(deck.createdAt),
                  style: const TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 8,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashSpace = 4.0;
    const cornerLength = 12.0;

    final path = Path();
    
    path.moveTo(0, cornerLength);
    path.lineTo(0, 0);
    path.lineTo(cornerLength, 0);
    
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerLength);
    
    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - cornerLength, size.height);
    
    path.moveTo(cornerLength, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - cornerLength);

    canvas.drawPath(path, paint);

    _drawDashedLine(canvas, paint, Offset(cornerLength + dashSpace, 0), Offset(size.width - cornerLength - dashSpace, 0));
    _drawDashedLine(canvas, paint, Offset(size.width, cornerLength + dashSpace), Offset(size.width, size.height - cornerLength - dashSpace));
    _drawDashedLine(canvas, paint, Offset(size.width - cornerLength - dashSpace, size.height), Offset(cornerLength + dashSpace, size.height));
    _drawDashedLine(canvas, paint, Offset(0, size.height - cornerLength - dashSpace), Offset(0, cornerLength + dashSpace));
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    
    double distance = (end - start).distance;
    int count = (distance / (dashWidth + dashSpace)).floor();
    
    Offset direction = (end - start) / distance;
    
    for (int i = 0; i < count; i++) {
      Offset dashStart = start + direction * (i * (dashWidth + dashSpace));
      Offset dashEnd = dashStart + direction * dashWidth;
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
