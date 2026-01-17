import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

final showBottomNavProvider = StateProvider<bool>((ref) => true);
