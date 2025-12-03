import 'package:flutter/material.dart';

/// Represents a type of Dhikr/Tasbih with its configuration
class TasbihType {
  final String id;
  final String nameEn;
  final String nameAr;
  final String dhikrText;
  final String meaningEn;
  final String meaningAr;
  final String benefitEn;
  final String benefitAr;
  final int defaultTarget;
  final IconData icon;
  final Color color;

  const TasbihType({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.dhikrText,
    required this.meaningEn,
    required this.meaningAr,
    required this.benefitEn,
    required this.benefitAr,
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

/// Predefined Islamic Dhikr types for Tasbih
class TasbihTypes {
  // 1. Subhanallah
  static const subhanallah = TasbihType(
    id: 'subhanallah',
    nameEn: 'Subhanallah',
    nameAr: 'سُبْحَانَ اللَّه',
    dhikrText: 'سُبْحَانَ اللَّه',
    meaningEn: 'Glory be to Allah',
    meaningAr: 'تنزيه الله عن كل نقص',
    benefitEn: 'Heavy in the scale of deeds',
    benefitAr: 'ثقيلة في الميزان',
    defaultTarget: 33,
    icon: Icons.auto_awesome,
    color: Color(0xFF10B981),
  );

  // 2. Alhamdulillah
  static const alhamdulillah = TasbihType(
    id: 'alhamdulillah',
    nameEn: 'Alhamdulillah',
    nameAr: 'الْـحَمْدُ لِلَّه',
    dhikrText: 'الْـحَمْدُ لِلَّه',
    meaningEn: 'All praise is due to Allah',
    meaningAr: 'الشكر والثناء على الله',
    benefitEn: 'Fills the scale of good deeds',
    benefitAr: 'تملأ الميزان',
    defaultTarget: 33,
    icon: Icons.favorite,
    color: Color(0xFF14B8A6),
  );

  // 3. Allahu Akbar
  static const allahuAkbar = TasbihType(
    id: 'allahu_akbar',
    nameEn: 'Allahu Akbar',
    nameAr: 'اللَّهُ أَكْبَر',
    dhikrText: 'اللَّهُ أَكْبَر',
    meaningEn: 'Allah is the Greatest',
    meaningAr: 'الله أعظم من كل شيء',
    benefitEn: 'Said after prayers with Tasbih and Tahmid',
    benefitAr: 'تُقال مع التسبيح والتحميد بعد الصلاة',
    defaultTarget: 34,
    icon: Icons.star,
    color: Color(0xFF3B82F6),
  );

  // 4. La ilaha illallah
  static const laIlahaIllallah = TasbihType(
    id: 'la_ilaha_illallah',
    nameEn: 'La ilaha illallah',
    nameAr: 'لَا إِلَهَ إِلَّا اللَّه',
    dhikrText: 'لَا إِلَهَ إِلَّا اللَّه',
    meaningEn: 'There is no god but Allah',
    meaningAr: 'توحيد الله',
    benefitEn: 'One of the greatest dhikr in reward',
    benefitAr: 'من أعظم الأذكار أجرًا',
    defaultTarget: 100,
    icon: Icons.mosque,
    color: Color(0xFF8B5CF6),
  );

  // 5. Astaghfirullah
  static const astaghfirullah = TasbihType(
    id: 'astaghfirullah',
    nameEn: 'Astaghfirullah',
    nameAr: 'أَسْتَغْفِرُ اللَّه',
    dhikrText: 'أَسْتَغْفِرُ اللَّه',
    meaningEn: 'I seek forgiveness from Allah',
    meaningAr: 'طلب المغفرة',
    benefitEn: 'Erases sins and relieves distress',
    benefitAr: 'تمحو الذنوب وتفرّج الهم',
    defaultTarget: 100,
    icon: Icons.self_improvement,
    color: Color(0xFFF59E0B),
  );

  // 6. Salawat on Prophet
  static const salawat = TasbihType(
    id: 'salawat',
    nameEn: 'Salawat on Prophet',
    nameAr: 'الصلاة على النبي',
    dhikrText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّد',
    meaningEn: 'O Allah, send blessings upon Muhammad',
    meaningAr: 'الصلاة على النبي ﷺ',
    benefitEn: 'Cause for provision and relief from distress',
    benefitAr: 'سبب للرزق وتفريج الكرب',
    defaultTarget: 100,
    icon: Icons.circle,
    color: Color(0xFFEC4899),
  );

  static List<TasbihType> get all => [
        subhanallah,
        alhamdulillah,
        allahuAkbar,
        laIlahaIllallah,
        astaghfirullah,
        salawat,
      ];

  static TasbihType? getById(String id) {
    try {
      return all.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}

