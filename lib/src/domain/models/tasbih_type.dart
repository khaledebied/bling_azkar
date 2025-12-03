import 'package:flutter/material.dart';

/// Represents a type of Tasbih with its configuration
class TasbihType {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final int defaultTarget;
  final IconData icon;
  final Color color;

  const TasbihType({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.defaultTarget,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TasbihType &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Predefined Tasbih types
class TasbihTypes {
  static const tasbih33 = TasbihType(
    id: 'tasbih_33',
    nameEn: '33-bead Subha',
    nameAr: 'سبحة 33 حبة',
    descriptionEn: 'Traditional 33-bead tasbih',
    descriptionAr: 'سبحة تقليدية 33 حبة',
    defaultTarget: 33,
    icon: Icons.circle_outlined,
    color: Color(0xFF10B981),
  );

  static const tasbih99 = TasbihType(
    id: 'tasbih_99',
    nameEn: '99-bead Tasbih',
    nameAr: 'سبحة 99 حبة',
    descriptionEn: 'Three rounds of 33 beads',
    descriptionAr: 'ثلاث جولات من 33 حبة',
    defaultTarget: 99,
    icon: Icons.auto_awesome,
    color: Color(0xFF14B8A6),
  );

  static const tasbih100 = TasbihType(
    id: 'tasbih_100',
    nameEn: '100-bead Tasbih',
    nameAr: 'سبحة 100 حبة',
    descriptionEn: 'Count to 100 style',
    descriptionAr: 'عد إلى 100',
    defaultTarget: 100,
    icon: Icons.filter_vintage,
    color: Color(0xFF3B82F6),
  );

  static const tasbih11 = TasbihType(
    id: 'tasbih_11',
    nameEn: '11-bead Mini Tasbih',
    nameAr: 'سبحة صغيرة 11 حبة',
    descriptionEn: 'Short rounds for quick dhikr',
    descriptionAr: 'جولات قصيرة للذكر السريع',
    defaultTarget: 11,
    icon: Icons.minimize,
    color: Color(0xFFF59E0B),
  );

  static const tasbih7 = TasbihType(
    id: 'tasbih_7',
    nameEn: '7-bead Tasbih',
    nameAr: 'سبحة 7 حبات',
    descriptionEn: 'Short daily dhikr',
    descriptionAr: 'ذكر يومي قصير',
    defaultTarget: 7,
    icon: Icons.filter_7,
    color: Color(0xFF8B5CF6),
  );

  static const tasbihWrist = TasbihType(
    id: 'tasbih_wrist',
    nameEn: 'Wrist Tasbih',
    nameAr: 'سبحة معصم',
    descriptionEn: 'Compact wearable style',
    descriptionAr: 'أسلوب مضغوط قابل للارتداء',
    defaultTarget: 33,
    icon: Icons.watch,
    color: Color(0xFFEC4899),
  );

  static const tasbihDigital = TasbihType(
    id: 'tasbih_digital',
    nameEn: 'Pocket Digital Tasbih',
    nameAr: 'سبحة رقمية جيبية',
    descriptionEn: 'Digital counter style',
    descriptionAr: 'نمط عداد رقمي',
    defaultTarget: 100,
    icon: Icons.smartphone,
    color: Color(0xFF6366F1),
  );

  static const tasbihGemstone = TasbihType(
    id: 'tasbih_gemstone',
    nameEn: 'Gemstone Tasbih',
    nameAr: 'سبحة أحجار كريمة',
    descriptionEn: 'Aesthetic prayer beads',
    descriptionAr: 'خرز صلاة جمالي',
    defaultTarget: 99,
    icon: Icons.diamond,
    color: Color(0xFF06B6D4),
  );

  static const tasbihWooden = TasbihType(
    id: 'tasbih_wooden',
    nameEn: 'Wooden Classic Tasbih',
    nameAr: 'سبحة خشبية كلاسيكية',
    descriptionEn: 'Traditional warm wood look',
    descriptionAr: 'مظهر خشبي دافئ تقليدي',
    defaultTarget: 99,
    icon: Icons.spa,
    color: Color(0xFF92400E),
  );

  static const tasbihMultiSection = TasbihType(
    id: 'tasbih_multi',
    nameEn: 'Multi-section Tasbih',
    nameAr: 'سبحة متعددة الأقسام',
    descriptionEn: 'Separators for count groups',
    descriptionAr: 'فواصل لمجموعات العد',
    defaultTarget: 99,
    icon: Icons.view_module,
    color: Color(0xFF059669),
  );

  static List<TasbihType> get all => [
        tasbih33,
        tasbih99,
        tasbih100,
        tasbih11,
        tasbih7,
        tasbihWrist,
        tasbihDigital,
        tasbihGemstone,
        tasbihWooden,
        tasbihMultiSection,
      ];

  static TasbihType? getById(String id) {
    try {
      return all.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}

