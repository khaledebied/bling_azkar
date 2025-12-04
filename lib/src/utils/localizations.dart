import 'package:flutter/material.dart';

/// Simple localization helper using maps
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static AppLocalizations ofWithFallback(BuildContext context) {
    return of(context) ?? AppLocalizations(const Locale('en'));
  }

  bool get isArabic => locale.languageCode == 'ar';

  // Simple getter that returns localized strings
  String _get(String key) {
    final strings = isArabic ? _arabicStrings : _englishStrings;
    return strings[key] ?? key;
  }

  // Common
  String get appName => _get('appName');
  String get ok => _get('ok');
  String get cancel => _get('cancel');
  String get save => _get('save');
  String get delete => _get('delete');
  String get edit => _get('edit');
  String get close => _get('close');
  String get search => _get('search');
  String get settings => _get('settings');
  String get back => _get('back');
  String get next => _get('next');
  String get previous => _get('previous');
  String get done => _get('done');
  String get reset => _get('reset');
  String get clear => _get('clear');
  String get confirm => _get('confirm');
  String get yes => _get('yes');
  String get no => _get('no');

  // Home Screen
  String get peaceBeUponYou => _get('peaceBeUponYou');
  String get searchAzkar => _get('searchAzkar');
  String get categories => _get('categories');
  String get all => _get('all');
  String get favorites => _get('favorites');
  String get recent => _get('recent');
  String get reminders => _get('reminders');
  String get dailyAzkar => _get('dailyAzkar');
  String get keepHeartClose => _get('keepHeartClose');
  String get noAzkarFound => _get('noAzkarFound');
  String get noAzkarInCategory => _get('noAzkarInCategory');
  String get clearFilter => _get('clearFilter');
  String get errorLoadingAzkar => _get('errorLoadingAzkar');
  String get noFavoritesYet => _get('noFavoritesYet');
  String get addFavoritesHint => _get('addFavoritesHint');
  String get recentAzkarWillAppearHere => _get('recentAzkarWillAppearHere');

  // Player Screen
  String get repetitionCount => _get('repetitionCount');
  String get ofCount => _get('ofCount');
  String get completed => _get('completed');

  // Reminders
  String get setReminder => _get('setReminder');
  String get manageReminder => _get('manageReminder');
  String get enableNotificationsInSettings => _get('enableNotificationsInSettings');
  String get pleaseEnableNotifications => _get('pleaseEnableNotifications');
  String get chooseHowToRemind => _get('chooseHowToRemind');
  String get chooseReminderType => _get('chooseReminderType');
  String get activeReminders => _get('activeReminders');
  String get dailyAtFixedTime => _get('dailyAtFixedTime');
  String get dailyAtFixedTimeDesc => _get('dailyAtFixedTimeDesc');
  String get everyXMinutes => _get('everyXMinutes');
  String get everyXMinutesDesc => _get('everyXMinutesDesc');
  String get dailyAt => _get('dailyAt');
  String get every => _get('every');
  String get minutes => _get('minutes');
  String get active => _get('active');
  String get inactive => _get('inactive');
  String get deleteReminder => _get('deleteReminder');
  String get confirmDeleteReminder => _get('confirmDeleteReminder');
  String get dailyReminderSet => _get('dailyReminderSet');
  String get setReminderInterval => _get('setReminderInterval');
  String get setInterval => _get('setInterval');
  String get chooseIntervalForReminders => _get('chooseIntervalForReminders');
  String get remindEvery => _get('remindEvery');
  String get hours => _get('hours');
  String get set => _get('set');
  String get reminderSetEvery => _get('reminderSetEvery');
  String get reminderSetFor => _get('reminderSetFor');
  String get errorCreatingReminder => _get('errorCreatingReminder');
  String get noReminders => _get('noReminders');
  String intervalReminderSet(int minutes) => _get('intervalReminderSet').replaceAll('{minutes}', minutes.toString());
  String get noRemindersSet => _get('noRemindersSet');
  String get noRemindersDesc => _get('noRemindersDesc');
  String get setRemindersFromZikrDetail => _get('setRemindersFromZikrDetail');
  String get unknownZikr => _get('unknownZikr');
  String get zikrNotFound => _get('zikrNotFound');
  String get viewZikr => _get('viewZikr');
  String get deleteReminderConfirm => _get('deleteReminderConfirm');

  // Settings
  String get language => _get('language');
  String get english => _get('english');
  String get arabic => _get('arabic');
  String get notifications => _get('notifications');
  String get enableNotifications => _get('enableNotifications');
  String get doNotDisturb => _get('doNotDisturb');
  String get from => _get('from');
  String get to => _get('to');
  String get disabled => _get('disabled');
  String get appearance => _get('appearance');
  String get theme => _get('theme');
  String get systemDefault => _get('systemDefault');
  String get textScale => _get('textScale');
  String get textSize => _get('textSize');
  String get storage => _get('storage');
  String get clearCache => _get('clearCache');
  String get clearAllData => _get('clearAllData');
  String get confirmClearAllData => _get('confirmClearAllData');
  String get allDataCleared => _get('allDataCleared');
  String get about => _get('about');
  String get version => _get('version');
  String get licenses => _get('licenses');
  String get help => _get('help');
  String get feedback => _get('feedback');
  String get send => _get('send');
  String get hour => _get('hour');
  String get minute => _get('minute');

  // Tab Names
  String get azkar => _get('azkar');
  String get tasbih => _get('tasbih');
  String get quranKareem => _get('quranKareem');
  String get electronicTasbih => _get('electronicTasbih');

  // Common Actions
  String get playAll => _get('playAll');
  String get pauseAll => _get('pauseAll');
  String get resumeAll => _get('resumeAll');
  String get playAllFavorites => _get('playAllFavorites');
  String get retry => _get('retry');
  String get goBack => _get('goBack');
  String get restart => _get('restart');
  String get explore => _get('explore');
  String get seeAll => _get('seeAll');
  String get viewAllCategories => _get('viewAllCategories');

  // Messages
  String get noAudiosAvailable => _get('noAudiosAvailable');
  String get errorLoadingCategories => _get('errorLoadingCategories');
  String get errorLoadingFavorites => _get('errorLoadingFavorites');
  String get errorLoadingQuran => _get('errorLoadingQuran');
  String get quranLibraryError => _get('quranLibraryError');
  String get errorPlayingAudio => _get('errorPlayingAudio');
  String get errorInitializing => _get('errorInitializing');
  String get cacheCleared => _get('cacheCleared');

  // Player Screen
  String get playFullAudio => _get('playFullAudio');
  String get audioRecitation => _get('audioRecitation');
  String get tapToPlay => _get('tapToPlay');
  String get arabicText => _get('arabicText');
  String get translation => _get('translation');
  String get recommendedRepetitions => _get('recommendedRepetitions');
  String get audioPreview => _get('audioPreview');
  String completedRepetitions(int count) => _get('completedRepetitions').replaceAll('{count}', count.toString());

  // Tasbih
  String get sessionComplete => _get('sessionComplete');
  String get mayAllahAccept => _get('mayAllahAccept');
  String get tapToCount => _get('tapToCount');
  String get selectTasbihType => _get('selectTasbihType');
  String get completedTapRestart => _get('completedTapRestart');

  // Settings
  String get zikrReminders => _get('zikrReminders');
  String get enableReminders => _get('enableReminders');
  String get enabledEvery10Minutes => _get('enabledEvery10Minutes');
  String get remindersEnabledEvery10Minutes => _get('remindersEnabledEvery10Minutes');
  String get remindersDisabled => _get('remindersDisabled');
  String get light => _get('light');
  String get dark => _get('dark');
  String get system => _get('system');
  String get pleaseEnableNotificationsDevice => _get('pleaseEnableNotificationsDevice');

  // Stats
  String get totalItems => _get('totalItems');
  String get audio => _get('audio');
  String get audios => _get('audios');

  // English strings
  static const Map<String, String> _englishStrings = {
    'appName': 'Bling Azkar',
    'ok': 'OK',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'close': 'Close',
    'search': 'Search',
    'settings': 'Settings',
    'back': 'Back',
    'next': 'Next',
    'previous': 'Previous',
    'done': 'Done',
    'reset': 'Reset',
    'clear': 'Clear',
    'confirm': 'Confirm',
    'yes': 'Yes',
    'no': 'No',
    'peaceBeUponYou': 'Peace be upon you',
    'searchAzkar': 'Search azkar...',
    'categories': 'Categories',
    'all': 'All',
    'favorites': 'Favorites',
    'recent': 'Recent',
    'reminders': 'Reminders',
    'dailyAzkar': 'Daily Azkar',
    'keepHeartClose': 'Keep your heart close to Allah',
    'noAzkarFound': 'No azkar found',
    'noAzkarInCategory': 'No azkar in this category',
    'clearFilter': 'Clear Filter',
    'errorLoadingAzkar': 'Error loading azkar',
    'noFavoritesYet': 'No favorites yet',
    'addFavoritesHint': 'Add your favorite azkar by tapping the heart icon',
    'recentAzkarWillAppearHere': 'Recent azkar will appear here',
    'repetitionCount': 'Repetition Count',
    'ofCount': 'of',
    'completed': 'Completed',
    'setReminder': 'Set Reminder',
    'manageReminder': 'Manage Reminder',
    'enableNotificationsInSettings': 'Please enable notifications in settings',
    'pleaseEnableNotifications': 'Please enable notifications in settings',
    'chooseHowToRemind': 'Choose how you want to be reminded',
    'chooseReminderType': 'Choose how you want to be reminded',
    'activeReminders': 'Active Reminders',
    'dailyAtFixedTime': 'Daily at Fixed Time',
    'dailyAtFixedTimeDesc': 'Get reminded at the same time every day',
    'everyXMinutes': 'Every X Minutes',
    'everyXMinutesDesc': 'Get reminded at regular intervals',
    'dailyAt': 'Daily at',
    'every': 'Every',
    'minutes': 'minutes',
    'active': 'Active',
    'inactive': 'Inactive',
    'deleteReminder': 'Delete Reminder',
    'confirmDeleteReminder': 'Are you sure you want to delete this reminder?',
    'dailyReminderSet': 'Daily reminder set',
    'setReminderInterval': 'Set Reminder Interval',
    'setInterval': 'Set Interval',
    'chooseIntervalForReminders': 'Choose interval for reminders',
    'remindEvery': 'Remind every',
    'hours': 'hours',
    'set': 'Set',
    'reminderSetEvery': 'Reminder set for every',
    'reminderSetFor': 'Reminder set for',
    'errorCreatingReminder': 'Error creating reminder',
    'noReminders': 'No Reminders',
    'intervalReminderSet': 'Interval reminder set for every {minutes} minutes',
    'noRemindersSet': 'No reminders set',
    'noRemindersDesc': 'You can set reminders from the Zikr detail screen',
    'setRemindersFromZikrDetail': 'You can set reminders from the Zikr detail screen',
    'unknownZikr': 'Unknown Zikr',
    'zikrNotFound': 'Zikr not found',
    'viewZikr': 'View Zikr',
    'deleteReminderConfirm': 'Are you sure you want to delete this reminder?',
    'language': 'Language',
    'english': 'English',
    'arabic': 'Arabic',
    'notifications': 'Notifications',
    'enableNotifications': 'Enable Notifications',
    'doNotDisturb': 'Do Not Disturb',
    'from': 'From',
    'to': 'To',
    'disabled': 'Disabled',
    'appearance': 'Appearance',
    'theme': 'Theme',
    'systemDefault': 'System Default',
    'textScale': 'Text Scale',
    'textSize': 'Text Size',
    'storage': 'Storage',
    'clearCache': 'Clear Cache',
    'clearAllData': 'Clear All Data',
    'confirmClearAllData': 'Are you sure you want to clear all app data? This action cannot be undone.',
    'allDataCleared': 'All data cleared',
    'about': 'About',
    'version': 'Version',
    'licenses': 'Licenses',
    'help': 'Help',
    'feedback': 'Feedback',
    'send': 'Send',
    'hour': 'hour',
    'minute': 'minute',
    'azkar': 'Azkar',
    'tasbih': 'Tasbih',
    'quranKareem': 'Quran Kareem',
    'electronicTasbih': 'Electronic Tasbih',
    'playAll': 'Play All',
    'pauseAll': 'Pause All',
    'resumeAll': 'Resume All',
    'playAllFavorites': 'Play All Favorites',
    'retry': 'Retry',
    'goBack': 'Go Back',
    'restart': 'Restart',
    'explore': 'Explore',
    'seeAll': 'See All',
    'viewAllCategories': 'View All Categories',
    'noAudiosAvailable': 'No audios available',
    'errorLoadingCategories': 'Error loading categories',
    'errorLoadingFavorites': 'Error loading favorites',
    'errorLoadingQuran': 'Error Loading Quran',
    'quranLibraryError': 'Quran Library Error',
    'errorPlayingAudio': 'Error playing audio',
    'errorInitializing': 'Error initializing',
    'cacheCleared': 'Cache cleared',
    'playFullAudio': 'Play Full Audio',
    'audioRecitation': 'Audio Recitation',
    'tapToPlay': 'Tap to play',
    'arabicText': 'Arabic Text',
    'translation': 'Translation',
    'recommendedRepetitions': 'Recommended Repetitions',
    'audioPreview': 'Audio Preview',
    'completedRepetitions': 'Completed {count}x repetitions!',
    'sessionComplete': 'Session Complete',
    'mayAllahAccept': 'May Allah accept your dhikr',
    'tapToCount': 'Tap to count',
    'selectTasbihType': 'Select Tasbih Type',
    'completedTapRestart': 'Completed — Tap Restart to begin again',
    'zikrReminders': 'Zikr Reminders',
    'enableReminders': 'Enable Reminders',
    'enabledEvery10Minutes': 'Enabled - Every 10 minutes',
    'remindersEnabledEvery10Minutes': 'Reminders enabled - Every 10 minutes ❤️',
    'remindersDisabled': 'Reminders disabled',
    'light': 'Light',
    'dark': 'Dark',
    'system': 'System',
    'pleaseEnableNotificationsDevice': 'Please enable notifications in device settings',
    'totalItems': 'total items',
    'audio': 'audio',
    'audios': 'audios',
  };

  // Arabic strings
  static const Map<String, String> _arabicStrings = {
    'appName': 'بِلينج أذكار',
    'ok': 'موافق',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'close': 'إغلاق',
    'search': 'بحث',
    'settings': 'الإعدادات',
    'back': 'رجوع',
    'next': 'التالي',
    'previous': 'السابق',
    'done': 'تم',
    'reset': 'إعادة تعيين',
    'clear': 'مسح',
    'confirm': 'تأكيد',
    'yes': 'نعم',
    'no': 'لا',
    'peaceBeUponYou': 'السلام عليكم',
    'searchAzkar': 'ابحث عن الأذكار...',
    'categories': 'الفئات',
    'all': 'الكل',
    'favorites': 'المفضلة',
    'recent': 'الأخيرة',
    'reminders': 'التذكيرات',
    'dailyAzkar': 'الأذكار اليومية',
    'keepHeartClose': 'اجعل قلبك قريبًا من الله',
    'noAzkarFound': 'لم يتم العثور على أذكار',
    'noAzkarInCategory': 'لا توجد أذكار في هذه الفئة',
    'clearFilter': 'مسح الفلتر',
    'errorLoadingAzkar': 'خطأ في تحميل الأذكار',
    'noFavoritesYet': 'لا توجد مفضلة بعد',
    'addFavoritesHint': 'أضف أذكارك المفضلة بالضغط على أيقونة القلب',
    'recentAzkarWillAppearHere': 'ستظهر الأذكار الأخيرة هنا',
    'repetitionCount': 'عدد التكرار',
    'ofCount': 'من',
    'completed': 'اكتمل',
    'setReminder': 'تعيين تذكير',
    'manageReminder': 'إدارة التذكير',
    'enableNotificationsInSettings': 'يرجى تمكين الإشعارات في الإعدادات',
    'pleaseEnableNotifications': 'يرجى تمكين الإشعارات في الإعدادات',
    'chooseHowToRemind': 'اختر كيف تريد أن يتم تذكيرك',
    'chooseReminderType': 'اختر كيف تريد أن يتم تذكيرك',
    'activeReminders': 'التذكيرات النشطة',
    'dailyAtFixedTime': 'يوميًا في وقت محدد',
    'dailyAtFixedTimeDesc': 'احصل على تذكير في نفس الوقت كل يوم',
    'everyXMinutes': 'كل X دقيقة',
    'everyXMinutesDesc': 'احصل على تذكير على فترات منتظمة',
    'dailyAt': 'يوميًا في',
    'every': 'كل',
    'minutes': 'دقيقة',
    'active': 'نشط',
    'inactive': 'غير نشط',
    'deleteReminder': 'حذف التذكير',
    'confirmDeleteReminder': 'هل أنت متأكد أنك تريد حذف هذا التذكير؟',
    'dailyReminderSet': 'تم تعيين التذكير اليومي',
    'setReminderInterval': 'تعيين فترة التذكير',
    'setInterval': 'تعيين الفترة',
    'chooseIntervalForReminders': 'اختر الفترة الزمنية للتذكيرات',
    'remindEvery': 'تذكير كل',
    'hours': 'ساعات',
    'set': 'تعيين',
    'reminderSetEvery': 'تم تعيين التذكير لكل',
    'reminderSetFor': 'تم تعيين التذكير لـ',
    'errorCreatingReminder': 'خطأ في إنشاء التذكير',
    'noReminders': 'لا توجد تذكيرات',
    'intervalReminderSet': 'تم تعيين التذكير كل {minutes} دقيقة',
    'noRemindersSet': 'لم يتم تعيين أي تذكيرات',
    'noRemindersDesc': 'يمكنك تعيين تذكيرات من شاشة تفاصيل الذكر',
    'setRemindersFromZikrDetail': 'يمكنك تعيين تذكيرات من شاشة تفاصيل الذكر',
    'unknownZikr': 'ذكر غير معروف',
    'zikrNotFound': 'لم يتم العثور على الذكر',
    'viewZikr': 'عرض الذكر',
    'deleteReminderConfirm': 'هل أنت متأكد أنك تريد حذف هذا التذكير؟',
    'language': 'اللغة',
    'english': 'الإنجليزية',
    'arabic': 'العربية',
    'notifications': 'الإشعارات',
    'enableNotifications': 'تمكين الإشعارات',
    'doNotDisturb': 'عدم الإزعاج',
    'from': 'من',
    'to': 'إلى',
    'disabled': 'معطل',
    'appearance': 'المظهر',
    'theme': 'السمة',
    'systemDefault': 'افتراضي النظام',
    'textScale': 'حجم النص',
    'textSize': 'حجم النص',
    'storage': 'التخزين',
    'clearCache': 'مسح ذاكرة التخزين المؤقت',
    'clearAllData': 'مسح جميع البيانات',
    'confirmClearAllData': 'هل أنت متأكد أنك تريد مسح جميع بيانات التطبيق؟ لا يمكن التراجع عن هذا الإجراء.',
    'allDataCleared': 'تم مسح جميع البيانات',
    'about': 'حول',
    'version': 'الإصدار',
    'licenses': 'التراخيص',
    'help': 'المساعدة',
    'feedback': 'التعليقات',
    'send': 'إرسال',
    'hour': 'ساعة',
    'minute': 'دقيقة',
    'azkar': 'الأذكار',
    'tasbih': 'التسبيح',
    'quranKareem': 'القرآن الكريم',
    'electronicTasbih': 'التسبيح الإلكتروني',
    'playAll': 'تشغيل الكل',
    'pauseAll': 'إيقاف الكل',
    'resumeAll': 'استئناف الكل',
    'playAllFavorites': 'تشغيل كل المفضلة',
    'retry': 'إعادة المحاولة',
    'goBack': 'رجوع',
    'restart': 'إعادة',
    'explore': 'استكشف',
    'seeAll': 'عرض الكل',
    'viewAllCategories': 'عرض جميع الفئات',
    'noAudiosAvailable': 'لا توجد ملفات صوتية متاحة',
    'errorLoadingCategories': 'خطأ في تحميل الفئات',
    'errorLoadingFavorites': 'خطأ في تحميل المفضلة',
    'errorLoadingQuran': 'خطأ في تحميل القرآن',
    'quranLibraryError': 'خطأ في مكتبة القرآن',
    'errorPlayingAudio': 'خطأ في تشغيل الصوت',
    'errorInitializing': 'خطأ في التهيئة',
    'cacheCleared': 'تم مسح الذاكرة المؤقتة',
    'playFullAudio': 'تشغيل الصوت الكامل',
    'audioRecitation': 'تلاوة صوتية',
    'tapToPlay': 'اضغط للتشغيل',
    'arabicText': 'النص العربي',
    'translation': 'الترجمة',
    'recommendedRepetitions': 'التكرارات الموصى بها',
    'audioPreview': 'معاينة الصوت',
    'completedRepetitions': 'اكتمل {count} تكرار!',
    'sessionComplete': 'جلسة مكتملة',
    'mayAllahAccept': 'تقبل الله منك',
    'tapToCount': 'اضغط للعد',
    'selectTasbihType': 'اختر نوع التسبيح',
    'completedTapRestart': 'مكتمل — اضغط إعادة للبدء من جديد',
    'zikrReminders': 'تذكير الأذكار',
    'enableReminders': 'تفعيل التذكير',
    'enabledEvery10Minutes': 'مفعل - كل 10 دقائق',
    'remindersEnabledEvery10Minutes': 'تم تفعيل التذكير كل 10 دقائق ❤️',
    'remindersDisabled': 'تم إيقاف التذكير',
    'light': 'فاتح',
    'dark': 'داكن',
    'system': 'نظام',
    'pleaseEnableNotificationsDevice': 'يرجى السماح بالإشعارات من إعدادات الجهاز',
    'totalItems': 'إجمالي العناصر',
    'audio': 'صوت',
    'audios': 'أصوات',
  };
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}


extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.ofWithFallback(this);
}
