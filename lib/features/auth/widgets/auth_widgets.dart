import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';

// Shared field label 
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTheme.labelMono,
    );
  }
}

class TQInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final int maxLines;
  final bool hasError;

  const TQInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.maxLines = 1,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(
          color: hasError 
              ? Colors.red 
              : (isFocused ? AppTheme.black : AppTheme.border),
          width: (isFocused || hasError) ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        style: AppTheme.bodyMono.copyWith(color: AppTheme.black, fontSize: 13),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.bodyMono.copyWith(color: AppTheme.dimmed, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}

// Primary CTA button
class TQButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const TQButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.black,
          disabledBackgroundColor: AppTheme.black.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTheme.headingM.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
      ),
    );
  }
}

// OR divider
class OrDivider extends StatelessWidget {
  final String label;
  const OrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: AppTheme.labelMono.copyWith(fontSize: 9, color: AppTheme.dimmed),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.border)),
      ],
    );
  }
}

// Google sign-in button
class GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const GoogleButton({
    super.key, 
    required this.onTap,
    this.label = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.white,
          side: const BorderSide(color: AppTheme.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CustomPaint(painter: GoogleIconPainter()),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTheme.bodyMono.copyWith(
                fontSize: 12,
                color: AppTheme.black,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Google "G" icon painter
class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    _drawArc(canvas, cx, cy, r, -0.52, 1.57, const Color(0xFF4285F4));
    _drawArc(canvas, cx, cy, r, 3.66, 1.15, const Color(0xFFEA4335));
    _drawArc(canvas, cx, cy, r, 2.62, 1.05, const Color(0xFFFBBC05));
    _drawArc(canvas, cx, cy, r, 1.05, 1.57, const Color(0xFF34A853));

    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, whitePaint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = r * 0.28
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.85, cy),
      barPaint,
    );
  }

  void _drawArc(Canvas canvas, double cx, double cy, double r,
      double startAngle, double sweepAngle, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweepAngle,
        false,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
