import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for search query text
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for search active state
final isSearchingProvider = StateProvider<bool>((ref) => false');

/// Provider for selected tab index
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);
