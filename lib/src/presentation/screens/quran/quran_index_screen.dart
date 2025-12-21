import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';
import '../../../../utils/localizations.dart';
import '../../../../domain/models/quran_data.dart';
import 'widgets/surah_list_widget.dart';
import '../../quran_screen.dart';

class QuranIndexScreen extends StatefulWidget {
  final Function(int surahNumber, int? ayatNumber) onSurahSelected;

  const QuranIndexScreen({
    super.key,
    required this.onSurahSelected,
  });

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _indexTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
    _indexTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _indexTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Main Tabs (Index, Search, Dividers)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2827) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _mainTabController,
            indicator: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Colors.grey : Colors.grey[600],
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: "الفواصل"), // Bookmarks/Dividers - Placeholder
              Tab(text: "البحث"),   // Search
              Tab(text: "الفهرس"),  // Index
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _mainTabController,
            children: [
              // Bookmarks Tab
              const Center(child: Text("Bookmarks")), 
              
              // Search Tab
              const Center(child: Text("Search")),
              
              // Index Tab (Nested Tabs: Juz / Surah)
              Column(
                children: [
                   // Index Sub-Tabs
                   Container(
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     child: TabBar(
                      controller: _indexTabController,
                      indicatorColor: AppTheme.primaryGreen,
                      indicatorWeight: 3,
                      labelColor: AppTheme.primaryGreen,
                       unselectedLabelColor: isDark ? Colors.grey : Colors.grey[600],
                      tabs: [
                        Tab(text: "الأجزاء"), // Juz
                        Tab(text: "السور"),   // Surah
                      ],
                                       ),
                   ),
                   const Divider(height: 1),

                   Expanded(
                     child: TabBarView(
                       controller: _indexTabController,
                       children: [
                         // Juz List (Placeholder for now)
                         const Center(child: Text("Juz List")),
                         
                         // Surah List
                         SurahListWidget(
                           surahs: SurahData.allSurahs,
                           onSurahTap: (surah) => widget.onSurahSelected(surah.number, null),
                           isArabic: l10n.isArabic,
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
