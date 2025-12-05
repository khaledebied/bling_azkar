import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../data/services/storage_service.dart';
import '../providers/prayer_times_providers.dart';

class LocationSelectionDialog extends ConsumerStatefulWidget {
  const LocationSelectionDialog({super.key});

  @override
  ConsumerState<LocationSelectionDialog> createState() => _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends ConsumerState<LocationSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storage = StorageService();
  List<Location> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final repository = MuslimRepository();
      final results = await repository.searchLocations(locationName: query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _selectLocation(Location location) async {
    final prefs = _storage.getPreferences();
    final updatedPrefs = prefs.copyWith(
      selectedLocationId: location.id,
      selectedLocationName: location.name,
      selectedLocationLatitude: location.latitude,
      selectedLocationLongitude: location.longitude,
      selectedLocationCountryCode: location.countryCode,
      selectedLocationCountryName: location.countryName,
    );
    
    await _storage.savePreferences(updatedPrefs);
    
    // Invalidate providers to refresh prayer times
    ref.invalidate(prayerTimesProvider);
    ref.invalidate(locationProvider);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isDarkMode = context.isDarkMode;
    final isArabic = l10n.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: isDarkMode ? context.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.isArabic ? 'اختر الموقع' : 'Select Location',
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  onChanged: _searchLocations,
                  decoration: InputDecoration(
                    hintText: l10n.isArabic
                        ? 'ابحث عن المدينة...'
                        : 'Search for city...',
                    prefixIcon: isArabic ? null : const Icon(Icons.search),
                    suffixIcon: isArabic ? const Icon(Icons.search) : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Results List
              Flexible(
                child: _isSearching
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.isArabic
                                        ? 'ابحث عن موقعك'
                                        : 'Search for your location',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final location = _searchResults[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_city,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  location.name,
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${location.countryName} (${location.countryCode})',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppTheme.primaryGreen,
                                ),
                                onTap: () => _selectLocation(location),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

