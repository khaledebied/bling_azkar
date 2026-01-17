import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../utils/direction_icons.dart';
import '../widgets/category_card.dart';
import '../widgets/floating_playlist_player.dart';
import '../widgets/category_audio_bottom_sheet.dart';
import '../widgets/animated_zikr_header.dart';
import '../providers/search_providers.dart';
import '../providers/azkar_providers.dart';
import '../../data/services/playlist_service.dart';
import '../widgets/zikr_list_item.dart';
import '../widgets/prayer_times_card.dart';
import '../providers/prayer_times_providers.dart';
import 'zikr_detail_screen.dart';
import 'settings_screen.dart';
import 'categories_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _playlistService = PlaylistService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _playlistService.initialize();
  }

