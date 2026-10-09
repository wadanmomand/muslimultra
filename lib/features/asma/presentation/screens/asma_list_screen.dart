import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/asma_name.dart';
import '../providers/asma_providers.dart';
import 'asma_detail_screen.dart';

class AsmaListScreen extends ConsumerStatefulWidget {
  const AsmaListScreen({super.key});

  @override
  ConsumerState<AsmaListScreen> createState() => _AsmaListScreenState();
}

class _AsmaListScreenState extends ConsumerState<AsmaListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLastViewed();
  }

  Future<void> _loadLastViewed() async {
    final lastIndex = await ref.read(asmaRepositoryProvider).getLastViewedIndex();
    if (mounted) {
      ref.read(lastViewedAsmaIndexProvider.notifier).state = lastIndex;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allNamesAsync = ref.watch(asmaNamesProvider);
    final filteredNames = ref.watch(filteredAsmaNamesProvider);
    final lastViewedIndex = ref.watch(lastViewedAsmaIndexProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.asmaUlHusna,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: allNamesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Failed to load names',
            style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
          ),
        ),
        data: (allNames) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => ref.read(asmaSearchQueryProvider.notifier).state = val,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchAsmaHint,
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.gold, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(asmaSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Resume Banner (if available and not searching)
              if (_searchController.text.isEmpty &&
                  lastViewedIndex > 0 &&
                  lastViewedIndex < allNames.length)
                _buildResumeBanner(context, allNames[lastViewedIndex], allNames, lastViewedIndex, l10n, isDark),

              // Names List
              Expanded(
                child: filteredNames.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noNamesFound,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filteredNames.length + 1, // +1 for source note
                        itemBuilder: (context, index) {
                          if (index == filteredNames.length) {
                            return _buildSourceFooter(context, l10n, isDark);
                          }
                          final name = filteredNames[index];
                          final originalIndex = allNames.indexWhere((n) => n.n == name.n);
                          return _buildNameTile(
                            context,
                            name,
                            allNames,
                            originalIndex >= 0 ? originalIndex : index,
                            isDark,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResumeBanner(
    BuildContext context,
    AsmaName name,
    List<AsmaName> allNames,
    int lastIndex,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AsmaDetailScreen(initialIndex: lastIndex, names: allNames),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, color: AppColors.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue reading: #${name.n} ${name.tr}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        name.en,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.gold, size: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameTile(
    BuildContext context,
    AsmaName item,
    List<AsmaName> allNames,
    int originalIndex,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AsmaDetailScreen(
                  initialIndex: originalIndex,
                  names: allNames,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Number Badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      '${item.n}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Transliteration & English
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.tr,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.en,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Arabic Calligraphy Text
                Text(
                  item.ar,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceFooter(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.4) : const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 16),
              const SizedBox(width: 6),
              Text(
                l10n.sourceTirmidhi,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tirmidhiScholarlyNote,
            style: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
