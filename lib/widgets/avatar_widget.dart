import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/mock_data.dart';

class AvatarWidget extends StatelessWidget {
  final String initials;
  final int colorIndex;
  final double size;
  final double fontSize;

  const AvatarWidget({
    super.key,
    required this.initials,
    required this.colorIndex,
    this.size = 38,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final color = MockData.avatarColors[colorIndex % MockData.avatarColors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
