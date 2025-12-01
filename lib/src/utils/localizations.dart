import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Get localizations with fallback to English
  static AppLocalizations ofWithFallback(BuildContext context) {
    return of(context) ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  // Common
  String get appName => isArabic ? 'بِلينج أذكار' : 'Bling Azkar';
  String get ok => isArabic ? 'موافق' : 'OK';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get search => isArabic ? 'بحث' : 'Search';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get back => isArabic ? 'رجوع' : 'Back';
  String get next => isArabic ? 'التالي' : 'Next';
  String get previous => isArabic ? 'السابق' : 'Previous';
  String get done => isArabic ? 'تم' : 'Done';
  String get reset => isArabic ? 'إعادة تعيين' : 'Reset';
  String get clear => isArabic ? 'مسح' : 'Clear';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get yes => isArabic ? 'نعم' : 'Yes';
  String get no => isArabic ? 'لا' : 'No';

  // Home Screen
  String get peaceBeUponYou => isArabic ? 'السلام عليكم' : 'Peace be upon you';
  String get searchAzkar => isArabic ? 'ابحث عن الأذكار...' : 'Search azkar...';
  String get categories => isArabic ? 'الفئات' : 'Categories';
  String get all => isArabic ? 'الكل' : 'All';
  String get favorites => isArabic ? 'المفضلة' : 'Favorites';
  String get recent => isArabic ? 'الأخيرة' : 'Recent';
  String get reminders => isArabic ? 'التذكيرات' : 'Reminders';
  String get dailyAzkar => isArabic ? 'الأذكار اليومية' : 'Daily Azkar';
  String get keepHeartClose => isArabic
      ? 'اجعل قلبك قريباً من الله'
      : 'Keep your heart close to Allah';
  String get noAzkarFound => isArabic ? 'لم يتم العثور على أذكار' : 'No azkar found';
  String get noAzkarInCategory =>
      isArabic ? 'لا توجد أذكار في هذه الفئة' : 'No azkar found in this category';
  String get clearFilter => isArabic ? 'مسح الفلتر' : 'Clear filter';
  String get explore => isArabic ? 'استكشف' : 'Explore';

  // Zikr Detail Screen
  String get setReminder => isArabic ? 'تعيين تذكير' : 'Set Reminder';
  String get manageReminder => isArabic ? 'إدارة التذكير' : 'Manage Reminder';
  String get chooseReminderType => isArabic
      ? 'اختر كيف تريد أن يتم تذكيرك'
      : 'Choose how you want to be reminded';
  String get activeReminders => isArabic ? 'التذكيرات النشطة' : 'Active Reminders';
  String get dailyAtFixedTime =>
      isArabic ? 'يومياً في وقت محدد' : 'Daily at Fixed Time';
  String get dailyAtFixedTimeDesc => isArabic
      ? 'احصل على تذكير في نفس الوقت كل يوم'
      : 'Get reminded at the same time every day';
  String get everyXMinutes => isArabic ? 'كل X دقيقة' : 'Every X Minutes';
  String get everyXMinutesDesc => isArabic
      ? 'احصل على تذكير على فترات منتظمة'
      : 'Get reminded at regular intervals';
  String get repetitionCount =>
      isArabic ? 'عدد التكرار' : 'Repetition Count';
  String get completed => isArabic ? 'مكتمل' : 'Completed';
  String get of => isArabic ? 'من' : 'of';

  // Reminder Dialog
  String get setInterval => isArabic ? 'تعيين الفترة' : 'Set Interval';
  String get every => isArabic ? 'كل' : 'Every';
  String get minute => isArabic ? 'دقيقة' : 'minute';
  String get minutes => isArabic ? 'دقائق' : 'minutes';
  String get hour => isArabic ? 'ساعة' : 'hour';
  String get hours => isArabic ? 'ساعات' : 'hours';
  String get reminderSetFor => isArabic ? 'تم تعيين التذكير لـ' : 'Reminder set for';
  String get reminderSetEvery =>
      isArabic ? 'تم تعيين التذكير لكل' : 'Reminder set for every';
  String get errorCreatingReminder =>
      isArabic ? 'خطأ في إنشاء التذكير' : 'Error creating reminder';
  String get active => isArabic ? 'نشط' : 'Active';
  String get inactive => isArabic ? 'غير نشط' : 'Inactive';
  String get deleteReminder => isArabic ? 'حذف التذكير' : 'Delete Reminder';
  String get deleteReminderConfirm => isArabic
      ? 'هل أنت متأكد من حذف هذا التذكير؟'
      : 'Are you sure you want to delete this reminder?';
  String get pleaseEnableNotifications => isArabic
      ? 'يرجى تفعيل الإشعارات في الإعدادات'
      : 'Please enable notifications in settings';
  String get set => isArabic ? 'تعيين' : 'Set';

  // Reminders Screen
  String get noReminders => isArabic ? 'لا توجد تذكيرات' : 'No Reminders';
  String get noRemindersDesc => isArabic
      ? 'قم بتعيين التذكيرات للحصول على إشعارات حول أذكارك اليومية'
      : 'Set reminders to get notified about your daily Azkar';
  String get viewZikr => isArabic ? 'عرض الذكر' : 'View Zikr';

  // Settings Screen
  String get language => isArabic ? 'اللغة' : 'Language';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get enableNotifications =>
      isArabic ? 'تفعيل الإشعارات' : 'Enable Notifications';
  String get appearance => isArabic ? 'المظهر' : 'Appearance';
  String get theme => isArabic ? 'المظهر' : 'Theme';
  String get light => isArabic ? 'فاتح' : 'Light';
  String get dark => isArabic ? 'داكن' : 'Dark';
  String get system => isArabic ? 'النظام' : 'System';
  String get textSize => isArabic ? 'حجم النص' : 'Text Size';
  String get storage => isArabic ? 'التخزين' : 'Storage';
  String get clearCache => isArabic ? 'مسح الذاكرة المؤقتة' : 'Clear Cache';
  String get clearAllData => isArabic ? 'مسح جميع البيانات' : 'Clear All Data';
  String get about => isArabic ? 'حول' : 'About';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get privacy => isArabic ? 'الخصوصية' : 'Privacy';
  String get terms => isArabic ? 'الشروط' : 'Terms';
  String get help => isArabic ? 'المساعدة' : 'Help';
  String get feedback => isArabic ? 'التعليقات' : 'Feedback';
  String get rateApp => isArabic ? 'قيم التطبيق' : 'Rate App';
  String get shareApp => isArabic ? 'شارك التطبيق' : 'Share App';

  // Audio Player
  String get play => isArabic ? 'تشغيل' : 'Play';
  String get pause => isArabic ? 'إيقاف مؤقت' : 'Pause';
  String get stop => isArabic ? 'إيقاف' : 'Stop';
  String get replay => isArabic ? 'إعادة' : 'Replay';
  String get forward => isArabic ? 'تقديم' : 'Forward';
  String get backward => isArabic ? 'رجوع' : 'Backward';

  // General
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get error => isArabic ? 'خطأ' : 'Error';
  String get success => isArabic ? 'نجح' : 'Success';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

