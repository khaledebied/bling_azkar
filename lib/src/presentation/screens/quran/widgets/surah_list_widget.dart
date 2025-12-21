import 'package:flutter/material.dart';
import '../../../../domain/models/quran_data.dart';
import '../../../../utils/theme.dart';
import '../../../../utils/theme_extensions.dart';

class SurahListWidget extends StatelessWidget {
  final List<SurahData> surahs;
  final Function(SurahData) onSurahTap;
  final bool isArabic;

  const SurahListWidget({
    super.key,
    required this.surahs,
    required this.onSurahTap,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return _buildSurahItem(context, surah);
      },
    );
  }

  Widget _buildSurahItem(BuildContext context, SurahData surah) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? const Color(0xFF1E2827) // Dark mint-ish green for dark mode
        : const Color(0xFFE0F2F1); // Light mint green for light mode

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onSurahTap(surah),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 80,
            child: Row(
              children: [
                // Star Number
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(40, 40),
                        painter: StarPainter(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        '${surah.number}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // English Name & Translation (Left side in LTR, Right in RTL conceptually but positioned differently)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   Text(
                      surah.nameAr,
                      style: AppTheme.quranMedium.copyWith(
                        fontSize: 20,
                        height: 1.0,
                         color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                     Text(
                      surah.nameEn,
                      style: AppTheme.bodySmall.copyWith(
                         color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Draw an 8-point star (Rub el Hizb style specific simplified)
    // Two squares rotated
    
    // Square 1
    final r = w / 2 - 2;
    // We can draw a path that looks like the star.
    // Or just draw two rects rotated.
    
    // Easier manual path for the octagram shape relative to the image
    // The image shows a specific 8-point rosette.
    // Let's approximating with two squares (rotated 45 deg).
    
    canvas.save();
    canvas.translate(cx, cy);
    
    // Draw Square 1
    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w*0.7, height: h*0.7), paint);
    
    // Draw Square 2 (Rotated)
    // canvas.rotate(3.14159 / 4); // 45 degrees
    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w*0.7, height: h*0.7), paint);
    
    // Actually the image is a bit more curvy/custom. Let's stick to the 8-pointed star icon style.
    // Actually, drawing a closed path is safer for stroke.
    
    double step = 3.14159 * 2 / 8;
    // Outer points
    
    // Let's use a simpler approach which matches the image: 
    // It's an 8-pointed star.
    
    // Vertices
    List<Offset> points = [];
    double outerRadius = w / 2;
    double innerRadius = w / 2.5; // Slightly indented

    for (int i = 0; i < 16; i++) {
        double angle = i * 3.14159 * 2 / 16;
        double radius = (i % 2 == 0) ? outerRadius : innerRadius;
        // Adjust for pointy star vs square-ish star. 
        // The image is two squares.
        // If we use just 8 points stepping by 45 degrees, we get the vertices of the squares.
    }
    
    // Let's simply draw two squares.
    final rectSide = w * 0.7;
    // Square 1
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: rectSide, height: rectSide), paint);
    
    // Square 2
    canvas.rotate(3.14159 / 4);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: rectSide, height: rectSide), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
